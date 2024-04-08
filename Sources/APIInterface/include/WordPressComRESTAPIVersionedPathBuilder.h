#import <Foundation/Foundation.h>
#import <WordPressKit/WordPressComRESTAPIVersion.h>

@interface WordPressComRESTAPIVersionedPathBuilder: NSObject

+ (NSString  * _Nonnull )pathForEndpoint:(NSString  * _Nonnull )endpoint
                             withVersion:(WordPressComRESTAPIVersion)apiVersion
NS_SWIFT_NAME(path(forEndpoint:withVersion:));

@end
