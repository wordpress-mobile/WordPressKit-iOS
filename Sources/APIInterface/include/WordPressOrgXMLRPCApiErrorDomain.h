#import <Foundation/Foundation.h>

/// Error domain of `NSError` instances that are converted from `WordPressOrgXMLRPCApiError`
/// and `WordPressAPIError<WordPressOrgXMLRPCApiError>` instances.
///
/// This matches the compiler generated value and is used to ensure consistent error domain across error types and SPM or Framework build modes.
///
/// See `extension WordPressComRestApiEndpointError: CustomNSError` in CoreAPI package for context.
static NSString *const _Nonnull WordPressOrgXMLRPCApiErrorDomain = @"WordPressKit.WordPressOrgXMLRPCApiError";
