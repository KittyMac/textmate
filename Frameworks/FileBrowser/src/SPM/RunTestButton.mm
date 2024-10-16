#import "TestFunctionTableCellView.h"
#import <OakAppKit/NSImage Additions.h>
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/OakFinderTag.h>
#import <TMFileReference/TMFileReference.h>

#import "SPMManager.h"
#import "RunTestButton.h"

@interface RunTestButton ()
@property (nonatomic) NSImage* image;
@end

@implementation RunTestButton
- (instancetype)initWithFrame:(NSRect) frame
{
	if((self = [super initWithFrame:frame])) {
		_button = [[NSButton alloc] initWithFrame:frame];
		_button.refusesFirstResponder = YES;
		_button.buttonType = NSButtonTypeMomentaryChange;
		_button.bordered = NO;
		_button.imagePosition = NSImageOnly;
		_button.imageScaling = NSImageScaleProportionallyUpOrDown;
		_button.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		
		_progress = [[NSProgressIndicator alloc] initWithFrame:frame];
		_progress.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		_progress.indeterminate = true;
		_progress.usesThreadedAnimation = true;
		_progress.style = NSProgressIndicatorStyleSpinning;
		
		[self addSubview:_button];
		[self addSubview:_progress];
		
		[self.widthAnchor constraintEqualToConstant: 14].active = YES;
		[self.heightAnchor constraintEqualToConstant: 14].active = YES;
		
		[self setImage: NULL];
	}
	return self;
}

- (void) setImage: (NSImage *) value {
	_button.image = value;
	
	if (value == NULL || [value isEqual: spmTestsProgressImage]) {
		_button.hidden = true;
		_progress.hidden = false;
		[_progress startAnimation: NULL];
	} else {
		_button.hidden = false;
		_progress.hidden = true;
		[_progress stopAnimation: NULL];
	}
}

@end
