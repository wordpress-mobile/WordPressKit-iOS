import Foundation

open class BlazeServiceRemote: ServiceRemoteWordPressComREST {

    public typealias BlazeStatusResponseCallback = (Result<Bool, Error>) -> Void

    public enum BlazeServiceRemoteError: Error {
        case InvalidDataError
    }

    // MARK: - Status

    open func getStatus(forSiteId siteId: Int, callback: @escaping BlazeStatusResponseCallback) {

        let endpoint = "sites/\(siteId)/blaze/status"
        let path = self.path(forEndpoint: endpoint, withVersion: ._2_0)

        wordPressComRestApi.GET(path, parameters: nil, success: { response, _ in

            if let json = reponse as? [String: Any],
               let approved = json["approved"] as? Bool {
                callback(.success(approved))
            } else {
                callback(.failure(BlazeServiceRemoteError.InvalidDataError))
            }

        }, failure: { error, response in
            WPKitLogError("Error retrieving blaze status")
            WPKitLogError("\(error)")

            if let response = response {
                WPKitLogDebug("Response Code: \(response.statusCode)")
            }

            callback(.failure(error))
        })

    }
}
