#import <Foundation/Foundation.h>

#import "WordPressOrgXMLRPCApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServiceRemoteWordPressXMLRPC : NSObject

- (id)initWithApi:(id<WordPressOrgXMLRPCApi>)api username:(NSString *)username password:(NSString *)password;

@property (nonatomic, readonly) id<WordPressOrgXMLRPCApi> api;

- (NSArray *)defaultXMLRPCArguments;
- (NSArray *)XMLRPCArgumentsWithExtra:(_Nullable id)extra;
- (NSArray *)XMLRPCArgumentsWithExtraDefaults:(NSArray *)extraDefaults andExtra:(_Nullable id)extra;

@end

NS_ASSUME_NONNULL_END
