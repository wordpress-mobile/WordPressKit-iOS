#import <Foundation/Foundation.h>
//#import "ServiceRemoteWordPressComREST.h"
#import "ServiceRemoteWordPressComREST.h"

NS_ASSUME_NONNULL_BEGIN

@interface SiteServiceRemoteWordPressComREST : ServiceRemoteWordPressComREST

@property (nonatomic, readonly) NSNumber *siteID;

- (instancetype)initWithWordPressComRestApi:(id<WordPressComRestApi>)api __unavailable;
- (instancetype)initWithWordPressComRestApi:(id<WordPressComRestApi>)api siteID:(NSNumber *)siteID;

@end

NS_ASSUME_NONNULL_END
