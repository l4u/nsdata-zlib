@interface NSData (zlib)
- (NSData *)bbs_dataByDeflating;
- (NSData *)bbs_dataByInflatingWithError:(NSError *__autoreleasing *)error;
- (BOOL)bbs_writeDeflatedToFile:(NSString *)path
                          error:(NSError *__autoreleasing *)error;
- (BOOL)bbs_writeInflatedToFile:(NSString *)path
                          error:(NSError *__autoreleasing *)error;
@end
