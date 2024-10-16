#ifndef __SPM_TESTTARGET__
#define __SPM_TESTTARGET__

@interface SPMTestTarget : NSObject
@property (nonatomic) NSString * targetName;
@property (nonatomic) NSString * targetPath;
@property (nonatomic) NSString * result;

- (id) initWithDictionary: (NSDictionary *) info;
- (void) updateWithDictionary: (NSDictionary *) info;
- (NSString *) uniqueId;
- (NSString *) filter;
- (void) beginTest;
- (NSImage *) runIcon;

@end

#endif