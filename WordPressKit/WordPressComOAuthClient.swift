import Alamofire

public typealias WordPressComOAuthError = WordPressAPIError<AuthenticationFailure>

public extension WordPressComOAuthError {
    var authenticationFailureKind: AuthenticationFailure.Kind? {
        if case let .endpointError(failure) = self {
            return failure.kind
        }
        return nil
    }
}

public struct AuthenticationFailure: LocalizedError {
    private static let errorsMap: [String: AuthenticationFailure.Kind] = [
        "invalid_client": .invalidClient,
        "unsupported_grant_type": .unsupportedGrantType,
        "invalid_request": .invalidRequest,
        "needs_2fa": .needsMultifactorCode,
        "invalid_otp": .invalidOneTimePassword,
        "user_exists": .socialLoginExistingUserUnconnected,
        "invalid_two_step_code": .invalidTwoStepCode,
        "unknown_user": .unknownUser
    ]

    public enum Kind {
        /// client_id is missing or wrong, it shouldn't happen
        case invalidClient
        /// client_id doesn't support password grants
        case unsupportedGrantType
        /// A required field is missing/malformed
        case invalidRequest
        /// Multifactor Authentication code is required
        case needsMultifactorCode
        /// Supplied one time password is incorrect
        case invalidOneTimePassword
        /// Returned by the social login endpoint if a wpcom user is found, but not connected to a social service.
        case socialLoginExistingUserUnconnected
        /// Supplied MFA code is incorrect
        case invalidTwoStepCode
        case unknownUser
        case unknown
    }

    public var kind: Kind
    public var localizedErrorMessage: String?
    public var newNonce: String?
    public var originalErrorJSON: [String: AnyObject]

    init(apiJSONResponse responseDict: [String: AnyObject]) {
        originalErrorJSON = responseDict

        // there's either a data object, or an error.
        if let errorStr = responseDict["error"] as? String {
            kind = Self.errorsMap[errorStr] ?? .unknown
            localizedErrorMessage = responseDict["error_description"] as? String
        } else if let data = responseDict["data"] as? [String: AnyObject],
            let errors = data["errors"] as? NSArray,
            let err = errors.firstObject as? [String: AnyObject] {
            let errorCode = err["code"] as? String ?? ""
            kind = Self.errorsMap[errorCode] ?? .unknown
            localizedErrorMessage = err["message"] as? String
            newNonce = data["two_step_nonce"] as? String
        } else {
            kind = .unknown
        }
    }
}

/// `WordPressComOAuthClient` encapsulates the pattern of authenticating against WordPress.com OAuth2 service.
///
/// Right now it requires a special client id and secret, so this probably won't work for you
/// @see https://developer.wordpress.com/docs/oauth2/
///
public final class WordPressComOAuthClient: NSObject {

    @objc public static let WordPressComOAuthDefaultBaseUrl = "https://wordpress.com"
    @objc public static let WordPressComOAuthDefaultApiBaseUrl = "https://public-api.wordpress.com"

    enum WordPressComURL: String {
        case oAuthBase = "/oauth2/token"
        case webauthnChallenge = "wp-login.php?action=webauthn-challenge-endpoint"
        case webauthnAuthentication = "wp-login.php?action=webauthn-authentication-endpoint"
        case socialLogin2FA = "/wp-login.php?action=two-step-authentication-endpoint&version=1.0"

        func url(base: URL) -> URL {
            return URL(string: self.rawValue, relativeTo: base)!
        }

        func url(base: String) -> URL {
            return URL(string: self.rawValue, relativeTo: URL(string: base))!
        }
    }

    @objc public static let WordPressComSocialLoginEndpointVersion = 1.0

    private let clientID: String
    private let secret: String

    private let wordPressComBaseUrl: URL
    private let wordPressComApiBaseUrl: URL

    private let urlSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = ["Accept": "application/json"]
        return URLSession(configuration: configuration)
    }()

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
        self.wordPressComBaseUrl = URL(string: wordPressComBaseUrl)!
        self.wordPressComApiBaseUrl = URL(string: wordPressComApiBaseUrl)!
    }

    public enum AuthenticationResult {
        case authenticated(token: String)
        case needsMultiFactor(userID: Int, nonceInfo: SocialLogin2FANonceInfo)
    }

    /// Authenticates on WordPress.com using the OAuth endpoints.
    ///
    /// - Parameters:
    ///     - username: the account's username.
    ///     - password: the account's password.
    ///     - multifactorCode: Multifactor Authentication One-Time-Password. If not needed, can be nil
    public func authenticate(
        username: String,
        password: String,
        multifactorCode: String?
    ) async -> WordPressAPIResult<AuthenticationResult, AuthenticationFailure> {
        var form = [
            "username": username,
            "password": password,
            "grant_type": "password",
            "client_id": clientID,
            "client_secret": secret,
            "wpcom_supports_2fa": "true",
            "with_auth_types": "true"
        ]

        if let multifactorCode, !multifactorCode.isEmpty {
            form["wpcom_otp"] = multifactorCode
        }

        let builder = HTTPRequestBuilder(url: wordPressComApiBaseUrl)
            .set(method: "POST")
            .set(path: "/oauth2/token")
            .body(form: form)
        return await urlSession
            .apiResult(with: builder)
            .assessStatusCode(
                success: { response in
                    guard let responseObject = try? JSONSerialization.jsonObject(with: response.body) else {
                        return nil
                    }

                    WPKitLogVerbose("Received OAuth2 response: \(self.cleanedUpResponseForLogging(responseObject as AnyObject? ?? "nil" as AnyObject))")

                    guard let responseDictionary = responseObject as? [String: AnyObject] else {
                        return nil
                    }

                    // If we found an access_token, we are authed.
                    if let authToken = responseDictionary["access_token"] as? String {
                        return .authenticated(token: authToken)
                    }

                    // If there is no access token, check for a security key nonce
                    guard let responseData = responseDictionary["data"] as? [String: AnyObject],
                          let userID = responseData["user_id"] as? Int,
                          let _ = responseData["two_step_nonce_webauthn"] else {
                        return nil
                    }

                    let nonceInfo = Self.extractNonceInfo(data: responseData)

                    return .needsMultiFactor(userID: userID, nonceInfo: nonceInfo)
                },
                failure: Self.processError(_:)
            )
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
    public func authenticate(
        username: String,
        password: String,
        multifactorCode: String?,
        needsMultifactor: @escaping ((_ userID: Int, _ nonceInfo: SocialLogin2FANonceInfo) -> Void),
        success: @escaping (_ authToken: String?) -> Void,
        failure: @escaping (_ error: WordPressComOAuthError) -> Void
    ) {
        Task { @MainActor in
            let result = await authenticate(username: username, password: password, multifactorCode: multifactorCode)
            switch result {
            case let .success(.authenticated(token)):
                success(token)
            case let .success(.needsMultiFactor(userID, nonceInfo)):
                needsMultifactor(userID, nonceInfo)
            case let .failure(error):
                failure(error)
            }
        }
    }

    /// Requests a One Time Code, to be sent via SMS.
    ///
    /// - Parameters:
    ///     - username: the account's username.
    ///     - password: the account's password.
    ///     - success: block to be called if authentication was successful.
    ///     - failure: block to be called if authentication failed. The error object is passed as a parameter.
    public func requestOneTimeCode(username: String, password: String) async -> WordPressAPIResult<Void, AuthenticationFailure> {
        let builder = HTTPRequestBuilder(url: wordPressComApiBaseUrl)
            .set(method: "POST")
            .set(path: "/oauth2/token")
            .body(form: [
                "username": username,
                "password": password,
                "grant_type": "password",
                "client_id": clientID,
                "client_secret": secret,
                "wpcom_supports_2fa": "true",
                "wpcom_resend_otp": "true"
            ])
        return await urlSession
            .apiResult(with: builder)
            .assessStatusCode(success: { _ in () }, failure: Self.processError(_:))
    }

    /// Requests a One Time Code, to be sent via SMS.
    ///
    /// - Parameters:
    ///     - username: the account's username.
    ///     - password: the account's password.
    ///     - success: block to be called if authentication was successful.
    ///     - failure: block to be called if authentication failed. The error object is passed as a parameter.
    public func requestOneTimeCode(
        username: String,
        password: String,
        success: @escaping () -> Void,
        failure: @escaping (_ error: WordPressComOAuthError) -> Void
    ) {
        Task { @MainActor in
            let result = await requestOneTimeCode(username: username, password: password)
            switch result {
            case .success:
                success()
            case let .failure(error):
                failure(error)
            }
        }
    }

    /// Request a new SMS code to be sent during social login
    ///
    /// - Parameters:
    ///     - userID: The wpcom user id.
    ///     - nonce: The nonce from a social login attempt.
    public func requestSocial2FACode(
        userID: Int,
        nonce: String
    ) async -> WordPressAPIResult<String, AuthenticationFailure> {
        let builder = HTTPRequestBuilder(url: wordPressComBaseUrl)
            .set(method: "POST")
            .set(path: "/wp-login.php")
            .query(name: "action", value: "send-sms-code-endpoint")
            .body(
                form: [
                    "user_id": "\(userID)",
                    "two_step_nonce": nonce,
                    "client_id": clientID,
                    "client_secret": secret,
                    "wpcom_supports_2fa": "true",
                    "wpcom_resend_otp": "true"
                ]
            )

        return await urlSession
            .apiResult(with: builder, errorType: AuthenticationFailure.self)
            .assessStatusCode(
                success: { response -> String? in
                    guard let responseObject = try? JSONSerialization.jsonObject(with: response.body),
                          let responseDictionary = responseObject as? [String: AnyObject],
                        let responseData = responseDictionary["data"] as? [String: AnyObject] else {
                        return nil
                    }

                    return Self.extractNonceInfo(data: responseData).nonceSMS
                },
                failure: Self.processError(_:)
            )
            .flatMapError { error in
                if case let .endpointError(authenticationFailure) = error, let newNonce = authenticationFailure.newNonce {
                    return .success(newNonce)
                }
                return .failure(error)
            }
    }

    /// Request a new SMS code to be sent during social login
    ///
    /// - Parameters:
    ///     - userID: The wpcom user id.
    ///     - nonce: The nonce from a social login attempt.
    ///     - success: block to be called if authentication was successful.
    ///     - failure: block to be called if authentication failed. The error object is passed as a parameter.
    public func requestSocial2FACode(
        userID: Int,
        nonce: String,
        success: @escaping (_ newNonce: String) -> Void,
        failure: @escaping (_ error: WordPressComOAuthError, _ newNonce: String?) -> Void
    ) {
        Task { @MainActor in
            let result = await requestSocial2FACode(userID: userID, nonce: nonce)
            switch result {
            case let .success(newNonce):
                success(newNonce)
            case let .failure(error):
                // TODO: Remove the `newNonce` argument?
                failure(error, nil)
            }
        }
    }

    public enum SocialAuthenticationResult {
        case authenticated(token: String)
        case needsMultiFactor(userID: Int, nonceInfo: SocialLogin2FANonceInfo)
        case existingUserNeedsConnection(email: String)
    }

    /// Authenticate on WordPress.com with a social service's ID token.
    ///
    /// - Parameters:
    ///     - token: A social ID token obtained from a supported social service.
    ///     - service: The social service type (ex: "google" or "apple").
    public func authenticate(
        socialIDToken token: String,
        service: String
    ) async -> WordPressAPIResult<SocialAuthenticationResult, AuthenticationFailure> {
        let builder = HTTPRequestBuilder(url: wordPressComBaseUrl)
            .set(method: "POST")
            .set(path: "/wp-login.php")
            .query(name: "action", value: "social-login-endpoint")
            .query(name: "version", value: "1.0")
            .body(
                form: [
                    "client_id": clientID,
                    "client_secret": secret,
                    "service": service,
                    "get_bearer_token": "true",
                    "id_token": token
                ]
            )

        return await urlSession
            .apiResult(with: builder, errorType: AuthenticationFailure.self)
            .assessStatusCode(
                success: { response in
                    WPKitLogVerbose("Received Social Login Oauth response.")

                    // Make sure we received expected data.
                    guard let responseObject = try? JSONSerialization.jsonObject(with: response.body),
                        let responseDictionary = responseObject as? [String: AnyObject],
                        let responseData = responseDictionary["data"] as? [String: AnyObject] else {
                        return nil
                    }

                    // Check for a bearer token. If one is found then we're authed.
                    if let authToken = responseData["bearer_token"] as? String {
                        return .authenticated(token: authToken)
                    }

                    // If there is no bearer token, check for 2fa enabled.
                    guard let userID = responseData["user_id"] as? Int,
                        let _ = responseData["two_step_nonce_backup"] else {
                        return nil
                    }

                    let nonceInfo = Self.extractNonceInfo(data: responseData)
                    return .needsMultiFactor(userID: userID, nonceInfo: nonceInfo)
                },
                failure: Self.processError(_:)
            )
            .flatMapError { error in
                // Inspect the error and handle the case of an existing user.
                if case let .endpointError(authenticationFailure) = error, authenticationFailure.kind == .socialLoginExistingUserUnconnected {
                    // Get the responseObject from the userInfo dict.
                    // Extract the email address for the callback.
                    let responseDict = authenticationFailure.originalErrorJSON
                    if let data = responseDict["data"] as? [String: AnyObject],
                        let email = data["email"] as? String {
                        return .success(.existingUserNeedsConnection(email: email))
                    }
                }
                return .failure(error)
            }
    }

    /// Authenticate on WordPress.com with a social service's ID token.
    ///
    /// - Parameters:
    ///     - token: A social ID token obtained from a supported social service.
    ///     - service: The social service type (ex: "google" or "apple").
    ///     - success: block to be called if authentication was successful. The OAuth2 token is passed as a parameter.
    ///     - needsMultifactor: block to be called if a 2fa token is needed to complete the auth process.
    ///     - failure: block to be called if authentication failed. The error object is passed as a parameter.
    public func authenticate(
        socialIDToken token: String,
        service: String,
        success: @escaping (_ authToken: String?) -> Void,
        needsMultifactor: @escaping (_ userID: Int, _ nonceInfo: SocialLogin2FANonceInfo) -> Void,
        existingUserNeedsConnection: @escaping (_ email: String) -> Void,
        failure: @escaping (_ error: WordPressComOAuthError) -> Void
    ) {
        Task { @MainActor in
            let result = await self.authenticate(socialIDToken: token, service: service)
            switch result {
            case let .success(.authenticated(token)):
                success(token)
            case let .success(.needsMultiFactor(userID, nonceInfo)):
                needsMultifactor(userID, nonceInfo)
            case let .success(.existingUserNeedsConnection(email)):
                existingUserNeedsConnection(email)
            case let .failure(error):
                failure(error)
            }
        }
    }

    /// Request a security key challenge from WordPress.com to be signed by the client.
    ///
    /// - Parameters:
    ///     - userID: the wpcom userID
    ///     - twoStepNonce: The nonce returned from a log in attempt.
    public func requestWebauthnChallenge(
        userID: Int64,
        twoStepNonce: String
    ) async -> WordPressAPIResult<WebauthnChallengeInfo, AuthenticationFailure> {
        let builder = HTTPRequestBuilder(url: wordPressComBaseUrl)
            .set(path: "/wp-login.php")
            .query(name: "action", value: "webauthn-challenge-endpoint")
            .set(method: "POST")
            .body(form: [
                "user_id": "\(userID)",
                "client_id": clientID,
                "client_secret": secret,
                "auth_type": "webauthn",
                "two_step_nonce": twoStepNonce,
            ])
        return await urlSession
            .apiResult(with: builder)
            .assessStatusCode(
                success: { response in
                    // Expect the parent data response object
                    guard let responseObject = try? JSONSerialization.jsonObject(with: response.body),
                          let responseDictionary = responseObject as? [String: Any],
                          let responseData = responseDictionary["data"] as? [String: Any] else {
                        return nil
                    }

                    // Expect the challenge info.
                    guard
                        let challenge = responseData["challenge"] as? String,
                        let nonce = responseData["two_step_nonce"] as? String,
                        let rpID = responseData["rpId"] as? String,
                        let allowCredentials = responseData["allowCredentials"] as? [[String: Any]]
                    else {
                        return nil
                    }

                    let allowedCredentialIDs = allowCredentials.compactMap { $0["id"] as? String }
                    return WebauthnChallengeInfo(challenge: challenge, rpID: rpID, twoStepNonce: nonce, allowedCredentialIDs: allowedCredentialIDs)
                },
                failure: Self.processError(_:)
            )
    }

    /// Request a security key challenge from WordPress.com to be signed by the client.
    ///
    /// - Parameters:
    ///     - userID: the wpcom userID
    ///     - twoStepNonce: The nonce returned from a log in attempt.
    ///     - success: block to be called if authentication was successful. The challenge info is passed as a parameter.
    ///     - failure: block to be called if authentication failed. The error object is passed as a parameter.
    public func requestWebauthnChallenge(
        userID: Int64,
        twoStepNonce: String,
        success: @escaping (_ challengeData: WebauthnChallengeInfo) -> Void,
        failure: @escaping (_ error: WordPressComOAuthError) -> Void
    ) {
        Task { @MainActor in
            let result = await requestWebauthnChallenge(userID: userID, twoStepNonce: twoStepNonce)
            switch result {
            case let .success(data):
                success(data)
            case let .failure(error):
                failure(error)
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
    public func authenticateWebauthnSignature(
        userID: Int64,
        twoStepNonce: String,
        credentialID: Data,
        clientDataJson: Data,
        authenticatorData: Data,
        signature: Data,
        userHandle: Data
    ) async -> WordPressAPIResult<String, AuthenticationFailure> {
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

        guard let serializedClientData = try? JSONSerialization.data(withJSONObject: clientData, options: .withoutEscapingSlashes),
              let clientDataString = String(data: serializedClientData, encoding: .utf8) else {
            return .failure(.requestEncodingFailure)
        }

        let builder = HTTPRequestBuilder(url: wordPressComBaseUrl)
            .set(method: "POST")
            .set(path: "/wp-login.php")
            .query(name: "action", value: "webauthn-authentication-endpoint")
            .body(form: [
                "user_id": "\(userID)",
                "client_id": clientID,
                "client_secret": secret,
                "auth_type": "webauthn",
                "two_step_nonce": twoStepNonce,
                "client_data": clientDataString,
                "get_bearer_token": "true",
                "create_2fa_cookies_only": "true",
            ])

        return await urlSession
            .apiResult(with: builder)
            .assessStatusCode(
                success: { response in
                    guard let responseObject = try? JSONSerialization.jsonObject(with: response.body),
                          let responseDictionary = responseObject as? [String: Any],
                          let successResponse = responseDictionary["success"] as? Bool, successResponse,
                          let responseData = responseDictionary["data"] as? [String: Any] else {
                        return nil
                    }

                    // Check for a bearer token. If one is found then we're authed.
                    guard let authToken = responseData["bearer_token"] as? String else {
                        return nil
                    }

                    return authToken
                },
                failure: Self.processError(_:)
            )
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
    public func authenticateWebauthnSignature(
        userID: Int64,
        twoStepNonce: String,
        credentialID: Data,
        clientDataJson: Data,
        authenticatorData: Data,
        signature: Data,
        userHandle: Data,
        success: @escaping (_ authToken: String) -> Void,
        failure: @escaping (_ error: WordPressComOAuthError) -> Void
    ) {
        Task { @MainActor in
            let result = await authenticateWebauthnSignature(
                userID: userID,
                twoStepNonce: twoStepNonce,
                credentialID: credentialID,
                clientDataJson: clientDataJson,
                authenticatorData: authenticatorData,
                signature: signature,
                userHandle: userHandle
            )
            switch result {
            case let .success(token):
                success(token)
            case let .failure(error):
                failure(error)
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
    private static func extractNonceInfo(data: [String: AnyObject]) -> SocialLogin2FANonceInfo {
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
    public func authenticate(
        socialLoginUserID userID: Int,
        authType: String,
        twoStepCode: String,
        twoStepNonce: String,
        success: @escaping (_ authToken: String?) -> Void,
        failure: @escaping (_ error: WordPressComOAuthError) -> Void
    ) {
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
                        return failure(.unparsableResponse(response: response.response, body: response.data))
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

    /// A error processor to handle error responses when status codes are betwen 400 and 500.
    /// Some HTTP requests include a response body even in a failure scenario. This method ensures
    /// it is available via an error's userInfo dictionary.
    func processError(response: DataResponse<Any>, originalError: Error) -> WordPressComOAuthError {
        switch originalError {
        case let urlError as URLError:
            return .connection(urlError)
        case let afError as AFError:
            switch afError {
            case .invalidURL, .parameterEncodingFailed, .multipartEncodingFailed:
                return .requestEncodingFailure
            case .responseSerializationFailed:
                return .unparsableResponse(response: response.response, body: response.data)
            case .responseValidationFailed:
                guard let statusCode = response.response?.statusCode,
                      [400, 409, 403].contains(statusCode),
                      let data = response.data,
                      let responseObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                      let responseDictionary = responseObject as? [String: AnyObject]
                else {
                    return .unparsableResponse(response: response.response, body: response.data)
                }

                return .endpointError(.init(apiJSONResponse: responseDictionary))
            }
        default:
            return .unknown(underlyingError: originalError)
        }
    }

    static func processError(_ response: HTTPAPIResponse<Data>) -> AuthenticationFailure? {
        guard [400, 409, 403].contains(response.response.statusCode),
              let responseObject = try? JSONSerialization.jsonObject(with: response.body, options: .allowFragments),
              let responseDictionary = responseObject as? [String: AnyObject]
        else {
            return nil
        }

        return .init(apiJSONResponse: responseDictionary)
    }
}
