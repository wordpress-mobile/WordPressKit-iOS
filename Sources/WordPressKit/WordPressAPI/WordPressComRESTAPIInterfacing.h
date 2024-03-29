@import Foundation;

@class FilePart;

@protocol WordPressComRESTAPIInterfacing

@property (strong, nonatomic, readonly) NSURL * _Nonnull baseURL;

- (NSProgress * _Nullable)get:(NSString * _Nonnull)URLString
                   parameters:(NSDictionary<NSString *, NSObject *> * _Nullable)parameters
                      success:(void (^ _Nonnull)(id _Nonnull, NSHTTPURLResponse * _Nullable))success
                      failure:(void (^ _Nonnull)(NSError * _Nonnull, NSHTTPURLResponse * _Nullable))failure;

- (NSProgress * _Nullable)post:(NSString * _Nonnull)URLString
                    parameters:(NSDictionary<NSString *, NSObject *> * _Nullable)parameters
                       success:(void (^ _Nonnull)(id _Nonnull, NSHTTPURLResponse * _Nullable))success
                       failure:(void (^ _Nonnull)(NSError * _Nonnull, NSHTTPURLResponse * _Nullable))failure;

- (NSProgress * _Nullable)multipartPOST:(NSString * _Nonnull)URLString
                             parameters:(NSDictionary<NSString *, NSObject *> * _Nullable)parameters
                              fileParts:(NSArray<FilePart *> * _Nonnull)fileParts
                        requestEnqueued:(void (^ _Nullable)(NSNumber * _Nonnull))requestEnqueue
                                success:(void (^ _Nonnull)(id _Nonnull, NSHTTPURLResponse * _Nullable))success
                                failure:(void (^ _Nonnull)(NSError * _Nonnull, NSHTTPURLResponse * _Nullable))failure;

@end
