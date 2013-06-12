@interface NSData (zlib)

- (NSData *)dataByDeflating;
- (NSData *)dataByInflatingWithError:(NSError * __autoreleasing *)error;
- (BOOL)writeDeflatedToFile:(NSString *)path
                      error:(NSError * __autoreleasing *)error;
- (BOOL)writeInflatedToFile:(NSString *)path
                      error:(NSError * __autoreleasing *)error;
@end
