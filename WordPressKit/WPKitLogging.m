#import "WPKitLogging.h"
#import "WPKitLoggingPrivate.h"

int WPKitGetLoggingLevel() {
    return ddLogLevel;
}

void WPKitSetLoggingLevel(int level) {
    ddLogLevel = level;
}
