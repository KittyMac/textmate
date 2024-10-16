#import "SPMObserver.h"
#import "SPMManager.h"
#import "SPMTestTarget.h"
#include <io/path.h>
#include <io/exec.h>
#import <OakAppKit/NSImage Additions.h>
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/OakFinderTag.h>


@implementation SPMTestTarget

- (instancetype) initWithDictionary: (NSDictionary *) info {
	self = [super init];
	if (self) {
		_targetName = info[@"targetName"];
		_targetPath = info[@"targetPath"];
		_result = info[@"result"];
	}
	return self;
}

- (void) updateWithDictionary: (NSDictionary *) info {
	_targetName = info[@"targetName"];

 	[self willChangeValueForKey:@"runIcon"];
	_result = info[@"result"];
 	[self didChangeValueForKey:@"runIcon"];
}

- (NSString *) uniqueId {
	return _targetName;
}

- (NSString *) filter {
	return _targetName;
}

- (void) beginTest {
 	[self willChangeValueForKey:@"runIcon"];
	_result = @"progress";
 	[self didChangeValueForKey:@"runIcon"];
}

- (NSImage *) runIcon {
	if ([_result isEqualToString: @"progress"]) {
		return spmTestsProgressImage;
	}
	if ([_result isEqualToString: @"passed"]) {
		return spmTestsPassImage;
	}
	if ([_result isEqualToString: @"failed"]) {
		return spmTestsFailImage;
	}
	if ([_result isEqualToString: @"warn"]) {
		return spmTestsWarnImage;
	}
	return spmTestsUnknownImage;
}

@end
