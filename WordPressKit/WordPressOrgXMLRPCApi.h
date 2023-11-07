@import Foundation;

@protocol WordPressOrgXMLRPCApi <NSObject>
@property (nonatomic, class, readonly, copy) NSString * _Nonnull defaultBackgroundSessionIdentifier;
+ (NSString * _Nonnull)defaultBackgroundSessionIdentifier;
/// Minimum WordPress.org Supported Version.
@property (nonatomic, class, readonly, copy) NSString * _Nonnull minimumSupportedVersion;
+ (NSString * _Nonnull)minimumSupportedVersion;
/// Creates a new API object to connect to the WordPress XMLRPC API for the specified endpoint.
/// \param endpoint the endpoint to connect to the xmlrpc api interface.
///
/// \param userAgent the user agent to use on the connection.
///
/// \param backgroundUploads If this value is true the API object will use a background session to execute uploads requests when using the <code>multipartPOST</code> function. The default value is false.
///
/// \param backgroundSessionIdentifier The session identifier to use for the background session. This must be unique in the system.
///
- (nonnull instancetype)initWithEndpoint:(NSURL * _Nonnull)endpoint userAgent:(NSString * _Nullable)userAgent backgroundUploads:(BOOL)backgroundUploads backgroundSessionIdentifier:(NSString * _Nonnull)backgroundSessionIdentifier;
/// Creates a new API object to connect to the WordPress XMLRPC API for the specified endpoint. The background uploads are disabled when using this initializer.
/// \param endpoint the endpoint to connect to the xmlrpc api interface.
///
/// \param userAgent the user agent to use on the connection.
///
- (nonnull instancetype)initWithEndpoint:(NSURL * _Nonnull)endpoint userAgent:(NSString * _Nullable)userAgent;
/// Cancels all ongoing and makes the session so the object will not fullfil any more request
- (void)invalidateAndCancelTasks;
/// Check if username and password are valid credentials for the xmlrpc endpoint.
/// \param username username to check
///
/// \param password password to check
///
/// \param success callback block to be invoked if credentials are valid, the object returned in the block is the options dictionary for the site.
///
/// \param failure callback block to be invoked is credentials fail
///
- (void)checkCredentials:(NSString * _Nonnull)username password:(NSString * _Nonnull)password success:(void (^ _Nonnull)(id _Nonnull, NSHTTPURLResponse * _Nullable))success failure:(void (^ _Nonnull)(NSError * _Nonnull, NSHTTPURLResponse * _Nullable))failure;
/// Executes a XMLRPC call for the method specificied with the arguments provided.
/// \param method the xmlrpc method to be invoked
///
/// \param parameters the parameters to be encoded on the request
///
/// \param success callback to be called on successful request
///
/// \param failure callback to be called on failed request
///
///
/// returns:
/// a NSProgress object that can be used to track the progress of the request and to cancel the request. If the method
/// returns nil it’s because something happened on the request serialization and the network request was not started, but the failure callback
/// will be invoked with the error specificing the serialization issues.
- (NSProgress * _Nullable)callMethod:(NSString * _Nonnull)method parameters:(NSArray * _Nullable)parameters success:(void (^ _Nonnull)(id _Nonnull, NSHTTPURLResponse * _Nullable))success failure:(void (^ _Nonnull)(NSError * _Nonnull, NSHTTPURLResponse * _Nullable))failure;
/// Executes a XMLRPC call for the method specificied with the arguments provided, by streaming the request from a file.
/// This allows to do requests that can use a lot of memory, like media uploads.
/// \param method the xmlrpc method to be invoked
///
/// \param parameters the parameters to be encoded on the request
///
/// \param success callback to be called on successful request
///
/// \param failure callback to be called on failed request
///
///
/// returns:
/// a NSProgress object that can be used to track the progress of the request and to cancel the request. If the method
/// returns nil it’s because something happened on the request serialization and the network request was not started, but the failure callback
/// will be invoked with the error specificing the serialization issues.
- (NSProgress * _Nullable)streamCallMethod:(NSString * _Nonnull)method parameters:(NSArray * _Nullable)parameters success:(void (^ _Nonnull)(id _Nonnull, NSHTTPURLResponse * _Nullable))success failure:(void (^ _Nonnull)(NSError * _Nonnull, NSHTTPURLResponse * _Nullable))failure;
@property (nonatomic, class, readonly, strong) NSErrorUserInfoKey _Nonnull WordPressOrgXMLRPCApiErrorKeyData;
+ (NSErrorUserInfoKey _Nonnull)WordPressOrgXMLRPCApiErrorKeyData;
@property (nonatomic, class, readonly, strong) NSErrorUserInfoKey _Nonnull WordPressOrgXMLRPCApiErrorKeyDataString;
+ (NSErrorUserInfoKey _Nonnull)WordPressOrgXMLRPCApiErrorKeyDataString;
@property (nonatomic, class, readonly, strong) NSErrorUserInfoKey _Nonnull WordPressOrgXMLRPCApiErrorKeyStatusCode;
+ (NSErrorUserInfoKey _Nonnull)WordPressOrgXMLRPCApiErrorKeyStatusCode;
@end
