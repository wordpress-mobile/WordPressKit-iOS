#import "NSDate+WordPressJSON.h"

@implementation NSDate (WordPressJSON)

// FIXME: This is here only for the benefit of dateWithWordPressComJSONString. Remove together with that.
+ (NSDateFormatter *)rfc3339DateFormatter {
    static NSDateFormatter *rfc3339DateFormatter;
    if (rfc3339DateFormatter == nil) {
        rfc3339DateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

        [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
        [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
        [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return rfc3339DateFormatter;
}

+ (instancetype)dateWithWordPressComJSONString:(NSString *)string {
    return [[self rfc3339DateFormatter] dateFromString:string];
}

@end
