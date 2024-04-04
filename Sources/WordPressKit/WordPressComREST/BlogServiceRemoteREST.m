#import <Foundation/Foundation.h>
#import "BlogServiceRemoteREST.h"
#import "NSMutableDictionary+Helpers.h"
#import "RemotePostType.h"
#import "WPKit-Swift.h"
@import NSObject_SafeExpectations;
@import WordPressShared;

#pragma mark - Parsing Keys
static NSString * const RemotePostTypesKey                                  = @"post_types";
static NSString * const RemotePostTypeNameKey                               = @"name";
static NSString * const RemotePostTypeLabelKey                              = @"label";
static NSString * const RemotePostTypeQueryableKey                          = @"api_queryable";

#pragma mark - Keys used for Update Calls
// Note: Only god knows why these don't match the "Parsing Keys"
static NSString * const RemoteBlogNameForUpdateKey                          = @"blogname";
static NSString * const RemoteBlogTaglineForUpdateKey                       = @"blogdescription";

#pragma mark - Defaults
static NSString * const RemoteBlogDefaultPostFormat                         = @"standard";

@implementation BlogServiceRemoteREST

- (void)getAllAuthorsWithSuccess:(UsersHandler)success
                         failure:(void (^)(NSError *error))failure
{
    [self getAllAuthorsWithRemoteUsers:nil
                                offset:nil
                               success:success
                               failure:failure];
}

/**
 This method is called recursively to fetch all authors.
 The success block is called whenever the response users array is nil or empty.
 
 @param remoteUsers The loaded remote users
 @param offset The first n users to be skipped in the returned array
 @param success The block that will be executed on success
 @param failure The block that will be executed on failure
 */
- (void)getAllAuthorsWithRemoteUsers:(NSMutableArray <RemoteUser *>*)remoteUsers
                              offset:(NSNumber *)offset
                             success:(UsersHandler)success
                             failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *parameters = [@{ @"authors_only":@(YES),
                                          @"number": @(100)
                                        } mutableCopy];
    
    if ([offset wp_isValidObject]) {
        parameters[@"offset"] = offset.stringValue;
    }
    
    NSString *path = [self pathForUsers];
    NSString *requestUrl = [self pathForEndpoint:path
                                     withVersion:ServiceRemoteWordPressComRESTApiVersion_1_1];

    [self.wordPressComRESTAPI get:requestUrl
                       parameters:parameters
                          success:^(id responseObject, NSHTTPURLResponse *httpResponse) {
                              if (success) {
                                  NSArray *responseUsers = responseObject[@"users"];
                                  
                                  NSMutableArray *users = [remoteUsers wp_isValidObject] ? [remoteUsers mutableCopy] : [NSMutableArray array];
                                  
                                  if (![responseUsers wp_isValidObject] || responseUsers.count == 0) {
                                      success([users copy]);
                                  } else {
                                      [users addObjectsFromArray:[self usersFromJSONArray:responseUsers]];
                                      [self getAllAuthorsWithRemoteUsers:users
                                                                  offset:@(users.count)
                                                                 success:success
                                                                 failure:failure];
                                  }
                              }
                          } failure:^(NSError *error, NSHTTPURLResponse *httpResponse) {
                              if (failure) {
                                  failure(error);
                              }
                          }];
}

- (void)syncPostTypesWithSuccess:(PostTypesHandler)success
                         failure:(void (^)(NSError *error))failure
{
    NSString *path = [self pathForPostTypes];
    NSString *requestUrl = [self pathForEndpoint:path
                                     withVersion:ServiceRemoteWordPressComRESTApiVersion_1_1];
    NSDictionary *parameters = @{@"context": @"edit"};
    [self.wordPressComRESTAPI get:requestUrl
       parameters:parameters
          success:^(NSDictionary *responseObject, NSHTTPURLResponse *httpResponse) {
             
              NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"Response should be a dictionary.");
              NSArray <RemotePostType *> *postTypes = [[responseObject arrayForKey:RemotePostTypesKey] wp_map:^id(NSDictionary *json) {
                  return [self remotePostTypeWithDictionary:json];
              }];
              if (!postTypes.count) {
                  WPKitLogError(@"Response to %@ did not include post types for site.", requestUrl);
                  failure(nil);
                  return;
              }
              if (success) {
                  success(postTypes);
              }
          } failure:^(NSError *error, NSHTTPURLResponse *httpResponse) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)syncPostFormatsWithSuccess:(PostFormatsHandler)success
                           failure:(void (^)(NSError *))failure
{
    NSString *path = [self pathForPostFormats];
    NSString *requestUrl = [self pathForEndpoint:path
                                     withVersion:ServiceRemoteWordPressComRESTApiVersion_1_1];
    
    [self.wordPressComRESTAPI get:requestUrl
       parameters:nil
          success:^(id responseObject, NSHTTPURLResponse *httpResponse) {
              NSDictionary *formats = [self mapPostFormatsFromResponse:responseObject[@"formats"]];
              if (success) {
                  success(formats);
              }
          } failure:^(NSError *error, NSHTTPURLResponse *httpResponse) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)syncBlogSettingsWithSuccess:(SettingsHandler)success
                        failure:(void (^)(NSError *error))failure
{
    NSString *path = [self pathForSettings];
    NSString *requestUrl = [self pathForEndpoint:path withVersion:ServiceRemoteWordPressComRESTApiVersion_1_1];
    
    [self.wordPressComRESTAPI get:requestUrl
       parameters:nil
          success:^(id responseObject, NSHTTPURLResponse *httpResponse) {
              if (![responseObject isKindOfClass:[NSDictionary class]]){
                  if (failure) {
                      failure(nil);
                  }
                  return;
              }
              RemoteBlogSettings *remoteSettings = [self remoteBlogSettingFromJSONDictionary:responseObject];
              if (success) {
                  success(remoteSettings);
              }
          } failure:^(NSError *error, NSHTTPURLResponse *httpResponse) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)updateBlogSettings:(RemoteBlogSettings *)settings
                   success:(SuccessHandler)success
                   failure:(void (^)(NSError *error))failure;
{
    NSParameterAssert(settings);

    NSDictionary *parameters = [self remoteSettingsToDictionary:settings];
    NSString *path = [NSString stringWithFormat:@"sites/%@/settings?context=edit", self.siteID];
    NSString *requestUrl = [self pathForEndpoint:path withVersion:ServiceRemoteWordPressComRESTApiVersion_1_1];
    
    [self.wordPressComRESTAPI post:requestUrl
        parameters:parameters
           success:^(NSDictionary *responseDict, NSHTTPURLResponse *httpResponse) {
               if (![responseDict isKindOfClass:[NSDictionary class]]) {
                   if (failure) {
                       failure(nil);
                   }
                   return;
               }
               if (!responseDict[@"updated"]) {
                   if (failure) {
                       failure(nil);
                   }
               } else if (success) {
                   success();
               }
           }
           failure:^(NSError *error, NSHTTPURLResponse *httpResponse) {
               if (failure) {
                   failure(error);
               }
           }];
}

- (void)fetchSiteInfoForAddress:(NSString *)siteAddress
                        success:(void(^)(NSDictionary *siteInfoDict))success
                        failure:(void (^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"sites/%@", siteAddress];
    NSString *requestUrl = [self pathForEndpoint:path
                                     withVersion:ServiceRemoteWordPressComRESTApiVersion_1_1];

    [self.wordPressComRESTAPI get:requestUrl
                       parameters:nil
                          success:^(id responseObject, NSHTTPURLResponse *httpResponse) {
                              if (success) {
                                  success((NSDictionary *)responseObject);
                                  return;
                              }
                          } failure:^(NSError *error, NSHTTPURLResponse *httpResponse) {
                              if (failure) {
                                  failure(error);
                              }
                          }];
}

- (void)fetchUnauthenticatedSiteInfoForAddress:(NSString *)siteAddress
                        success:(void(^)(NSDictionary *siteInfoDict))success
                        failure:(void (^)(NSError *error))failure
{
    NSString *path = [self pathForEndpoint:@"connect/site-info" withVersion:ServiceRemoteWordPressComRESTApiVersion_1_1];
    NSURL *siteURL = [NSURL URLWithString:siteAddress];

    [self.wordPressComRESTAPI get:path
                       parameters:@{ @"url": siteURL.absoluteString }
                          success:^(id responseObject, NSHTTPURLResponse *httpResponse) {
                              if (success) {
                                  success((NSDictionary *)responseObject);
                              }
                          } failure:^(NSError *error, NSHTTPURLResponse *httpResponse) {
                              if(failure) {
                                  failure(error);
                              }
                          }];
}

#pragma mark - API paths

- (NSString *)pathForUsers
{
    return [NSString stringWithFormat:@"sites/%@/users", self.siteID];
}

- (NSString *)pathForPostTypes
{
    return [NSString stringWithFormat:@"sites/%@/post-types", self.siteID];
}

- (NSString *)pathForPostFormats
{
    return [NSString stringWithFormat:@"sites/%@/post-formats", self.siteID];
}

- (NSString *)pathForSettings
{
    return [NSString stringWithFormat:@"sites/%@/settings", self.siteID];
}


#pragma mark - Mapping methods

- (NSArray *)usersFromJSONArray:(NSArray *)jsonUsers
{
    return [jsonUsers wp_map:^RemoteUser *(NSDictionary *jsonUser) {
        return [self userFromJSONDictionary:jsonUser];
    }];
}

- (RemoteUser *)userFromJSONDictionary:(NSDictionary *)jsonUser
{
    RemoteUser *user = [RemoteUser new];
    user.userID = jsonUser[@"ID"];
    user.username = jsonUser[@"login"];
    user.email = jsonUser[@"email"];
    user.displayName = jsonUser[@"name"];
    user.primaryBlogID = jsonUser[@"site_ID"];
    user.avatarURL = jsonUser[@"avatar_URL"];
    user.linkedUserID = jsonUser[@"linked_user_ID"];
    return user;
}

- (NSDictionary *)mapPostFormatsFromResponse:(id)response
{
    if ([response isKindOfClass:[NSDictionary class]]) {
        return response;
    } else {
        return @{};
    }
}

- (RemotePostType *)remotePostTypeWithDictionary:(NSDictionary *)json
{
    RemotePostType *postType = [[RemotePostType alloc] init];
    postType.name = [json stringForKey:RemotePostTypeNameKey];
    postType.label = [json stringForKey:RemotePostTypeLabelKey];
    postType.apiQueryable = [json numberForKey:RemotePostTypeQueryableKey];
    return postType;
}

- (NSDictionary *)remoteSettingsToDictionary:(RemoteBlogSettings *)settings
{
    return [settings dictionaryRepresentation];
}

@end
