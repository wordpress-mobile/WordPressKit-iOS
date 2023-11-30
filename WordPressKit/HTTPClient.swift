import Foundation

public typealias WordPressAPIResult<R, E: LocalizedError> = Result<R, WordPressAPIError<E>>

struct HTTPAPIResponse<Body>{
    typealias Body = Body

    var response: HTTPURLResponse
    var body: Body
}

extension URLSession {

    func apiResult<E: LocalizedError>(
        with builder: HTTPRequestBuilder,
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

        return .success(.init(response: response, body: body))
    }

}

extension Result where Success == HTTPAPIResponse<Data> {

    func assessStatusCode<S, E: LocalizedError>(
        acceptable: [ClosedRange<Int>] = [200...299],
        success: (Success) -> S?,
        failure: (Success) -> E?
    ) -> WordPressAPIResult<S, E> where Failure == WordPressAPIError<E> {
        flatMap { response in
            if acceptable.contains(where: { $0 ~= response.response.statusCode }) {
                if let result = success(response) {
                    return .success(result)
                } else {
                    return .failure(.unparsableResponse(response: response.response, body: response.body))
                }
            } else {
                if let endpointError = failure(response) {
                    return .failure(.endpointError(endpointError))
                } else {
                    return .failure(.unparsableResponse(response: response.response, body: response.body))
                }
            }
        }
    }

}
