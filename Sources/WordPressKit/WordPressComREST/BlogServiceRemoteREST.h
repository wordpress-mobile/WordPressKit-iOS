#import <Foundation/Foundation.h>
#import <WordPressKit/BlogServiceRemote.h>
#import <WordPressKit/SiteServiceRemoteWordPressComREST.h>

typedef void (^SettingsHandler)(RemoteBlogSettings *settings);

@interface BlogServiceRemoteREST : SiteServiceRemoteWordPressComREST <BlogServiceRemote>

/**
 *  @brief      Fetch site info for the specified site address.
 *
 *  @note       Uses anonymous API
 *
 *  @param      success     The block that will be executed on success.  Can be nil.
 *  @param      failure     The block that will be executed on failure.  Can be nil.
 */
- (void)fetchSiteInfoForAddress:(NSString *)siteAddress
                        success:(void(^)(NSDictionary *siteInfoDict))success
                        failure:(void (^)(NSError *error))failure;

/**
 *  @brief      Fetch site info (does not require authentication) for the specified site address.
 *
 *  @note       Uses anonymous API
 *
 *  @param      success     The block that will be executed on success.  Can be nil.
 *  @param      failure     The block that will be executed on failure.  Can be nil.
 */
- (void)fetchUnauthenticatedSiteInfoForAddress:(NSString *)siteAddress
                        success:(void(^)(NSDictionary *siteInfoDict))success
                        failure:(void (^)(NSError *error))failure;

@end
