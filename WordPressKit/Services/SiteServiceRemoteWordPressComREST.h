#import <Foundation/Foundation.h>
#import <WordPressKit/ServiceRemoteWordPressComREST.h>

NS_ASSUME_NONNULL_BEGIN

@interface SiteServiceRemoteWordPressComREST : ServiceRemoteWordPressComREST

@property (nonatomic, readonly) NSNumber *siteID;

- (instancetype)initWithWordPressComRestApi:(WordPressComRestApi *)api __unavailable;
- (instancetype)initWithWordPressComRestApi:(WordPressComRestApi *)api siteID:(NSNumber *)siteID;

@end

NS_ASSUME_NONNULL_END
