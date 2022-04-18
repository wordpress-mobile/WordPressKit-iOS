import Foundation
import WordPressShared

public class BloggingPromptsServiceRemote: ServiceRemoteWordPressComREST {

    /// Fetches a number of blogging prompts for the specified site.
    ///
    /// Note that this method hits version 2.0, which means the `WordPressComRestAPI` needs to be initialized with `LocaleKeyV2`.
    ///
    /// - Parameters:
    ///   - siteID: Used to check which prompts have been answered for the site with given `siteID`.
    ///   - number: The number of prompts to query. When not specified, this will default to remote implementation.
    ///   - after: When specified, this will fetch prompts after the given date. When not specified, this will default to remote implementation.
    ///   - success: A closure that will be called when the request succeeds.
    ///   - failure: A closure that will be called when the request fails.
    func fetchPrompts(for siteID: NSNumber,
                      number: Int? = nil,
                      after: Date? = nil,
                      success: @escaping ([RemoteBloggingPrompt]) -> Void,
                      failure: @escaping (Error) -> Void) {
        let path = path(forEndpoint: "blogging-prompts", withVersion: ._2_0)
        let requestParameter: [String: AnyHashable] = {
            var params = [String: AnyHashable]()

            if let number = number, number > 0 {
                params["number"] = number
            }

            if let dateAfter = after {
                params["after"] = DateUtils.isoString(from: dateAfter)
            }

            return params
        }()

        wordPressComRestApi.GET(path, parameters: requestParameter as [String: AnyObject]) { result, _ in
            switch result {
            case .success(let responseObject):
                do {
                    let data = try JSONSerialization.data(withJSONObject: responseObject, options: [])
                    let response = try JSONDecoder().decode([String:[RemoteBloggingPrompt]].self, from: data)
                    success(response.values.first ?? [])
                } catch {
                    failure(error)
                }

            case .failure(let error):
                failure(error)
            }
        }
    }
}
