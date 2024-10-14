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

- (void) updateWithDictionary: (NSDictionary *) info {
	_targetName = info[@"targetName"];
	_className = info[@"className"];
	_functionName = info[@"functionName"];
	_filePath = info[@"filePath"];
	_fileOffset = info[@"fileOffset"];
	
 	[self willChangeValueForKey:@"runIcon"];
	_result = info[@"result"];
 	[self willChangeValueForKey:@"runIcon"];
}

- (NSString *) uniqueId {
	return [NSString stringWithFormat: @"%@.%@ %@", _targetName, _className, _functionName];
}

- (NSImage *) runIcon {
	if ([_result isEqualToString: @"passed"]) {
		return spmTestsPassImage;
	}
	if ([_result isEqualToString: @"failed"]) {
		return spmTestsFailImage;
	}
	return spmTestsUnknownImage;
}

@end
