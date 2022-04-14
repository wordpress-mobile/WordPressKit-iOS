import Foundation

public class BloggingPromptsServiceRemote: ServiceRemoteWordPressComREST {

    /// Fetches a number of blogging prompts for the specified site.
    ///
    /// - Parameters:
    ///   - siteID: Used to check which prompts have been answered for the site with given `siteID`.
    ///   - number: The number of prompts to query. When not specified, this will default to remote implementation.
    ///   - after: When specified, this will fetch prompts after the given date. When not specified, this will default to remote implementation.
    func fetchPrompts(for siteID: NSNumber, number: Int? = nil, after: Date? = nil) {
        // TODO: Implement.
    }

}
