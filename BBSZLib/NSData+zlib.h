@interface NSData (zlib)

extern NSString *const BBSZlibErrorDomain;
extern NSString *const BBSZlibErrorInfoKey;

typedef NS_ENUM(NSUInteger, BBSZlibErrorCode) {
    BBSZlibErrorCodeFileTooLarge = 0,
    BBSZlibErrorCodeDeflationError = 1,
    BBSZlibErrorCodeInflationError = 2,
    BBSZlibErrorCodeCouldNotCreateFileError = 3,
};

- (NSData *)bbs_dataByDeflatingWithError:(NSError *__autoreleasing *)error;
- (NSData *)bbs_dataByInflatingWithError:(NSError *__autoreleasing *)error;
- (BOOL)bbs_writeDeflatedToFile:(NSString *)path
                          error:(NSError *__autoreleasing *)error;
- (BOOL)bbs_writeInflatedToFile:(NSString *)path
                          error:(NSError *__autoreleasing *)error;
@end
