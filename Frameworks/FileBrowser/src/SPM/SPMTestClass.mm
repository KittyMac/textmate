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
 	[self willChangeValueForKey:@"runIcon"];
}

- (NSString *) uniqueId {
	return [NSString stringWithFormat: @"%@.%@", _targetName, _className];
}

- (NSImage *) runIcon {
	NSString * imageName = @"TestsUnknownTemplate";
	if ([_result isEqualToString: @"passed"]) {
		imageName = @"TestsPassTemplate";
	}
	if ([_result isEqualToString: @"failed"]) {
		imageName = @"TestsFailTemplate";
	}
	NSImage * img = [NSImage imageNamed:imageName inSameBundleAsClass:[OakRolloverButton class]];
	[img setTemplate: NO];
	return img;
}

@end
