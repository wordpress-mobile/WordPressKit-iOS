import Foundation

struct Root: Decodable {
    let prompts: [RemoteBloggingPrompt]
}

public class BloggingPromptsServiceRemote: ServiceRemoteWordPressComREST {

    /// Used to format dates so the time information is omitted.
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter
    }()

    /// Fetches a number of blogging prompts for the specified site.
    /// Note that this method hits wpcom/v2, which means the `WordPressComRestAPI` needs to be initialized with `LocaleKeyV2`.
    ///
    /// - Parameters:
    ///   - siteID: Used to check which prompts have been answered for the site with given `siteID`.
    ///   - number: The number of prompts to query. When not specified, this will default to remote implementation.
    ///   - fromDate: When specified, this will fetch prompts from the given date. When not specified, this will default to remote implementation.
    ///   - completion: A closure that will be called when the fetch request completes.
    func fetchPrompts(for siteID: NSNumber,
                      number: Int? = nil,
                      fromDate: Date? = nil,
                      completion: @escaping (Result<[RemoteBloggingPrompt], Error>) -> Void) {
        let path = path(forEndpoint: "sites/\(siteID)/blogging-prompts", withVersion: ._2_0)
        let requestParameter: [String: AnyHashable] = {
            var params = [String: AnyHashable]()

            if let number = number, number > 0 {
                params["number"] = number
            }

            if let fromDate = fromDate {
                // convert to yyyy-MM-dd format.
                // this parameter doesn't need to be timezone-accurate since prompts are grouped by date.
                params["from"] = Self.dateFormatter.string(from: fromDate)
            }

            return params
        }()

        wordPressComRestApi.GET(path, parameters: requestParameter as [String: AnyObject]) { result, _ in
            switch result {
            case .success(let responseObject):
                do {
                    let data = try JSONSerialization.data(withJSONObject: responseObject, options: [])
                    let decoder = JSONDecoder.apiDecoder
                    // our API decoder assumes that we're converting from snake case.
                    // revert it to default so the CodingKeys match the actual response keys.
                    decoder.keyDecodingStrategy = .useDefaultKeys
                    let response = try decoder.decode([String: [RemoteBloggingPrompt]].self, from: data)
                    completion(.success(response.values.first ?? []))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
