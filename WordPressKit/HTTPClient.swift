import Foundation

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

    func perform<E: LocalizedError>(
        request builder: HTTPRequestBuilder,
        acceptableStatusCodes: [ClosedRange<Int>] = [200...299],
        errorType: E.Type = E.self
    ) async -> WordPressAPIResult<HTTPAPIResponse<Data>, E> {
        guard let request = try? builder.build() else {
            return .failure(.requestEncodingFailure)
        }

        let result: (Data, URLResponse)
        do {
            result = try await data(for: request)
        } catch {
            if let urlError = error as? URLError {
                return .failure(.connection(urlError))
            } else {
                return .failure(.unknown(underlyingError: error))
            }
        }

        let (body, response) = result

        guard let response = response as? HTTPURLResponse else {
            return .failure(.unparsableResponse(response: nil, body: body))
        }

        guard acceptableStatusCodes.contains(where: { $0 ~= response.statusCode }) else {
            return .failure(.unacceptableStatusCode(response: response, body: body))
        }

        return .success(.init(response: response, body: body))
    }

}

extension WordPressAPIResult {

    func mapSuccess<NewSuccess, E: LocalizedError>(
        _ transform: (Success) -> NewSuccess?
    ) -> WordPressAPIResult<NewSuccess, E> where Success == HTTPAPIResponse<Data>, Failure == WordPressAPIError<E> {
        flatMap { success in
            guard let newSuccess = transform(success) else {
                return .failure(.unparsableResponse(response: success.response, body: success.body))
            }

            return .success(newSuccess)
        }
    }

    func decodeSuccess<NewSuccess: Decodable, E: LocalizedError>(
        _ decoder: JSONDecoder = JSONDecoder()
    ) -> WordPressAPIResult<NewSuccess, E> where Success == HTTPAPIResponse<Data>, Failure == WordPressAPIError<E> {
        mapSuccess {
            try? decoder.decode(NewSuccess.self, from: $0.body)
        }
    }

    func mapUnacceptableStatusCodeError<E: LocalizedError>(
        _ transform: (HTTPURLResponse, Data) -> E?
    ) -> WordPressAPIResult<Success, E> where Failure == WordPressAPIError<E> {
        mapError { error in
            if case let .unacceptableStatusCode(response, body) = error {
                if let endpointError = transform(response, body) {
                    return WordPressAPIError<E>.endpointError(endpointError)
                } else {
                    return WordPressAPIError<E>.unparsableResponse(response: response, body: body)
                }
            }
            return error
        }
    }

    func mapUnacceptableStatusCodeError<E>(
        _ decoder: JSONDecoder = JSONDecoder()
    ) -> WordPressAPIResult<Success, E> where E: LocalizedError, E: Decodable, Failure == WordPressAPIError<E> {
        mapUnacceptableStatusCodeError { _, body in
            try? decoder.decode(E.self, from: body)
        }
    }

}
