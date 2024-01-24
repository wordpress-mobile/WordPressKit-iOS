import Foundation
import Combine

public typealias WordPressAPIResult<Response, Error: LocalizedError> = Result<Response, WordPressAPIError<Error>>

struct HTTPAPIResponse<Body> {
    var response: HTTPURLResponse
    var body: Body
}

extension HTTPAPIResponse where Body == Data {
    var bodyText: String? {
        var encoding: String.Encoding?
        if let charset = response.textEncodingName {
            encoding = String.Encoding(ianaCharsetName: charset)
        }

        let defaultEncoding = String.Encoding.isoLatin1
        return String(data: body, encoding: encoding ?? defaultEncoding)
    }
}

extension URLSession {

    /// Send a HTTP request and return its response as a `WordPressAPIResult` instance.
    ///
    /// ## Progress Tracking and Cancellation
    ///
    /// You can track the HTTP request's overall progress by passing a `Progress` instance to the `fulfillingProgress`
    /// parameter, which must satisify following requirements:
    /// - `totalUnitCount` must not be zero.
    /// - `completedUnitCount` must be zero.
    /// - It's used exclusivity for tracking the HTTP request overal progress: No children in its progress tree.
    /// - `cancellationHandler` must be nil. You can call `fulfillingProgress.cancel()` to cancel the ongoing HTTP request.
    ///
    ///  Upon completion, the HTTP request's progress fulfills the `fulfillingProgress`.
    ///
    /// - Parameters:
    ///   - builder: A `HTTPRequestBuilder` instance that represents an HTTP request to be sent.
    ///   - acceptableStatusCodes: HTTP status code ranges that are considered a successful response. Responses with
    ///         a status code outside of these ranges are returned as a `WordPressAPIResult.unacceptableStatusCode` instance.
    ///   - parentProgress: A `Progress` instance that will be used as the parent progress of the HTTP request's overall
    ///         progress. See the function documentation regarding requirements on this argument.
    ///   - errorType: The concret endpoint error type.
    func perform<E: LocalizedError>(
        request builder: HTTPRequestBuilder,
        acceptableStatusCodes: [ClosedRange<Int>] = [200...299],
        fulfilling parentProgress: Progress? = nil,
        errorType: E.Type = E.self
    ) async -> WordPressAPIResult<HTTPAPIResponse<Data>, E> {
        if let parentProgress {
            assert(parentProgress.completedUnitCount == 0 && parentProgress.totalUnitCount > 0, "Invalid parent progress")
            assert(parentProgress.cancellationHandler == nil, "The progress instance's cancellationHandler property must be nil")
        }

        return await withCheckedContinuation { continuation in
            let completion: @Sendable (Data?, URLResponse?, Error?) -> Void = { data, response, error in
                let result: WordPressAPIResult<HTTPAPIResponse<Data>, E> = Self.parseResponse(
                    data: data,
                    response: response,
                    error: error,
                    acceptableStatusCodes: acceptableStatusCodes
                )

                continuation.resume(returning: result)
            }

            let task: URLSessionTask

            do {
                task = try self.task(for: builder, completion: completion)
            } catch {
                continuation.resume(returning: .failure(.requestEncodingFailure(underlyingError: error)))
                return
            }

            task.resume()

            if let parentProgress, parentProgress.totalUnitCount > parentProgress.completedUnitCount {
                let pending = parentProgress.totalUnitCount - parentProgress.completedUnitCount
                // The Jetpack/WordPress app requires task progress updates to be delievered on the main queue.
                let progressUpdator = parentProgress.update(totoalUnit: pending, with: task.progress, queue: .main)

                parentProgress.cancellationHandler = { [weak task] in
                    task?.cancel()
                    progressUpdator.cancel()
                }
            }
        }
    }

    private func task(
        for builder: HTTPRequestBuilder,
        completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void
    ) throws -> URLSessionTask {
        var request = try builder.build(encodeMultipartForm: false)

        // Use special `URLSession.uploadTask` API for multipart POST requests.
        if let multipart = builder.multipartForm, !multipart.isEmpty {
            let isBackgroundSession = configuration.identifier != nil

            return try builder
                .encodeMultipartForm(request: &request, forceWriteToFile: isBackgroundSession)
                .map(
                    left: {
                        uploadTask(with: request, from: $0, completionHandler: completion)
                    },
                    right: {
                        uploadTask(with: request, fromFile: $0, completionHandler: completion)
                    }
                )
        } else {
            // Use `URLSession.dataTask` for all other request
            return dataTask(with: request, completionHandler: completion)
        }
    }

    private static func parseResponse<E: LocalizedError>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        acceptableStatusCodes: [ClosedRange<Int>]
    ) -> WordPressAPIResult<HTTPAPIResponse<Data>, E> {
        let result: WordPressAPIResult<HTTPAPIResponse<Data>, E>

        if let error {
            if let urlError = error as? URLError {
                result = .failure(.connection(urlError))
            } else {
                result = .failure(.unknown(underlyingError: error))
            }
        } else {
            if let httpResponse = response as? HTTPURLResponse {
                if acceptableStatusCodes.contains(where: { $0 ~= httpResponse.statusCode }) {
                    result = .success(HTTPAPIResponse(response: httpResponse, body: data ?? Data()))
                } else {
                    result = .failure(.unacceptableStatusCode(response: httpResponse, body: data ?? Data()))
                }
            } else {
                result = .failure(.unparsableResponse(response: nil, body: data))
            }
        }

        return result
    }

}

extension WordPressAPIResult {

    func mapSuccess<NewSuccess, E: LocalizedError>(
        _ transform: (Success) throws -> NewSuccess
    ) -> WordPressAPIResult<NewSuccess, E> where Success == HTTPAPIResponse<Data>, Failure == WordPressAPIError<E> {
        flatMap { success in
            do {
                return try .success(transform(success))
            } catch {
                return .failure(.unparsableResponse(response: success.response, body: success.body, underlyingError: error))
            }
        }
    }

    func decodeSuccess<NewSuccess: Decodable, E: LocalizedError>(
        _ decoder: JSONDecoder = JSONDecoder()
    ) -> WordPressAPIResult<NewSuccess, E> where Success == HTTPAPIResponse<Data>, Failure == WordPressAPIError<E> {
        mapSuccess {
            try decoder.decode(NewSuccess.self, from: $0.body)
        }
    }

    func mapUnacceptableStatusCodeError<E: LocalizedError>(
        _ transform: (HTTPURLResponse, Data) throws -> E
    ) -> WordPressAPIResult<Success, E> where Failure == WordPressAPIError<E> {
        mapError { error in
            if case let .unacceptableStatusCode(response, body) = error {
                do {
                    return try WordPressAPIError<E>.endpointError(transform(response, body))
                } catch {
                    return WordPressAPIError<E>.unparsableResponse(response: response, body: body, underlyingError: error)
                }
            }
            return error
        }
    }

    func mapUnacceptableStatusCodeError<E>(
        _ decoder: JSONDecoder = JSONDecoder()
    ) -> WordPressAPIResult<Success, E> where E: LocalizedError, E: Decodable, Failure == WordPressAPIError<E> {
        mapUnacceptableStatusCodeError { _, body in
            try decoder.decode(E.self, from: body)
        }
    }

}

extension Progress {
    func update(totoalUnit: Int64, with progress: Progress, queue: DispatchQueue) -> AnyCancellable {
        let start = self.completedUnitCount
        return progress.publisher(for: \.fractionCompleted, options: .new)
            .receive(on: queue)
            .sink { fraction in
                self.completedUnitCount = start + Int64(fraction * Double(totoalUnit))
            }
    }
}
