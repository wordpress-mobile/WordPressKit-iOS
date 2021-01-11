#import <Foundation/Foundation.h>


@class RemoteReaderSiteInfoSubscriptionEmail;
@class RemoteReaderSiteInfoSubscriptionPost;


@interface RemoteReaderSiteInfo: NSObject
@property (nonatomic, copy) NSNumber *feedID;
@property (nonatomic, copy) NSString *feedURL;
@property (nonatomic) BOOL isFollowing;
@property (nonatomic) BOOL isJetpack;
@property (nonatomic) BOOL isPrivate;
@property (nonatomic) BOOL isVisible;
@property (nonatomic, copy) NSNumber *organizationID;
@property (nonatomic, copy) NSNumber *postCount;
@property (nonatomic, copy) NSString *siteBlavatar;
@property (nonatomic, copy) NSString *siteDescription;
@property (nonatomic, copy) NSNumber *siteID;
@property (nonatomic, copy) NSString *siteName;
@property (nonatomic, copy) NSString *siteURL;
@property (nonatomic, copy) NSNumber *subscriberCount;
@property (nonatomic, copy) NSNumber *unseenCount;
@property (nonatomic, copy) NSString *postsEndpoint;
@property (nonatomic, copy) NSString *endpointPath;

@property (nonatomic, strong) RemoteReaderSiteInfoSubscriptionPost *postSubscription;
@property (nonatomic, strong) RemoteReaderSiteInfoSubscriptionEmail *emailSubscription;

+ (instancetype)siteInfoForSiteResponse:(NSDictionary *)response isFeed:(BOOL)isFeed;
@end
