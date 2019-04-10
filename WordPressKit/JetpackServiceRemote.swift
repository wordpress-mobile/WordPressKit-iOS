import Foundation

public enum JetpackInstallError: String, Error {
    case invalidCredentials = "INVALID_CREDENTIALS"
    case forbidden = "FORBIDDEN"
    case installFailure = "INSTALL_FAILURE"
    case installResponseError = "INSTALL_RESPONSE_ERROR"
    case loginFailure = "LOGIN_FAILURE"
    case siteIsJetpack = "SITE_IS_JETPACK"
    case activationOnInstallFailure = "ACTIVATION_ON_INSTALL_FAILURE"
    case activationResponseError = "ACTIVATION_RESPONSE_ERROR"
    case activationFailure = "ACTIVATION_FAILURE"
    case unknown
    
    init(error key: String) {
        self = JetpackInstallError(rawValue: key) ?? .unknown
    }
}

public class JetpackServiceRemote: ServiceRemoteWordPressComREST {
    public enum ResponseError: Error {
        case decodingFailed
    }

    @objc public func checkSiteHasJetpack(_ url: URL, success: @escaping (Bool) -> Void, failure: @escaping (Error?) -> Void) {
        let path = self.path(forEndpoint: "connect/site-info", withVersion: ._1_0)
        wordPressComRestApi.GET(path,
                                parameters: ["url": url.absoluteString as AnyObject],
                                success: { [weak self] (response: AnyObject, httpResponse: HTTPURLResponse?) in
                                    do {
                                        let hasJetpack = try self?.hasJetpackMapping(object: response)
                                        success(hasJetpack ?? false)
                                    } catch {
                                        failure(error)
                                    }
        }) { (error: NSError, httpResponse: HTTPURLResponse?) in
            failure(error)
        }
    }

    func installJetpack(url: String,
                        username: String,
                        password: String,
                        completion: @escaping (Bool, JetpackInstallError?) -> Void) {
        guard let escapedURL = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(false, .unknown)
            return
        }
        let path = String(format: "jetpack-install/%@/", escapedURL)
        let requestUrl = self.path(forEndpoint: path, withVersion: ._1_0)
        let parameters = ["user": username,
                          "password": password]

        wordPressComRestApi.POST(requestUrl,
                                 parameters: parameters as [String : AnyObject],
                                 success: { (response: AnyObject, httpResponse: HTTPURLResponse?) in
                                    if let response = response as? [String: Bool],
                                        let success = response[Constants.status] {
                                        completion(success, nil)
                                    } else {
                                        completion(false, .installResponseError)
                                    }
        }) { (error: NSError, httpResponse: HTTPURLResponse?) in
            if let key = error.userInfo[WordPressComRestApi.ErrorKeyErrorCode] as? String {
                completion(false, JetpackInstallError(error: key))
            } else {
                completion(false, .unknown)
            }
        }
    }

    private enum Constants {
        static let hasJetpack = "hasJetpack"
        static let status = "status"
    }
}

private extension JetpackServiceRemote {
    func hasJetpackMapping(object: AnyObject) throws -> Bool {
        guard let response = object as? [String: AnyObject],
            let hasJetpack = response[Constants.hasJetpack] as? NSNumber else {
                throw ResponseError.decodingFailed
        }
        return hasJetpack.boolValue
    }
}
