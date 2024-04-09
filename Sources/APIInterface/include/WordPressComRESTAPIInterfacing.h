@import Foundation;

@class FilePart;

@protocol WordPressComRESTAPIInterfacing

@property (strong, nonatomic, readonly) NSURL * _Nonnull baseURL;

/// Whether the user's preferred language locale should be appended to the request.
/// Should default to `true`.
///
/// - SeeAlso: `localeKey` and `localeValue` to configure the locale appendend to the request.
@property (nonatomic, readonly) BOOL appendsPreferredLanguageLocale;

/// The key with which to specify locale in the parameters of a request.
@property (strong, nonatomic, readonly) NSString * _Nonnull localeKey;

/// The value with which to specify locale in the parameters of a request.
@property (strong, nonatomic, readonly) NSString * _Nonnull localeValue;

/// - Note: `parameters` has `id` instead of the more common `NSObject *` as its value type so it will convert to `AnyObject` in Swift.
///         In Swift, it's simpler to work with `AnyObject` than with `NSObject`. For example `"abc" as AnyObject` over `"abc" as NSObject`.
- (NSProgress * _Nullable)get:(NSString * _Nonnull)URLString
                   parameters:(NSDictionary<NSString *, id> * _Nullable)parameters
                      success:(void (^ _Nonnull)(id _Nonnull, NSHTTPURLResponse * _Nullable))success
                      failure:(void (^ _Nonnull)(NSError * _Nonnull, NSHTTPURLResponse * _Nullable))failure;

/// - Note: `parameters` has `id` instead of the more common `NSObject *` as its value type so it will convert to `AnyObject` in Swift.
///         In Swift, it's simpler to work with `AnyObject` than with `NSObject`. For example `"abc" as AnyObject` over `"abc" as NSObject`.
- (NSProgress * _Nullable)post:(NSString * _Nonnull)URLString
                    parameters:(NSDictionary<NSString *, id> * _Nullable)parameters
                       success:(void (^ _Nonnull)(id _Nonnull, NSHTTPURLResponse * _Nullable))success
                       failure:(void (^ _Nonnull)(NSError * _Nonnull, NSHTTPURLResponse * _Nullable))failure;

- (NSProgress * _Nullable)multipartPOST:(NSString * _Nonnull)URLString
                             parameters:(NSDictionary<NSString *, NSObject *> * _Nullable)parameters
                              fileParts:(NSArray<FilePart *> * _Nonnull)fileParts
                        requestEnqueued:(void (^ _Nullable)(NSNumber * _Nonnull))requestEnqueue
                                success:(void (^ _Nonnull)(id _Nonnull, NSHTTPURLResponse * _Nullable))success
                                failure:(void (^ _Nonnull)(NSError * _Nonnull, NSHTTPURLResponse * _Nullable))failure;

@end
