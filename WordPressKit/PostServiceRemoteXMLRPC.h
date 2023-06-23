#import <Foundation/Foundation.h>
#import <WordPressKit/PostServiceRemote.h>
#import <WordPressKit/ServiceRemoteWordPressXMLRPC.h>

NS_ASSUME_NONNULL_BEGIN
@interface PostServiceRemoteXMLRPC : ServiceRemoteWordPressXMLRPC <PostServiceRemote>
- (NSDictionary *)parametersWithRemotePost:(RemotePost *)post;
@end
NS_ASSUME_NONNULL_END
