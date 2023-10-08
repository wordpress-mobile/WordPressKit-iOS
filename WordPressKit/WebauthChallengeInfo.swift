import Foundation

/// Type that represents the Webauthn challenge info return by Wordpress.com
///
@objc public class WebauthnChallengeInfo: NSObject {
    /// Challenge to be signed.
    ///
    @objc public var challenge = ""

    /// The website this request is for
    ///
    @objc public var rpID = ""

    /// Nonce required by Wordpress.com to verify the signed challenge
    ///
    @objc public var twoStepNonce = ""

    init(challenge: String, rpID: String, twoStepNonce: String) {
        self.challenge = challenge
        self.rpID = rpID
        self.twoStepNonce = twoStepNonce
    }
}
