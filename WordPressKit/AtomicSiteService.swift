import Foundation

public final class AtomicSiteService: ServiceRemoteWordPressComREST {
    /// - parameter scrollID: Pass the scroll ID from the previous response to
    /// fetch the next page.
    public func getSiteErrorLogs(
        siteID: Int,
        range: Range<Date>,
        pageSize: Int = 50,
        severity: AtomicLogMessage.Severity? = nil,
        scrollID: String? = nil,
        success: @escaping (AtomicErrorLogsResponse) -> Void,
        failure: @escaping (Error) -> Void) 
    {
        let path = self.path(forEndpoint: "sites/\(siteID)/hosting/error-logs/", withVersion: ._2_0)
        var parameters = [
//            "start": "\(range.lowerBound.timeIntervalSince1970)",
//            "end": "\(range.upperBound.timeIntervalSince1970)",
            "sort_order": "desc"
//            "page_size": "\(pageSize)"
        ] as [String: AnyObject]
        if let severity {
            parameters["filter[severity][]"] = severity.rawValue as AnyObject
        }
        wordPressComRestApi.GET(path, parameters: parameters) { responseObject, httpResponse in
            guard (200..<300).contains(responseObject.statusCode ?? 0),
                  let data = responseObject as? [String: AnyObject] else {
                failure(URLError(.unknown))
                return
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: data)
                let response = try JSONDecoder.apiDecoder.decode(AtomicErrorLogsResponse.self, from: data)
                success(response)
            } catch {
                WPKitLogError("Error parsing campaigns response: \(error), \(responseObject)")
                failure(error)
            }
        } failure: { error, _ in
            failure(error)
        }
    }
}
