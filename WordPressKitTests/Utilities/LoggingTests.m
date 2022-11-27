#import <XCTest/XCTest.h>

@import WordPressKit;

@interface CaptureLogs : NSObject<WordPressLoggingDelegate>

@property (nonatomic, strong) NSMutableArray *infoLogs;
@property (nonatomic, strong) NSMutableArray *errorLogs;

@end

@implementation CaptureLogs

- (instancetype)init
{
    if ((self = [super init])) {
        self.infoLogs = [NSMutableArray new];
        self.errorLogs = [NSMutableArray new];
    }
    return self;
}

- (void)logInfo:(NSString *)str
{
    [self.infoLogs addObject:str];
}

- (void)logError:(NSString *)str
{
    [self.errorLogs addObject:str];
}

@end

@interface LoggingTest : XCTestCase

@property (nonatomic, strong) CaptureLogs *logger;

@end

@implementation LoggingTest

- (void)setUp
{
    self.logger = [CaptureLogs new];
    WPKitSetLoggingDelegate(self.logger);
}

- (void)testLogging
{
    WPKitLogInfo(@"This is an info log");
    WPKitLogInfo(@"This is an info log %@", @"with an argument");
    XCTAssertEqualObjects(self.logger.infoLogs, (@[@"This is an info log", @"This is an info log with an argument"]));

    WPKitLogError(@"This is an error log");
    WPKitLogError(@"This is an error log %@", @"with an argument");
    XCTAssertEqualObjects(self.logger.errorLogs, (@[@"This is an error log", @"This is an error log with an argument"]));
}

- (void)testUnimplementedLoggingMethod
{
    XCTAssertNoThrow(WPKitLogVerbose(@"verbose logging is not implemented"));
}

- (void)testNoLogging
{
    WPKitSetLoggingDelegate(nil);
    XCTAssertNoThrow(WPKitLogInfo(@"this log should not be printed"));
    XCTAssertEqual(self.logger.infoLogs.count, 0);
}

@end
