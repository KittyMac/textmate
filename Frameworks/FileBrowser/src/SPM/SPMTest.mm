#import "SPMObserver.h"
#import "SPMManager.h"
#import "SPMTest.h"
#include <io/path.h>
#include <io/exec.h>
#import <OakAppKit/NSImage Additions.h>
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/OakFinderTag.h>


@implementation SPMTest

- (instancetype) initWithDictionary: (NSDictionary *) info {
	self = [super init];
	if (self) {
		_targetName = info[@"targetName"];
		_className = info[@"className"];
		_functionName = info[@"functionName"];
		_result = info[@"result"];
		_filePath = info[@"filePath"];
		_fileOffset = info[@"fileOffset"];
	}
	return self;
}

- (NSString *) uniqueId {
	return [NSString stringWithFormat: @"%@.%@ %@", _targetName, _className, _functionName];
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
