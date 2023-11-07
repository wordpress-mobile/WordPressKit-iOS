import Foundation

#if SWIFT_PACKAGE
import WordPressKitObjC
#endif

public enum UsersServiceRemoteError: Int, Error {
    case UnexpectedResponseData
}

/// UsersServiceRemoteXMLRPC handles Users related XML-RPC calls.
/// https://codex.wordpress.org/XML-RPC_WordPress_API/Users
///
public class UsersServiceRemoteXMLRPC: ServiceRemoteWordPressXMLRPC {

    /// Fetch the blog user's profile.
    ///
    public func fetchProfile(_ success: @escaping ((RemoteProfile) -> Void), failure: @escaping ((NSError?) -> Void)) {
        let params = defaultXMLRPCArguments() as [AnyObject]
        api.callMethod("wp.getProfile", parameters: params, success: { (responseObj, _) in
            guard let dict = responseObj as? NSDictionary else {
                assertionFailure("A dictionary was expected but the API returned something different.")
                failure(UsersServiceRemoteError.UnexpectedResponseData as NSError)
                return
            }
            let profile = RemoteProfile(dictionary: dict)
            success(profile)

        }, failure: { (error, _) in
            failure(error)
        })
    }

}
