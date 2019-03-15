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

    init?(error code: String?) {
        guard let code = code else {
            self = .unknown
            return
        }

        self.init(rawValue: code)
    }
}

public extension BlogServiceRemoteREST {
    public func installJetpack(url: String,
                               username: String,
                               password: String,
                               completion: @escaping (Bool, JetpackInstallError?) -> Void) {
        guard let escapedURL = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(false, .unknown)
            return
        }
        let path = String(format: "jetpack-install/%@/?locale=en_US", escapedURL)
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
            let code = JetpackInstallError(error: error.userInfo[WordPressComRestApi.ErrorKeyErrorCode] as? String)
            completion(false, code ?? .unknown)
        }
    }
    
    private enum Constants {
        static let status = "status"
    }
}
