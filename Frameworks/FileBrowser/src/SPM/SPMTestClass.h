#ifndef __SPM_TESTCLASS__
#define __SPM_TESTCLASS__

@interface SPMTestClass : NSObject
@property (nonatomic) NSString * targetName;
@property (nonatomic) NSString * className;
@property (nonatomic) NSString * result;

- (id) initWithDictionary: (NSDictionary *) info;
- (void) updateWithDictionary: (NSDictionary *) info;
- (NSString *) uniqueId;
- (NSString *) filter;
- (void) beginTest;
- (NSImage *) runIcon;

@end

#endif