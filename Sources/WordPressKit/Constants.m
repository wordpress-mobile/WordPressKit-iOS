#import "Constants.h"

/// Error domain of `NSError` instances that are converted from `WordPressComRestApiEndpointError`
/// and `WordPressAPIError<WordPressComRestApiEndpointError>` instances.
///
/// See `extension WordPressComRestApiEndpointError: CustomNSError` for context.
//
// FIXME: This is now part of CoreAPI and should be removed, right?
NSString *WordPressComRestApiErrorDomain = @"WordPressKit.WordPressComRestApiError";
