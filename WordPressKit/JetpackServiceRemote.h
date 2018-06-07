#import <Foundation/Foundation.h>
#import "ServiceRemoteWordPressComREST.h"

@interface JetpackServiceRemote : ServiceRemoteWordPressComREST

- (void)checkSiteHasJetpack:(NSURL *)siteURL
                    success:(void (^)(BOOL hasJetpack))success
                    failure:(void (^)(NSError *error))failure;

@end
