@interface BBZlibError
    : NSError

extern NSString *const BBZlibErrorDomain;

typedef NS_ENUM(NSUInteger, BBZlibErrorCode) {
    BBZlibErrorCodeFileTooLarge = 0,
    BBZlibErrorCodeDeflationError = 1,
    BBZlibErrorCodeInflationError = 2,
    BBZlibErrorCodeCouldNotCreateFileError = 3,
};

@end
