#import "RemotePost.h"
#import <objc/runtime.h>
#import "SHAHasher.h"

NSString * const PostStatusDraft = @"draft";
NSString * const PostStatusPending = @"pending";
NSString * const PostStatusPrivate = @"private";
NSString * const PostStatusPublish = @"publish";
NSString * const PostStatusScheduled = @"future";
NSString * const PostStatusTrash = @"trash";
NSString * const PostStatusDeleted = @"deleted"; // Returned by wpcom REST API when a post is permanently deleted.

@implementation RemotePost

- (id)initWithSiteID:(NSNumber *)siteID status:(NSString *)status title:(NSString *)title content:(NSString *)content
{
    self = [super init];
    if (self) {
        _siteID = siteID;
        _status = status;
        _title = title;
        _content = content;
    }
    return self;
}

- (NSString *)debugDescription {
    NSDictionary *properties = [self debugProperties];
    return [NSString stringWithFormat:@"<%@: %p> (%@)", NSStringFromClass([self class]), self, properties];
}

- (NSDictionary *)debugProperties {
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([RemotePost class], &propertyCount);
    NSMutableDictionary *debugProperties = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
    for (int i = 0; i < propertyCount; i++)
    {
        // Add property name to array
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        id value = [self valueForKey:@(propertyName)];
        if (value == nil) {
            value = [NSNull null];
        }
        [debugProperties setObject:value forKey:@(propertyName)];
    }
    free(properties);
    return [NSDictionary dictionaryWithDictionary:debugProperties];
}

/// A hash used to determine if the remote content has changed.
///
/// This hash must remain constant regardless of iOS version, app restarts or instances used. `Hasher` or NSObject's `hash` were not used for these reasons.
///
/// - Note: `dateModified` is not included within the hash as it is prone to change wihout the content having been changed and is the reason this hash is necessary.
- (NSString *)contentHash
{
    NSString *hashedContents = [NSString stringWithFormat:@"%@/%@/%@%@/%@/%@%@/%@/%@%@/%@/%@%@/%@/%@%@/%@/%@%@/%@/%@%@/%@/%@%@/%@/%@",
        self.postID.stringValue,
        self.siteID.stringValue,
        self.authorAvatarURL,
        self.authorDisplayName,
        self.authorEmail,
        self.authorURL,
        self.authorID.stringValue,
        self.date.description,
        self.title,
        self.URL.absoluteString,
        self.shortURL.absoluteString,
        self.content,
        self.excerpt,
        self.slug,
        self.suggestedSlug,
        self.status,
        self.parentID.stringValue,
        self.postThumbnailID.stringValue,
        self.postThumbnailPath,
        self.type,
        self.format,
        self.commentCount.stringValue,
        self.likeCount.stringValue,
        [self.tags componentsJoinedByString:@""],
        self.pathForDisplayImage,
        self.isStickyPost.stringValue,
        self.isFeaturedImageChanged ? @"1" : @"2"];
    NSData *hashData = [SHAHasher hashForString:hashedContents];
    return [SHAHasher sha256StringFromData:hashData];
}

@end
