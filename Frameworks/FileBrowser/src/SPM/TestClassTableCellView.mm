#import "TestClassTableCellView.h"
#import <OakAppKit/NSImage Additions.h>
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/OakFinderTag.h>
#import <TMFileReference/TMFileReference.h>

#import "SPMManager.h"
#import "../FileItem.h"

@interface TestClassTableCellView () <NSTextFieldDelegate>
@end

@implementation TestClassTableCellView
- (instancetype)init
{
	if((self = [super initWithFrame:NSZeroRect]))
	{
		NSTextField* textField = OakCreateLabel(@"", [NSFont controlContentFontOfSize:0]);
		textField.cell = [[NSTextFieldCell alloc] initTextCell:@""];
		[textField.cell setWraps:NO];
		[textField.cell setLineBreakMode:NSLineBreakByTruncatingMiddle];
		
		_runButton = [[NSButton alloc] initWithFrame:NSZeroRect];
		_runButton.refusesFirstResponder = YES;
		_runButton.buttonType            = NSButtonTypeMomentaryChange;
		_runButton.bordered              = NO;
		_runButton.imagePosition         = NSImageOnly;
		_runButton.imageScaling          = NSImageScaleProportionallyUpOrDown;

		NSStackView* stackView = [NSStackView stackViewWithViews:@[
			textField, _runButton
		]];
		stackView.spacing = 4;

		[self addSubview:stackView];

		[textField setContentHuggingPriority:NSLayoutPriorityDefaultLow-1 forOrientation:NSLayoutConstraintOrientationHorizontal];

		[stackView.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor  constant: 4].active = YES;
		[stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8].active = YES;
		[stackView.topAnchor      constraintEqualToAnchor:self.topAnchor      constant: 0].active = YES;
		[stackView.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor   constant: 0].active = YES;
		
		[_runButton bind:NSImageBinding toObject:self withKeyPath:@"objectValue.runIcon" options:nil];
		[textField bind:NSValueBinding        toObject:self withKeyPath:@"objectValue.displayName" options:nil];
	}
	return self;
}

- (void)dealloc
{

}

@end


@interface TestClassFileItem : FileItem
{
	
}
@end

@implementation TestClassFileItem
+ (void)load
{
	[self registerClass:self forURLScheme:@"spmTestClass"];
}

+ (id)makeObserverForURL:(NSURL*)url usingBlock:(void(^)(NSArray<NSURL*>*))handler
{
	// Auto-detect the type of directory this is and use the correct observer for it
	SPMObserver * observer = [[SPMManager sharedInstance] observerAtURL: url usingBlock: handler];
	if (observer != NULL) {
		return observer;
	}
	
	return nil;
}

- (instancetype)initWithURL:(NSURL*)url
{
	if(self = [super initWithURL:url])
	{
		self.sortingGroup = 1;
	}
	return self;
}

- (void)dealloc
{
	
}

- (void)runTests:(id)sender
{
	NSLog(@"RUN TESTS - TEST CLASS");
	
	SPMObserver * observer = [[SPMManager sharedInstance] existingObserverAtURL: self.URL];
	[observer runTests: @[]];
	
}

- (NSImage *) runIcon {
	NSString * imageName = @"TestsUnknownTemplate";
	
	// If all children passed, then we should show as passed
	// If any child failed, then we should show as failed
	// If no children have been run yet, show as unknown
	NSArray * tests = [[SPMManager sharedInstance] existingTestsAtURL: self.URL];
	if ([tests count] > 0) {
		for (SPMTest * test in tests) {
			if ([test.result isEqualToString:@"failed"]) {
				imageName = @"TestsFailTemplate";
			} else if ([test.result isEqualToString:@"passed"] && [imageName isEqualToString:@"TestsUnknownTemplate"]) {
				imageName = @"TestsPassTemplate";
			}
		}
	}
	
	NSImage * img = [NSImage imageNamed:imageName inSameBundleAsClass:[OakRolloverButton class]];
	[img setTemplate: NO];
	return img;
}


- (NSString*)localizedName
{
	return [self.URL queryForKey:@"className"];
}

- (NSURL*)parentURL
{
	return [NSURL fileURLWithPath:self.URL.path];
}
@end

