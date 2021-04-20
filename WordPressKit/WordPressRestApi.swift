import Foundation

/// This class offers a wrapper to provide a common interface between `WordPressOrgRestApi` and `WordPressComRestApi` for classes that can use either
/// one nearly interchangably.
public protocol WordPressRestApi {
    typealias Completion = (Swift.Result<Any, Error>, HTTPURLResponse?) -> Void

    /**
     Executes a GET request to the specified endpoint defined on URLString

     - parameter path:  the url string to be added to the baseURL
     - parameter parameters: the parameters to be encoded on the request
     - parameter completion: callback to be called on successful or failed request.

     - returns:  a NSProgress object that can be used to track the progress of the request and to cancel the request. If the method
     returns nil it's because something happened on the request serialization and the network request was not started, but the failure callback
     will be invoked with the error specificing the serialization issues.
     */
    @discardableResult func GET(_ path: String, parameters: [String: AnyObject]?, completion: @escaping Completion) -> Progress?

    /**
    Modifies the provided path from an Org endpoint as needed to support a generic path for either `WordPressOrgRestApi` and `WordPressComRestApi`. This is meant to be
    used as a helper before calling the GET request.

     - parameter path:  the url string to be added to the baseURL
     - parameter siteID: the unique ID that represents a site.

     - returns:  a modified path or the same path depending on the implementation. A default implementation is provided that returns the same path.
     */
    func requestPath(fromOrgPath path: String, with siteID: Int?) -> String
}

extension WordPressRestApi {
    public func requestPath(fromOrgPath path: String, with siteID: Int?) -> String {
        return path
    }
}
