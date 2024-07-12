#import <UIKit/UIKit.h>

@interface NSString (XMLExtensions)

+ (NSString *)wpkit_encodeXMLCharactersIn : (NSString *)source;
+ (NSString *)wpkit_decodeXMLCharactersIn : (NSString *)source;
- (NSString *)wpkit_stringByDecodingXMLCharacters;
- (NSString *)wpkit_stringByEncodingXMLCharacters;

@end
