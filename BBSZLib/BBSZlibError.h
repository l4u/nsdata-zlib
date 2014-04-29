@interface BBSZlibError
    : NSError

extern NSString *const BBSZlibErrorDomain;

typedef NS_ENUM(NSUInteger, BBSZlibErrorCode) {
    BBSZlibErrorCodeFileTooLarge = 0,
    BBSZlibErrorCodeDeflationError = 1,
    BBSZlibErrorCodeInflationError = 2,
    BBSZlibErrorCodeCouldNotCreateFileError = 3,
};

@end
