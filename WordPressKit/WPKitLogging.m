#import "WPKitLogging.h"
#import "WPKitLoggingPrivate.h"

DDLogLevel WPKitGetLoggingLevel() {
    return ddLogLevel;
}

void WPKitSetLoggingLevel(DDLogLevel level) {
    ddLogLevel = level;
}
