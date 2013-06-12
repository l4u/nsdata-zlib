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

- (void)testRandom
{
    dispatch_apply(50000, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^(size_t i) {
                       uint32_t len = getRandInt(65536 * 2 + 2);
                       [self helperTestDataWithLength:len];
                       NSLog(@"Small i = %zd, len = %.2f KB", i, len / 1024.);
                   });
    dispatch_apply(10000, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^(size_t i) {
                       uint32_t len = getRandInt(50 * 1024 * 1024);
                       [self helperTestDataWithLength:len];
                       NSLog(@"Large i = %zd, len = %.2f MB", i, len / (1024. * 1024));
                   });
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
        [orig writeDeflatedToFile:deflatedFileName
                            error:&error];
        STAssertNil(error, error.localizedDescription);
        NSData *deflated = [NSData dataWithContentsOfFile:deflatedFileName];
        NSString *inflatedFileName = getTempFilenamePath();
        [deflated writeInflatedToFile:inflatedFileName
                                error:&error];
        STAssertNil(error, error.localizedDescription);
        NSData *inflated = [NSData dataWithContentsOfFile:inflatedFileName];
        STAssertTrue([inflated isEqualToData:orig], @"Mismatch for length: %d", length);
        deletePath(deflatedFileName);
        deletePath(inflatedFileName);
    }
}

- (void)helperTestDataWithLength:(NSUInteger)length
{
    @autoreleasepool {
        NSData *orig = getRandomBytes(length);
        NSData *deflated = [orig dataByDeflating];
        NSError *error;
        NSData *inflated = [deflated dataByInflatingWithError:&error];
        STAssertNil(error, error.localizedDescription);
        STAssertTrue([inflated isEqualToData:orig], @"Mismatch for length: %d", length);
    }
}

static NSString *getTempFilenamePath()
{
    static const char *tmpDirPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tmpDirPath = [[[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory
                                                               inDomains:NSUserDomainMask] lastObject] path] UTF8String];
    });
    char *fname = tempnam(tmpDirPath, "zlibTestTemp");
    NSString *tmpFilePath = [NSString stringWithUTF8String:fname];
    free(fname);
    return tmpFilePath;
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
