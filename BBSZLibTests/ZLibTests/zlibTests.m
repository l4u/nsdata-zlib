#import "NSData+zlib.h"

#import "zlibTests.h"

@implementation zlibTests

- (void)testZero
{
    [self helperTestFileWithLength:0];
    [self helperTestDataWithLength:0];
}

- (void)testOne
{
    [self helperTestFileWithLength:1];
    [self helperTestDataWithLength:1];
}

- (void)testChunk
{
    [self helperTestFileWithLength:65535];
    [self helperTestFileWithLength:65536];
    [self helperTestFileWithLength:65537];
    [self helperTestDataWithLength:65535];
    [self helperTestDataWithLength:65536];
    [self helperTestDataWithLength:65537];
}

- (void)testSmallInMemory
{
    dispatch_apply(50000, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^(size_t i) {
                       uint32_t len = getRandInt(65536 * 2);
                       [self helperTestDataWithLength:len];
                       NSLog(@"Small - i = %zd, len = %.2f KiB", i, len / 1024.);
                   });

}

- (void)testLargeInMemory
{
    dispatch_apply(10000, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^(size_t i) {
                       uint32_t len = getRandInt(50 * 1024 * 1024);
                       [self helperTestDataWithLength:len];
                       NSLog(@"Large - i = %zd, len = %.2f MiB", i, len / (1024. * 1024));
                   });
}

- (void)testFiles
{
    for (NSUInteger i = 0; i < 10; i++) {
        [self helperTestFileWithLength:getRandInt(50 * 1024 * 1024)];
    }
}

- (void)helperTestFileWithLength:(NSUInteger)length
{
    @autoreleasepool {
        NSData *orig = getRandomBytes(length);
        NSString *deflatedFileName = getTempFilenamePath();
        NSError *error;
        BOOL success = [orig bbs_writeDeflatedToFile:deflatedFileName
                                               error:&error];
        XCTAssertNil(error, @"%@", error.localizedDescription);
        XCTAssertTrue(success, @"Deflation failed");

        NSData *deflated = [NSData dataWithContentsOfFile:deflatedFileName];
        NSString *inflatedFileName = getTempFilenamePath();
        success = [deflated bbs_writeInflatedToFile:inflatedFileName
                                              error:&error];
        XCTAssertNil(error, @"%@", error.localizedDescription);
        XCTAssertTrue(success, @"Inflation failed");

        NSData *inflated = [NSData dataWithContentsOfFile:inflatedFileName];
        XCTAssertTrue([inflated isEqualToData:orig], @"Mismatch for length: %lu", length);
        deletePath(deflatedFileName);
        deletePath(inflatedFileName);
    }
}

- (void)helperTestDataWithLength:(NSUInteger)length
{
    @autoreleasepool {
        NSData *orig = getRandomBytes(length);
        NSError *error;
        NSData *deflated = [orig bbs_dataByDeflatingWithError:&error];
        XCTAssertNil(error, @"%@", error.localizedDescription);
        NSData *inflated = [deflated bbs_dataByInflatingWithError:&error];
        XCTAssertNil(error, @"%@", error.localizedDescription);
        XCTAssertTrue([inflated isEqualToData:orig], @"Mismatch for length: %lu", length);
    }
}

static NSString *getTempFilenamePath()
{
    char templateBuf[PATH_MAX];
    static NSURL *templateURL;
    if (!templateURL) {
        NSString *tmpDir = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory
                                                                    inDomains:NSUserDomainMask] lastObject] path];
        templateURL = [NSURL fileURLWithPathComponents:@[tmpDir, @"zlibTestTemp.XXXXXXXX"]];
    }
    [templateURL getFileSystemRepresentation:templateBuf
                                   maxLength:PATH_MAX];
    int success = mkstemp(templateBuf);
    if (success == -1) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Could not create temp file"
                                     userInfo:nil];
    }
    return [NSString stringWithUTF8String:templateBuf];
}

static void deletePath(NSString *path)
{
    [[NSFileManager defaultManager] removeItemAtPath:path
                                               error:nil];
}

static NSData *getRandomBytes(NSUInteger length)
{
    static dispatch_once_t onceToken;
    static char randBytes[100 * 1024 * 1024];
    dispatch_once(&onceToken, ^{
        arc4random_buf(randBytes, sizeof(randBytes));
    });
    char *buf = malloc(length);
    for (NSUInteger i = 0; i < length; i++) {
        buf[i] = randBytes[getRandInt(sizeof(randBytes))];
    }
    return [NSData dataWithBytesNoCopy:buf
                                length:length
                          freeWhenDone:YES];
}

static uint32_t getRandInt(uint32_t upper)
{
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t sema;
    dispatch_once(&onceToken, ^{
        sema = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    uint32_t n = arc4random_uniform(upper);
    dispatch_semaphore_signal(sema);
    return n;
}

@end
