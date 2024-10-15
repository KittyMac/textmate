#import "SPMObserver.h"
#import "SPMManager.h"
#import "SPMTestClass.h"
#include <io/path.h>
#include <io/exec.h>
#import <OakAppKit/NSImage Additions.h>
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/OakFinderTag.h>


@implementation SPMTestClass

- (instancetype) initWithDictionary: (NSDictionary *) info {
	self = [super init];
	if (self) {
		_targetName = info[@"targetName"];
		_className = info[@"className"];
		_result = info[@"result"];
	}
	return self;
}

- (void) updateWithDictionary: (NSDictionary *) info {
	_targetName = info[@"targetName"];
	_className = info[@"className"];

 	[self willChangeValueForKey:@"runIcon"];
	_result = info[@"result"];
 	[self didChangeValueForKey:@"runIcon"];
}

- (NSString *) uniqueId {
	return [NSString stringWithFormat: @"%@.%@", _targetName, _className];
}

- (NSString *) filter {
	return [NSString stringWithFormat:@"%@", _className];
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
	return spmTestsUnknownImage;
}

@end
