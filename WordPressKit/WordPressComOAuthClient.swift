import Alamofire

@objc public enum WordPressComOAuthError: Int {
    case unknown
    case invalidClient
    case unsupportedGrantType
    case invalidRequest
    case needsMultifactorCode
    case invalidOneTimePassword
    case socialLoginExistingUserUnconnected
    case invalidTwoStepCode
    case unknownUser
}

/// `WordPressComOAuthClient` encapsulates the pattern of authenticating against WordPress.com OAuth2 service.
///
/// Right now it requires a special client id and secret, so this probably won't work for you
/// @see https://developer.wordpress.com/docs/oauth2/
///
public final class WordPressComOAuthClient: NSObject {

    @objc public static let WordPressComOAuthErrorResponseObjectKey = "WordPressComOAuthErrorResponseObjectKey"
    @objc public static let WordPressComOAuthErrorNewNonceKey = "WordPressComOAuthErrorNewNonceKey"
    @objc public static let WordPressComOAuthErrorDomain = "WordPressComOAuthError"

    @objc public static let WordPressComOAuthDefaultBaseUrl = "https://wordpress.com"
    @objc public static let WordPressComOAuthDefaultApiBaseUrl = "https://public-api.wordpress.com"

    enum WordPressComURL: String {
        case oAuthBase = "/oauth2/token"
        case webauthnChallenge = "wp-login.php?action=webauthn-challenge-endpoint"
        case webauthnAuthentication = "wp-login.php?action=webauthn-authentication-endpoint"
        case socialLogin = "/wp-login.php?action=social-login-endpoint&version=1.0"
        case socialLogin2FA = "/wp-login.php?action=two-step-authentication-endpoint&version=1.0"
        case socialLoginNewSMS2FA = "/wp-login.php?action=send-sms-code-endpoint"

        func url(base: String) -> URL {
            return URL(string: self.rawValue, relativeTo: URL(string: base))!
        }
    }

    @objc public static let WordPressComSocialLoginEndpointVersion = 1.0

    private let clientID: String
    private let secret: String

    private let wordPressComBaseUrl: String
    private let wordPressComApiBaseUrl: String

    private let oauth2SessionManager: SessionManager = {
        return WordPressComOAuthClient.sessionManager()
    }()

    private let webauthnSessionManager: SessionManager = {
        return WordPressComOAuthClient.sessionManager()
    }()

    private let socialSessionManager: SessionManager = {
        return WordPressComOAuthClient.sessionManager()
    }()

    private let social2FASessionManager: SessionManager = {
        return WordPressComOAuthClient.sessionManager()
    }()

    private let socialNewSMS2FASessionManager: SessionManager = {
        return WordPressComOAuthClient.sessionManager()
    }()

    private class func sessionManager() -> SessionManager {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = ["Accept": "application/json"]
        let sessionManager = SessionManager(configuration: .ephemeral)

        return sessionManager
    }

    /// Creates a WordPresComOAuthClient initialized with the clientID and secrets provided
    ///
    @objc public class func client(clientID: String, secret: String) -> WordPressComOAuthClient {
        let client = WordPressComOAuthClient(clientID: clientID, secret: secret)
        return client
    }

    /// Creates a WordPresComOAuthClient initialized with the clientID, secret and base urls provided
    ///
    @objc public class func client(clientID: String,
                                   secret: String,
                                   wordPressComBaseUrl: String,
                                   wordPressComApiBaseUrl: String) -> WordPressComOAuthClient {
        let client = WordPressComOAuthClient(clientID: clientID,
                                             secret: secret,
                                             wordPressComBaseUrl: wordPressComBaseUrl,
                                             wordPressComApiBaseUrl: wordPressComApiBaseUrl)
        return client
    }

    /// Creates a WordPressComOAuthClient using the defined clientID and secret
    ///
    /// - Parameters:
    ///     - clientID: the app oauth clientID
    ///     - secret: the app secret
    ///     - wordPressComBaseUrl: The base url to use for WordPress.com requests. Defaults to https://wordpress.com
    ///     - wordPressComApiBaseUrl: The base url to use for WordPress.com API requests. Defaults to https://public-api-wordpress.com
    ///
    @objc public init(clientID: String,
                      secret: String,
                      wordPressComBaseUrl: String = WordPressComOAuthClient.WordPressComOAuthDefaultBaseUrl,
                      wordPressComApiBaseUrl: String = WordPressComOAuthClient.WordPressComOAuthDefaultApiBaseUrl) {
        self.clientID = clientID
        self.secret = secret
        self.wordPressComBaseUrl = wordPressComBaseUrl
        self.wordPressComApiBaseUrl = wordPressComApiBaseUrl
    }

    /// Authenticates on WordPress.com using the OAuth endpoints.
    ///
    /// - Parameters:
    ///     - username: the account's username.
    ///     - password: the account's password.
    ///     - multifactorCode: Multifactor Authentication One-Time-Password. If not needed, can be nil
    ///     - needsMultifactor: @escaping (_ userID: Int, _ nonceInfo: SocialLogin2FANonceInfo) -> Void,
    ///     - success: block to be called if authentication was successful. The OAuth2 token is passed as a parameter.
    ///     - failure: block to be called if authentication failed. The error object is passed as a parameter.
    ///
    @objc public func authenticateWithUsername(_ username: String,
                                               password: String,
                                               multifactorCode: String?,
                                               needsMultifactor: @escaping (_ userID: Int, _ nonceInfo: SocialLogin2FANonceInfo) -> Void,
                                               success: @escaping (_ authToken: String?) -> Void,
                                               failure: @escaping (_ error: NSError) -> Void ) {
        var parameters: [String: AnyObject] = [
            "username": username as AnyObject,
            "password": password as AnyObject,
            "grant_type": "password" as AnyObject,
            "client_id": clientID as AnyObject,
            "client_secret": secret as AnyObject,
            "wpcom_supports_2fa": true as AnyObject,
            "with_auth_types": true as AnyObject
        ]

        if let multifactorCode = multifactorCode, !multifactorCode.isEmpty {
            parameters["wpcom_otp"] = multifactorCode as AnyObject?
        }

        oauth2SessionManager.request(WordPressComURL.oAuthBase.url(base: wordPressComApiBaseUrl), method: .post, parameters: parameters)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let responseObject):
                    WPKitLogVerbose("Received OAuth2 response: \(self.cleanedUpResponseForLogging(responseObject as AnyObject? ?? "nil" as AnyObject))")

                    let defaultError = NSError(domain: WordPressComOAuthClient.WordPressComOAuthErrorDomain,
                                               code: WordPressComOAuthError.unknown.rawValue,
                                               userInfo: nil)

                    guard let responseDictionary = responseObject as? [String: AnyObject] else {
                        return failure(defaultError)
                    }

                    // If we found an access_token, we are authed.
                    if let authToken = responseDictionary["access_token"] as? String {
                        return success(authToken)
                    }

                    // If there is no access token, check for a security key nonce
                    guard let responseData = responseDictionary["data"] as? [String: AnyObject],
                          let userID = responseData["user_id"] as? Int,
                          let _ = responseData["two_step_nonce_webauthn"] else {
                        failure(defaultError)
                        return
                    }

                    let nonceInfo = self.extractNonceInfo(data: responseData)
                    needsMultifactor(userID, nonceInfo)

                case .failure(let error):
                    let nserror = self.processError(response: response, originalError: error)
                    WPKitLogError("Error receiving OAuth2 token: \(nserror)")
                    failure(nserror)
                }
            })
    }

    /// Requests a One Time Code, to be sent via SMS.
    ///
    /// - Parameters:
    ///     - username: the account's username.
    ///     - password: the account's password.
    ///     - success: block to be called if authentication was successful.
    ///     - failure: block to be called if authentication failed. The error object is passed as a parameter.
    ///
    @objc public func requestOneTimeCodeWithUsername(_ username: String, password: String,
                                        success: @escaping () -> Void, failure: @escaping (_ error: NSError) -> Void) {
        let parameters = [
            "username": username,
            "password": password,
            "grant_type": "password",
            "client_id": clientID,
            "client_secret": secret,
            "wpcom_supports_2fa": true,
            "wpcom_resend_otp": true
        ] as [String: Any]

        oauth2SessionManager.request(WordPressComURL.oAuthBase.url(base: wordPressComApiBaseUrl), method: .post, parameters: parameters)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    success()
                case .failure(let error):
                    let nserror = self.processError(response: response, originalError: error)
                    failure(nserror)
                }
            }
        )
    }

    /// Request a new SMS code to be sent during social login
    ///
    /// - Parameters:
    ///     - userID: The wpcom user id.
    ///     - nonce: The nonce from a social login attempt.
    ///     - success: block to be called if authentication was successful.
    ///     - failure: block to be called if authentication failed. The error object is passed as a parameter.
    ///
    @objc public func requestSocial2FACodeWithUserID(_ userID: Int,
                                                     nonce: String,
                                                     success: @escaping (_ newNonce: String) -> Void,
                                                     failure: @escaping (_ error: NSError, _ newNonce: String?) -> Void) {
        let parameters = [
            "user_id": userID,
            "two_step_nonce": nonce,
            "client_id": clientID,
            "client_secret": secret,
            "wpcom_supports_2fa": true,
            "wpcom_resend_otp": true
            ] as [String: Any]

        socialNewSMS2FASessionManager.request(WordPressComURL.socialLoginNewSMS2FA.url(base: wordPressComBaseUrl), method: .post, parameters: parameters)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let responseObject):
                    let defaultError = NSError(domain: WordPressComOAuthClient.WordPressComOAuthErrorDomain,
                                               code: WordPressComOAuthError.unknown.rawValue,
                                               userInfo: nil)

                    guard let responseDictionary = responseObject as? [String: AnyObject],
                        let responseData = responseDictionary["data"] as? [String: AnyObject] else {
                            failure(defaultError, nil)
                            return
                    }

                    let nonceInfo = self.extractNonceInfo(data: responseData)

                    success(nonceInfo.nonceSMS)
                case .failure(let error):
                    let nserror = self.processError(response: response, originalError: error)
                    if let newNonce = nserror.userInfo[WordPressComOAuthClient.WordPressComOAuthErrorNewNonceKey] as? String {
                        failure(nserror, newNonce)
                    } else {
                        failure(nserror, nil)
                    }
                }
            })
    }

    /// Authenticate on WordPress.com with a social service's ID token.
    ///
    /// - Parameters:
    ///     - token: A social ID token obtained from a supported social service.
    ///     - service: The social service type (ex: "google" or "apple").
    ///     - success: block to be called if authentication was successful. The OAuth2 token is passed as a parameter.
    ///     - needsMultifactor: block to be called if a 2fa token is needed to complete the auth process.
    ///     - failure: block to be called if authentication failed. The error object is passed as a parameter.
    ///
    @objc public func authenticateWithIDToken(_ token: String,
                                              service: String,
                                              success: @escaping (_ authToken: String?) -> Void,
                                              needsMultifactor: @escaping (_ userID: Int, _ nonceInfo: SocialLogin2FANonceInfo) -> Void,
                                              existingUserNeedsConnection: @escaping (_ email: String) -> Void,
                                              failure: @escaping (_ error: NSError) -> Void ) {
        let parameters = [
            "client_id": clientID,
            "client_secret": secret,
            "service": service,
            "get_bearer_token": true,
            "id_token": token
            ] as [String: Any]

        // Passes an empty string for the path. The session manager was composed with the full endpoint path.
        socialSessionManager.request(WordPressComURL.socialLogin.url(base: wordPressComBaseUrl), method: .post, parameters: parameters)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let responseObject):
                    WPKitLogVerbose("Received Social Login Oauth response.")

                    let defaultError = NSError(domain: WordPressComOAuthClient.WordPressComOAuthErrorDomain,
                                               code: WordPressComOAuthError.unknown.rawValue,
                                               userInfo: nil)

                    // Make sure we received expected data.
                    guard let responseDictionary = responseObject as? [String: AnyObject],
                        let responseData = responseDictionary["data"] as? [String: AnyObject] else {
                            failure(defaultError)
                            return
                    }

                    // Check for a bearer token. If one is found then we're authed.
                    if let authToken = responseData["bearer_token"] as? String {
                        success(authToken)
                        return
                    }

                    // If there is no bearer token, check for 2fa enabled.
                    guard let userID = responseData["user_id"] as? Int,
                        let _ = responseData["two_step_nonce_backup"] else {
                            failure(defaultError)
                            return
                    }

                    let nonceInfo = self.extractNonceInfo(data: responseData)
                    needsMultifactor(userID, nonceInfo)
                case .failure(let error):
                    let err = self.processError(response: response, originalError: error)

                    // Inspect the error and handle the case of an existing user.
                    if err.code == WordPressComOAuthError.socialLoginExistingUserUnconnected.rawValue &&
                        err.domain == WordPressComOAuthClient.WordPressComOAuthErrorDomain {
                        // Get the responseObject from the userInfo dict.
                        // Extract the email address for the callback.
                        if let responseDict = err.userInfo[WordPressComOAuthClient.WordPressComOAuthErrorResponseObjectKey] as? [String: AnyObject],
                            let data = responseDict["data"] as? [String: AnyObject],
                            let email = data["email"] as? String {

                            existingUserNeedsConnection(email)
                            return
                        }
                    }
                    failure(err)
                }
            }
        )
    }

    /// Request a security key challenge from WordPress.com to be signed by the client.
    ///
    /// - Parameters:
    ///     - userID: the wpcom userID
    ///     - twoStepNonce: The nonce returned from a log in attempt.
    ///     - success: block to be called if authentication was successful. The challenge info is passed as a parameter.
    ///     - failure: block to be called if authentication failed. The error object is passed as a parameter.
    ///
    @objc public func requestWebauthnChallenge(userID: Int64,
                                               twoStepNonce: String,
                                               success: @escaping (_ challengeData: WebauthnChallengeInfo) -> Void,
                                               failure: @escaping (_ error: NSError) -> Void ) {

        var parameters: [String: Any] = [
            "user_id": userID,
            "client_id": clientID,
            "client_secret": secret,
            "auth_type": "webauthn",
            "two_step_nonce": twoStepNonce,
        ]

        webauthnSessionManager.request(WordPressComURL.webauthnChallenge.url(base: wordPressComBaseUrl), method: .post, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let responseObject):

                    let defaultError = NSError(domain: WordPressComOAuthClient.WordPressComOAuthErrorDomain,
                                               code: WordPressComOAuthError.unknown.rawValue,
                                               userInfo: nil)

                    // Expect the parent data response object
                    guard let responseDictionary = responseObject as? [String: Any],
                          let responseData = responseDictionary["data"] as? [String: Any] else {
                        return failure(defaultError)
                    }

                    // Expect the challenge info.
                    guard
                        let challenge = responseData["challenge"] as? String,
                        let nonce = responseData["two_step_nonce"] as? String,
                        let rpID = responseData["rpId"] as? String
                    else {
                        return failure(defaultError)
                    }

                    let challengeData = WebauthnChallengeInfo(challenge: challenge, rpID: rpID, twoStepNonce: nonce)
                    success(challengeData)

                case .failure(let error):
                    let nserror = self.processError(response: response, originalError: error)
                    WPKitLogError("Error with WebAuthn challenge: \(nserror)")
                    failure(nserror)
                }
            }
    }

    /// Verifies a signed challenge with a security key on WordPress.com.
    ///
    /// - Parameters:
    ///     - userID: the wpcom userID
    ///     - twoStepNonce: The nonce returned from a  request challenge attempt.
    ///     - credentialID: The id of the security key that signed the challenge.
    ///     - clientDataJson: Json returned by the passkey framework.
    ///     - authenticatorData: Authenticator Data from the security key.
    ///     - signature: Signature to verify.
    ///     - userHandle: User associated with the security key.
    ///     - success: block to be called if authentication was successful. The auth token is passed as a parameter.
    ///     - failure: block to be called if authentication failed. The error object is passed as a parameter.
    ///
    @objc public func authenticateWebauthnSignature(userId: Int64,
                                                    twoStepNonce: String,
                                                    credentialID: Data,
                                                    clientDataJson: Data,
                                                    authenticatorData: Data,
                                                    signature: Data,
                                                    userHandle: Data,
                                                    success: @escaping (_ authToken: String) -> Void,
                                                    failure: @escaping (_ error: NSError) -> Void ) {

        let clientData: [String: AnyHashable] = [
            "id": credentialID.base64EncodedString(),
            "rawId": credentialID.base64EncodedString(),
            "type": "public-key",
            "clientExtensionResults": Dictionary<String, String>(),
            "response": [
                "clientDataJSON": clientDataJson.base64EncodedString(),
                "authenticatorData": authenticatorData.base64EncodedString(),
                "signature": signature.base64EncodedString(),
                "userHandle": userHandle.base64EncodedString(),
            ]
        ]


        let defaultError = NSError(domain: WordPressComOAuthClient.WordPressComOAuthErrorDomain,
                                   code: WordPressComOAuthError.unknown.rawValue,
                                   userInfo: nil)

        guard let serializedClientData = try? JSONSerialization.data(withJSONObject: clientData, options: .withoutEscapingSlashes),
              let clientDataString = String(data: serializedClientData, encoding: .utf8) else {
                  return failure(defaultError)
              }

        let parameters: [String: Any] = [
            "user_id": userId,
            "client_id": clientID,
            "client_secret": secret,
            "auth_type": "webauthn",
            "two_step_nonce": twoStepNonce,
            "client_data": clientDataString,
            "get_bearer_token": true,
            "create_2fa_cookies_only" : true
        ]

        webauthnSessionManager.request(WordPressComURL.webauthnAuthentication.url(base: wordPressComBaseUrl), method: .post, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let responseObject):

                    guard let responseDictionary = responseObject as? [String: Any],
                          let successResponse = responseDictionary["success"] as? Bool, successResponse,
                          let responseData = responseDictionary["data"] as? [String: Any] else {
                        return failure(defaultError)
                    }

                    // Check for a bearer token. If one is found then we're authed.
                    guard let authToken = responseData["bearer_token"] as? String else {
                        return failure(defaultError)
                    }

                    return success(authToken)

                case .failure(let error):
                    let nserror = self.processError(response: response, originalError: error)
                    WPKitLogError("Error with WebAuthn authentication: \(nserror)")
                    failure(nserror)
                }
            }
    }

    /// A helper method to get an instance of SocialLogin2FANonceInfo and populate 
    /// it with the supplied data.
    ///
    /// - Parameters:
    ///     - data: The dictionary to use to populate the instance.
    ///
    /// - Return: SocialLogin2FANonceInfo
    ///
    private func extractNonceInfo(data: [String: AnyObject]) -> SocialLogin2FANonceInfo {
        let nonceInfo = SocialLogin2FANonceInfo()

        if let nonceAuthenticator = data["two_step_nonce_authenticator"] as? String {
            nonceInfo.nonceAuthenticator = nonceAuthenticator
        }

        // atm, used for requesting and verifying a security key.
        if let nonceWebauthn = data["two_step_nonce_webauthn"] as? String {
            nonceInfo.nonceWebauthn = nonceWebauthn
        }

        // atm, the only use of the more vague "two_step_nonce" key is when requesting a new SMS code
        if let nonce = data["two_step_nonce"] as? String {
            nonceInfo.nonceSMS = nonce
        }

        if let nonce = data["two_step_nonce_sms"] as? String {
            nonceInfo.nonceSMS = nonce
        }

        if let nonce = data["two_step_nonce_backup"] as? String {
            nonceInfo.nonceBackup = nonce
        }

        if let notification = data["two_step_notification_sent"] as? String {
            nonceInfo.notificationSent = notification
        }

        if let authTypes = data["two_step_supported_auth_types"] as? [String] {
            nonceInfo.supportedAuthTypes = authTypes
        }

        if let phone = data["phone_number"] as? String {
            nonceInfo.phoneNumber = phone
        }

        return nonceInfo
    }

    /// Completes a social login that has 2fa enabled.
    ///
    /// - Parameters:
    ///     - userID: The wpcom user id.
    ///     - authType: The type of 2fa authentication being used. (sms|backup|authenticator)
    ///     - twoStepCode: The user's 2fa code.
    ///     - twoStepNonce: The nonce returned from a social login attempt.
    ///     - success: block to be called if authentication was successful. The OAuth2 token is passed as a parameter.
    ///     - failure: block to be called if authentication failed. The error object is passed as a parameter.
    ///
    @objc public func authenticateSocialLoginUser(_ userID: Int,
                                            authType: String,
                                            twoStepCode: String,
                                            twoStepNonce: String,
                                            success: @escaping (_ authToken: String?) -> Void,
                                            failure: @escaping (_ error: NSError) -> Void ) {
        let parameters = [
            "user_id": userID,
            "auth_type": authType,
            "two_step_code": twoStepCode,
            "two_step_nonce": twoStepNonce,
            "get_bearer_token": true,
            "client_id": clientID,
            "client_secret": secret
            ] as [String: Any]

        // Passes an empty string for the path. The session manager was composed with the full endpoint path.
        social2FASessionManager.request(WordPressComURL.socialLogin2FA.url(base: wordPressComBaseUrl), method: .post, parameters: parameters)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let responseObject):
                    WPKitLogVerbose("Received Social Login Oauth response: \(self.cleanedUpResponseForLogging(responseObject as AnyObject? ?? "nil" as AnyObject))")
                    guard let responseDictionary = responseObject as? [String: AnyObject],
                        let responseData = responseDictionary["data"] as? [String: AnyObject],
                        let authToken = responseData["bearer_token"] as? String else {
                            failure(NSError(domain: WordPressComOAuthClient.WordPressComOAuthErrorDomain,
                                            code: WordPressComOAuthError.unknown.rawValue,
                                            userInfo: nil))
                            return
                    }

                    success(authToken)

                case .failure(let error):
                    let nserror = self.processError(response: response, originalError: error)
                    failure(nserror)
                }
            })
    }

    private func cleanedUpResponseForLogging(_ response: AnyObject) -> AnyObject {
        guard var responseDictionary = response as? [String: AnyObject] else {
                return response
        }

        // If the response is wrapped in a "data" field, clean up tokens inside it.
        if var dataDictionary = responseDictionary["data"] as? [String: AnyObject] {
            let keys = ["access_token", "bearer_token", "token_links"]
            for key in keys {
                if dataDictionary[key] != nil {
                    dataDictionary[key] = "*** REDACTED ***" as AnyObject?
                }
            }

            responseDictionary.updateValue(dataDictionary as AnyObject, forKey: "data")

            return responseDictionary as AnyObject
        }

        let keys = ["access_token", "bearer_token"]
        for key in keys {
            if responseDictionary[key] != nil {
                responseDictionary[key] = "*** REDACTED ***" as AnyObject?
            }
        }

        return responseDictionary as AnyObject
    }

}

/// Extra error handling for standard 400 error responses coming from the OAUTH server
///
extension WordPressComOAuthClient {

    /// Possible 400 errors:
    ///     - invalid_client: client_id is missing or wrong, it shouldn't happen
    ///     - unsupported_grant_type: client_id doesn't support password grants
    ///     - invalid_request: A required field is missing/malformed
    ///     - invalid_request: Authentication failed
    ///     - needs_2fa: Multifactor Authentication code is required
    ///     - user_exists: Returned by the social login endpoint if a wpcom user is found, but not connected to a social service.
    ///
    static let errorsMap = [
        "invalid_client": WordPressComOAuthError.invalidClient,
        "unsupported_grant_type": WordPressComOAuthError.unsupportedGrantType,
        "invalid_request": WordPressComOAuthError.invalidRequest,
        "needs_2fa": WordPressComOAuthError.needsMultifactorCode,
        "invalid_otp": WordPressComOAuthError.invalidOneTimePassword,
        "user_exists": WordPressComOAuthError.socialLoginExistingUserUnconnected,
        "invalid_two_step_code": WordPressComOAuthError.invalidTwoStepCode,
        "unknown_user": WordPressComOAuthError.unknownUser
    ]

    /// A error processor to handle error responses when status codes are betwen 400 and 500.
    /// Some HTTP requests include a response body even in a failure scenario. This method ensures
    /// it is available via an error's userInfo dictionary.
    func processError(response: DataResponse<Any>, originalError: Error) -> NSError {
        let originalNSError = originalError as NSError
        guard let afError = originalError as?  AFError,
            case AFError.responseValidationFailed(_) = afError,
            let httpResponse = response.response, (400...500).contains(httpResponse.statusCode),
            let data = response.data,
            let responseObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let responseDictionary = responseObject as? [String: AnyObject]
        else {
            return originalNSError
        }

        if [400, 409, 403].contains(httpResponse.statusCode) {
            return parseError(from: responseDictionary)
        }

        return originalNSError
    }

    /// Create the NSError from the response dictionary
    private func parseError(from responseDict: [String: AnyObject]) -> NSError {
        var errorCode = ""
        var errorDescription = ""
        var newNonce: String?

        // there's either a data object, or an error.
        if  let errorStr = responseDict["error"] as? String {
            errorCode = errorStr
            errorDescription = responseDict["error_description"] as? String ?? ""
        } else if let data = responseDict["data"] as? [String: AnyObject],
            let errors = data["errors"] as? NSArray,
            let err = errors.firstObject as? [String: AnyObject] {
            errorCode = err["code"] as? String ?? ""
            errorDescription = err["message"] as? String ?? ""
            newNonce = data["two_step_nonce"] as? String
        }

        return errorFor(errorCode: errorCode, errorDescription: errorDescription, responseObject: responseDict, newNonce: newNonce)
    }

    /// Creates an NSError from the supplied arguements. The response object is
    /// added to the error's userInfo dictionary.
    ///
    /// - Parameters:
    ///   - errorCode: A string representing the error code. This is not the same as an HTTP status code.
    ///   - errorDescription: A description of the error.
    ///   - responseObject: The responseObject (if any) that was passed with the error.
    ///   - newNonce: *optional* The new nonce provided when a 2FA fails
    /// - Returns: An NSError.
    @objc func errorFor(errorCode: String, errorDescription: String, responseObject: Any?, newNonce: String? = nil) -> NSError {
        var userInfo: [String: AnyObject] = [NSLocalizedDescriptionKey: errorDescription as AnyObject]
        if let responseObject = responseObject {
            userInfo[WordPressComOAuthClient.WordPressComOAuthErrorResponseObjectKey] = responseObject as AnyObject
        }
        if let newNonce = newNonce {
            userInfo[WordPressComOAuthClient.WordPressComOAuthErrorNewNonceKey] = newNonce as AnyObject
        }
        let mappedCode = WordPressComOAuthClient.errorsMap[errorCode]?.rawValue ?? WordPressComOAuthError.unknown.rawValue
        return NSError(domain: WordPressComOAuthClient.WordPressComOAuthErrorDomain,
                       code: mappedCode,
                       userInfo: userInfo)
    }
}
