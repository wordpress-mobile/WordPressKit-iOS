#import "JetpackServiceRemote.h"

#import <WordPressKit/WordPressKit-Swift.h>
#import "WPKitLoggingPrivate.h"
@import CocoaLumberjack;
@import NSObject_SafeExpectations;

@implementation JetpackServiceRemote

/**
    Check if the specified site is a Jetpack site.  The success block
    receives a bool indicating if the site has Jetpack.
 */
- (void)checkSiteHasJetpack:(NSURL *)siteURL
                    success:(void (^)(BOOL isJetpack))success
                    failure:(void (^)(NSError *error))failure
{
    NSString *path = [self pathForEndpoint:@"connect/site-info" withVersion:ServiceRemoteWordPressComRESTApiVersion_1_1];

    [self.wordPressComRestApi GET:path
                       parameters:@{ @"url": siteURL.absoluteString }
                          success:^(id responseObject, NSHTTPURLResponse *httpResponse) {
                              NSDictionary *dict = (NSDictionary *)responseObject;
                              BOOL hasJetpack = [[dict numberForKey:@"hasJetpack"] boolValue];
                              success(hasJetpack);
                          } failure:^(NSError *error, NSHTTPURLResponse *httpResponse) {
                              failure(error);
                          }];
}


@end
