#ifndef __SPM_TEST__
#define __SPM_TEST__

@interface SPMTest : NSObject
@property (nonatomic) NSString * targetName;
@property (nonatomic) NSString * className;
@property (nonatomic) NSString * functionName;
@property (nonatomic) NSString * result;
@property (nonatomic) NSString * filePath;
@property (nonatomic) NSNumber * fileOffset;

- (id) initWithDictionary: (NSDictionary *) info;
- (void) updateWithDictionary: (NSDictionary *) info;
- (NSString *) uniqueId;
- (NSString *) filter;
- (void) beginTest;
- (NSImage *) runIcon;

@end

#endif