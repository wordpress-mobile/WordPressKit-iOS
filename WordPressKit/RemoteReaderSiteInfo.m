#import "RemoteReaderSiteInfo.h"
#import "WPKit-Swift.h"

@import NSObject_SafeExpectations;

// Site Topic Keys
static NSString * const SiteDictionaryFeedIDKey = @"feed_ID";
static NSString * const SiteDictionaryFeedURLKey = @"feed_URL";
static NSString * const SiteDictionaryFollowingKey = @"is_following";
static NSString * const SiteDictionaryJetpackKey = @"is_jetpack";
static NSString * const SiteDictionaryOrganizationID = @"organization_id";
static NSString * const SiteDictionaryPrivateKey = @"is_private";
static NSString * const SiteDictionaryVisibleKey = @"visible";
static NSString * const SiteDictionaryPostCountKey = @"post_count";
static NSString * const SiteDictionaryIconPathKey = @"icon.img";
static NSString * const SiteDictionaryDescriptionKey = @"description";
static NSString * const SiteDictionaryIDKey = @"ID";
static NSString * const SiteDictionaryNameKey = @"name";
static NSString * const SiteDictionaryURLKey = @"URL";
static NSString * const SiteDictionarySubscriptionsKey = @"subscribers_count";
static NSString * const SiteDictionarySubscriptionKey = @"subscription";
static NSString * const SiteDictionaryUnseenCountKey = @"unseen_count";

// Subscription keys
static NSString * const SubscriptionDeliveryMethodsKey = @"delivery_methods";

// Delivery methods keys
static NSString * const DeliveryMethodEmailKey = @"email";
static NSString * const DeliveryMethodNotificationKey = @"notification";

@implementation RemoteReaderSiteInfo

+ (instancetype)siteInfoForSiteResponse:(NSDictionary *)response isFeed:(BOOL)isFeed
{
    if (isFeed) {
        return [self siteInfoForFeedResponse:response];
    }

    RemoteReaderSiteInfo *siteInfo = [RemoteReaderSiteInfo new];
    siteInfo.feedID = [response numberForKey:SiteDictionaryFeedIDKey];
    siteInfo.feedURL = [response stringForKey:SiteDictionaryFeedURLKey];
    siteInfo.isFollowing = [[response numberForKey:SiteDictionaryFollowingKey] boolValue];
    siteInfo.isJetpack = [[response numberForKey:SiteDictionaryJetpackKey] boolValue];
    siteInfo.isPrivate = [[response numberForKey:SiteDictionaryPrivateKey] boolValue];
    siteInfo.isVisible = [[response numberForKey:SiteDictionaryVisibleKey] boolValue];
    siteInfo.organizationID = [response numberForKey:SiteDictionaryOrganizationID] ?: @0;
    siteInfo.postCount = [response numberForKey:SiteDictionaryPostCountKey];
    siteInfo.siteBlavatar = [response stringForKeyPath:SiteDictionaryIconPathKey];
    siteInfo.siteDescription = [response stringForKey:SiteDictionaryDescriptionKey];
    siteInfo.siteID = [response numberForKey:SiteDictionaryIDKey];
    siteInfo.siteName = [response stringForKey:SiteDictionaryNameKey];
    siteInfo.siteURL = [response stringForKey:SiteDictionaryURLKey];
    siteInfo.subscriberCount = [response numberForKey:SiteDictionarySubscriptionsKey] ?: @0;
    siteInfo.unseenCount = [response numberForKey: SiteDictionaryUnseenCountKey] ?: @0;

    if (![siteInfo.siteName length] && [siteInfo.siteURL length] > 0) {
        siteInfo.siteName = [[NSURL URLWithString:siteInfo.siteURL] host];
    }

    siteInfo.endpointPath = [NSString stringWithFormat:@"read/sites/%@/posts/", siteInfo.siteID];

    NSDictionary *subscription = response[SiteDictionarySubscriptionKey];
    siteInfo.postSubscription = [self.class postSubscriptionFor:subscription];
    siteInfo.emailSubscription = [self.class emailSubscriptionFor:subscription];

    return siteInfo;
}

+ (instancetype)siteInfoForFeedResponse:(NSDictionary *)response
{
    RemoteReaderSiteInfo *siteInfo = [RemoteReaderSiteInfo new];
    siteInfo.feedID = [response numberForKey:SiteDictionaryFeedIDKey];
    siteInfo.feedURL = [response stringForKey:SiteDictionaryFeedURLKey];
    siteInfo.isFollowing = [[response numberForKey:SiteDictionaryFollowingKey] boolValue];
    siteInfo.isJetpack = NO;
    siteInfo.isPrivate = NO;
    siteInfo.isVisible = YES;
    siteInfo.postCount = @0;
    siteInfo.siteBlavatar = @"";
    siteInfo.siteDescription = @"";
    siteInfo.siteID = @0;
    siteInfo.siteName = [response stringForKey:SiteDictionaryNameKey];
    siteInfo.siteURL = [response stringForKey:SiteDictionaryURLKey];
    siteInfo.subscriberCount = [response numberForKey:SiteDictionarySubscriptionsKey] ?: @0;

    if (![siteInfo.siteName length] && [siteInfo.siteURL length] > 0) {
        siteInfo.siteName = [[NSURL URLWithString:siteInfo.siteURL] host];
    }
    
    siteInfo.endpointPath = [NSString stringWithFormat:@"read/feed/%@/posts/", siteInfo.feedID];

    return siteInfo;
}

/**
 Generate an Site Info Post Subscription object

 @param subscription A dictionary object for the site subscription
 @return A nullable Site Info Post Subscription
 */
+ (RemoteReaderSiteInfoSubscriptionPost *)postSubscriptionFor:(NSDictionary *)subscription
{
    if (![subscription wp_isValidObject]) {
        return nil;
    }

    NSDictionary *method = [[subscription dictionaryForKey: SubscriptionDeliveryMethodsKey] dictionaryForKey: DeliveryMethodNotificationKey];

    if (![method wp_isValidObject]) {
        return nil;
    }

    return [[RemoteReaderSiteInfoSubscriptionPost alloc] initWithDictionary:method];
}

/**
 Generate an Site Info Email Subscription object

 @param subscription A dictionary object for the site subscription
 @return A nullable Site Info Email Subscription
 */

+ (RemoteReaderSiteInfoSubscriptionEmail *)emailSubscriptionFor:(NSDictionary *)subscription
{
    if (![subscription wp_isValidObject]) {
        return nil;
    }

    NSDictionary *method = [[subscription dictionaryForKey: SubscriptionDeliveryMethodsKey] dictionaryForKey: DeliveryMethodEmailKey];

    if (![method wp_isValidObject]) {
        return nil;
    }

    return [[RemoteReaderSiteInfoSubscriptionEmail alloc] initWithDictionary:method];
}
@end
