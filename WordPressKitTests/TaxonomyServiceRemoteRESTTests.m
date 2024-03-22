#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "TaxonomyServiceRemoteREST.h"
#import "RemotePostTag.h"
@import WordPressKit;

@interface TaxonomyServiceRemoteRESTTests : XCTestCase

@property (nonatomic, strong) TaxonomyServiceRemoteREST *service;

@end

@implementation TaxonomyServiceRemoteRESTTests

- (void)setUp
{
    [super setUp];

    NSNumber *dotComID = @10;
    WordPressComRestApi *api = OCMStrictClassMock([WordPressComRestApi class]);

    TaxonomyServiceRemoteREST *service = nil;
    XCTAssertNoThrow(service = [[TaxonomyServiceRemoteREST alloc] initWithWordPressComRestApi:api siteID:dotComID]);
    
    self.service = service;
}

- (void)tearDown
{
    [super tearDown];
    
    self.service = nil;
}

- (NSString *)GETtaxonomyURLWithType:(NSString *)taxonomyTypeIdentifier
{
    NSString *endpoint = [NSString stringWithFormat:@"sites/%@/%@?context=edit", self.service.siteID, taxonomyTypeIdentifier];
    NSString *url = [self.service pathForEndpoint:endpoint
                                      withVersion:ServiceRemoteWordPressComRESTApiVersion_1_1];
    return url;
}

#pragma mark - Categories

- (void)testThatCreateCategoryWorks
{
    RemotePostCategory *category = OCMStrictClassMock([RemotePostCategory class]);
    OCMStub([category name]).andReturn(@"name");
    OCMStub([category parentID]).andReturn(nil);

    NSString *endpoint = [NSString stringWithFormat:@"sites/%@/%@/new?context=edit", self.service.siteID, @"categories"];
    NSString *url = [self.service pathForEndpoint:endpoint
                                      withVersion:ServiceRemoteWordPressComRESTApiVersion_1_1];

    BOOL (^parametersCheckBlock)(id obj) = ^BOOL(NSDictionary *parameters) {
        return ([parameters isKindOfClass:[NSDictionary class]] && [[parameters objectForKey:@"name"] isEqualToString:category.name]);
    };
    
    WordPressComRestApi *api = self.service.wordPressComRestApi;
    OCMStub([api post:[OCMArg isEqual:url]
           parameters:[OCMArg checkWithBlock:parametersCheckBlock]
              success:[OCMArg isNotNil]
              failure:[OCMArg isNotNil]]);
    
    [self.service createCategory:category
                         success:^(RemotePostCategory * _Nonnull category) {}
                         failure:^(NSError * _Nonnull error) {}];
}

- (void)testThatGetCategoriesWorks
{
    NSString *url = [self GETtaxonomyURLWithType:@"categories"];

    BOOL (^parametersCheckBlock)(id obj) = ^BOOL(NSDictionary *parameters) {
        return ([parameters isKindOfClass:[NSDictionary class]] && [[parameters objectForKey:@"number"] integerValue] == 1000);
    };

    WordPressComRestApi *api = self.service.wordPressComRestApi;
    OCMStub([api get:[OCMArg isEqual:url]
          parameters:[OCMArg checkWithBlock:parametersCheckBlock]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    [self.service getCategoriesWithSuccess:^(NSArray<RemotePostCategory *> * _Nonnull categories) {}
                                   failure:^(NSError * _Nonnull error) {}];
}

/// Verify `RemotePostCategory.parent` is `@0` instead of `nil` when the corresponding JSON response is `"parent": null`.
- (void)testThatGetCategoriesWithNilParent
{
    NSString *url = [self GETtaxonomyURLWithType:@"categories"];

    WordPressComRestApi *api = self.service.wordPressComRestApi;
    NSDictionary *json = @{
        @"found": @1,
        @"categories": @[
          @{
            @"ID": @97,
            @"name": @"Uncategorized",
            @"slug": @"uncategorized",
            @"description": @"",
            @"post_count": @0,
            @"feed_url": @"https://blog.wordpress.com/category/uncategorized/feed/",
            @"parent": [NSNull null],
            @"meta": @{
              @"links": @{
                @"self": @"https://public-api.wordpress.com/rest/v1.1/sites/42/categories/slug:uncategorized",
                @"help": @"https://public-api.wordpress.com/rest/v1.1/sites/42/categories/slug:uncategorized/help",
                @"site": @"https://public-api.wordpress.com/rest/v1.1/sites/42"
              }
            }
          }
        ]
      };
    NSHTTPURLResponse *response = OCMStrictClassMock([NSHTTPURLResponse class]);
    OCMStub([api get:[OCMArg isEqual:url]
          parameters:[OCMArg any]
             success:([OCMArg invokeBlockWithArgs:json, response, nil])
             failure:[OCMArg isNotNil]]);

    XCTestExpectation *parentIsZero = [self expectationWithDescription:@"parent should be zero"];
    id success = ^(NSArray<RemotePostCategory *> * _Nonnull categories) {
        if ([categories.firstObject.parentID isEqualToNumber:@0]) {
            [parentIsZero fulfill];
        }
    };
    [self.service getCategoriesWithSuccess:success
                                   failure:^(NSError * _Nonnull error) {}];

    [self waitForExpectations:@[parentIsZero] timeout:0.1];
}

- (void)testThatGetCategoriesWithPagingWorks
{
    RemoteTaxonomyPaging *paging = OCMStrictClassMock([RemoteTaxonomyPaging class]);
    OCMStub([paging number]).andReturn(@100);
    OCMStub([paging offset]).andReturn(@0);
    OCMStub([paging page]).andReturn(@0);
    OCMStub([paging order]).andReturn(RemoteTaxonomyPagingOrderAscending);
    OCMStub([paging orderBy]).andReturn(RemoteTaxonomyPagingResultsOrderingByName);

    NSString *url = [self GETtaxonomyURLWithType:@"categories"];
    
    BOOL (^parametersCheckBlock)(id obj) = ^BOOL(NSDictionary *parameters) {
        if (![parameters isKindOfClass:[NSDictionary class]]) {
            return NO;
        }
        if (![[parameters objectForKey:@"number"] isEqual:paging.number]) {
            return NO;
        }
        if (![[parameters objectForKey:@"offset"] isEqual:paging.offset]) {
            return NO;
        }
        if (![[parameters objectForKey:@"page"] isEqual:paging.page]) {
            return NO;
        }
        if (![[parameters objectForKey:@"order"] isEqualToString:@"ASC"]) {
            return NO;
        }
        if (![[parameters objectForKey:@"order_by"] isEqualToString:@"name"]) {
            return NO;
        }
        return YES;
    };
    
    WordPressComRestApi *api = self.service.wordPressComRestApi;
    OCMStub([api get:[OCMArg isEqual:url]
          parameters:[OCMArg checkWithBlock:parametersCheckBlock]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    [self.service getCategoriesWithPaging:paging
                                  success:^(NSArray<RemotePostCategory *> * _Nonnull categories) {}
                                  failure:^(NSError * _Nonnull error) {}];
}

- (void)testThatSearchCategoriesWithNameWorks
{
    NSString *url = [self GETtaxonomyURLWithType:@"categories"];
    NSString *searchName = @"category name";
    
    BOOL (^parametersCheckBlock)(id obj) = ^BOOL(NSDictionary *parameters) {
        if (![parameters isKindOfClass:[NSDictionary class]]) {
            return NO;
        }
        if (![[parameters objectForKey:@"search"] isEqualToString:searchName]) {
            return NO;
        }
        return YES;
    };
    
    WordPressComRestApi *api = self.service.wordPressComRestApi;
    OCMStub([api get:[OCMArg isEqual:url]
          parameters:[OCMArg checkWithBlock:parametersCheckBlock]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    [self.service searchCategoriesWithName:searchName
                                   success:^(NSArray<RemotePostCategory *> * _Nonnull categories) {}
                                   failure:^(NSError * _Nonnull error) {}];
}

#pragma mark - Tags

- (void)testThatCreateTagWorks
{
    RemotePostTag *tag = OCMStrictClassMock([RemotePostTag class]);
    OCMStub([tag name]).andReturn(@"name");
    OCMStub([tag tagDescription]).andReturn(@"description");

    NSString *endpoint = [NSString stringWithFormat:@"sites/%@/%@/new?context=edit", self.service.siteID, @"tags"];
    NSString *url = [self.service pathForEndpoint:endpoint
                                      withVersion:ServiceRemoteWordPressComRESTApiVersion_1_1];
    
    BOOL (^parametersCheckBlock)(id obj) = ^BOOL(NSDictionary *parameters) {
        return ([parameters isKindOfClass:[NSDictionary class]] && [[parameters objectForKey:@"name"] isEqualToString:tag.name]);
    };

    WordPressComRestApi *api = self.service.wordPressComRestApi;
    OCMStub([api post:[OCMArg isEqual:url]
           parameters:[OCMArg checkWithBlock:parametersCheckBlock]
              success:[OCMArg isNotNil]
              failure:[OCMArg isNotNil]]);
    
    [self.service createTag:tag
                    success:^(RemotePostTag * _Nonnull tag) {}
                    failure:^(NSError * _Nonnull error) {}];
}

- (void)testThatGetTagsWorks
{
    NSString *url = [self GETtaxonomyURLWithType:@"tags"];

    BOOL (^parametersCheckBlock)(id obj) = ^BOOL(NSDictionary *parameters) {
        return ([parameters isKindOfClass:[NSDictionary class]] && [[parameters objectForKey:@"number"] integerValue] == 1000);
    };

    WordPressComRestApi *api = self.service.wordPressComRestApi;
    OCMStub([api get:[OCMArg isEqual:url]
          parameters:[OCMArg checkWithBlock:parametersCheckBlock]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    [self.service getTagsWithSuccess:^(NSArray<RemotePostTag *> * _Nonnull tags) {}
                             failure:^(NSError * _Nonnull error) {}];
}

- (void)testThatGetTagsWithPagingWorks
{
    RemoteTaxonomyPaging *paging = OCMStrictClassMock([RemoteTaxonomyPaging class]);
    OCMStub([paging number]).andReturn(@100);
    OCMStub([paging offset]).andReturn(@0);
    OCMStub([paging page]).andReturn(@0);
    OCMStub([paging order]).andReturn(RemoteTaxonomyPagingOrderAscending);
    OCMStub([paging orderBy]).andReturn(RemoteTaxonomyPagingResultsOrderingByName);
    
    NSString *url = [self GETtaxonomyURLWithType:@"tags"];
    
    BOOL (^parametersCheckBlock)(id obj) = ^BOOL(NSDictionary *parameters) {
        if (![parameters isKindOfClass:[NSDictionary class]]) {
            return NO;
        }
        if (![[parameters objectForKey:@"number"] isEqual:paging.number]) {
            return NO;
        }
        if (![[parameters objectForKey:@"offset"] isEqual:paging.offset]) {
            return NO;
        }
        if (![[parameters objectForKey:@"page"] isEqual:paging.page]) {
            return NO;
        }
        if (![[parameters objectForKey:@"order"] isEqualToString:@"ASC"]) {
            return NO;
        }
        if (![[parameters objectForKey:@"order_by"] isEqualToString:@"name"]) {
            return NO;
        }
        return YES;
    };
    
    WordPressComRestApi *api = self.service.wordPressComRestApi;
    OCMStub([api get:[OCMArg isEqual:url]
          parameters:[OCMArg checkWithBlock:parametersCheckBlock]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    [self.service getTagsWithPaging:paging
                            success:^(NSArray<RemotePostTag *> * _Nonnull tags) {}
                            failure:^(NSError * _Nonnull error) {}];
}

- (void)testThatSearchTagsWithNameWorks
{
    NSString *url = [self GETtaxonomyURLWithType:@"tags"];
    NSString *searchName = @"tag name";
    
    BOOL (^parametersCheckBlock)(id obj) = ^BOOL(NSDictionary *parameters) {
        if (![parameters isKindOfClass:[NSDictionary class]]) {
            return NO;
        }
        if (![[parameters objectForKey:@"search"] isEqualToString:searchName]) {
            return NO;
        }
        return YES;
    };
    
    WordPressComRestApi *api = self.service.wordPressComRestApi;
    OCMStub([api get:[OCMArg isEqual:url]
          parameters:[OCMArg checkWithBlock:parametersCheckBlock]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    [self.service searchTagsWithName:searchName
                             success:^(NSArray<RemotePostTag *> * _Nonnull tags) {}
                             failure:^(NSError * _Nonnull error) {}];
}

@end
