#import <Foundation/Foundation.h>
#import <WordPressKit/WordPressComRESTAPIInterfacing.h>

@class WordPressComRestApi;

typedef NS_ENUM(NSInteger, WordPressComRESTAPIVersion) {
    WordPressComRESTAPIVersion_1_0 = 1000,
    WordPressComRESTAPIVersion_1_1 = 1001,
    WordPressComRESTAPIVersion_1_2 = 1002,
    WordPressComRESTAPIVersion_1_3 = 1003,
    WordPressComRESTAPIVersion_2_0 = 2000
};

NS_ASSUME_NONNULL_BEGIN

/**
 *  @class  ServiceRemoteREST
 *  @brief  Parent class for all REST service classes.
 */
@interface ServiceRemoteWordPressComREST : NSObject


/**
 *  @brief      The API object to use for communications.
 */
@property (nonatomic, strong, readonly) WordPressComRestApi *wordPressComRestApi;

/**
 *  @brief      The interface to the WordPress.com API to use for performing REST requests.
 *              This is meant to gradually replace `wordPressComRestApi`.
 */
@property (nonatomic, strong, readonly) id<WordPressComRESTAPIInterfacing> wordPressComRESTAPI;

/**
 *  @brief      Designated initializer.
 *
 *  @param      api     The API to use for communication.  Cannot be nil.
 *
 *  @returns    The initialized object.
 */
- (instancetype)initWithWordPressComRestApi:(WordPressComRestApi *)api;

#pragma mark - Request URL construction

/**
 *  @brief      Constructs the request URL for the specified API version and specified resource URL.
 *
 *  @param      endpoint        The URL of the resource for the request.  Cannot be nil.
 *  @param      apiVersion      The version of the API to use.
 *
 *  @returns    The request URL.
 */
- (NSString *)pathForEndpoint:(NSString *)endpoint
                  withVersion:(WordPressComRESTAPIVersion)apiVersion;

@end

NS_ASSUME_NONNULL_END
