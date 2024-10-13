#import "TestFunctionTableCellView.h"
#import <OakAppKit/NSImage Additions.h>
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/OakFinderTag.h>
#import <TMFileReference/TMFileReference.h>

#import "SPMManager.h"
#import "../FileItem.h"

@interface TestFunctionTableCellView () <NSTextFieldDelegate>
@end

@implementation TestFunctionTableCellView
- (instancetype)init
{
	if((self = [super initWithFrame:NSZeroRect]))
	{
		_openButton = [[NSButton alloc] initWithFrame:NSZeroRect];
		_openButton.refusesFirstResponder = YES;
		_openButton.buttonType            = NSButtonTypeMomentaryChange;
		_openButton.bordered              = NO;
		_openButton.imagePosition         = NSImageOnly;
		_openButton.imageScaling          = NSImageScaleProportionallyUpOrDown;

		[_openButton.widthAnchor  constraintEqualToConstant:16].active = YES;
		[_openButton.heightAnchor constraintEqualToConstant:16].active = YES;

		NSTextField* textField = OakCreateLabel(@"", [NSFont controlContentFontOfSize:0]);
		textField.cell = [[NSTextFieldCell alloc] initTextCell:@""];
		[textField.cell setWraps:NO];
		[textField.cell setLineBreakMode:NSLineBreakByTruncatingMiddle];
		//textField.formatter = [[FileItemFormatter alloc] initWithTableCellView:self];
		
		_runButton = OakCreateTestUnknownButton();
		_runButton.refusesFirstResponder = YES;
		
		NSStackView* stackView = [NSStackView stackViewWithViews:@[
			// _openButton, textField
			textField,
			_runButton
		]];
		stackView.spacing = 4;

		[self addSubview:stackView];

		[textField setContentHuggingPriority:NSLayoutPriorityDefaultLow-1 forOrientation:NSLayoutConstraintOrientationHorizontal];

		[stackView.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor  constant: 4].active = YES;
		[stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8].active = YES;
		[stackView.topAnchor      constraintEqualToAnchor:self.topAnchor      constant: 0].active = YES;
		[stackView.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor   constant: 0].active = YES;
		
		[_runButton bind:NSImageBinding toObject:self withKeyPath:@"objectValue.runIcon" options:nil];
		[textField bind:NSValueBinding toObject:self withKeyPath:@"objectValue.displayName" options:nil];
	}
	return self;
}

- (void)runTest:(id)sender
{
	NSLog(@"runTest");
}

- (void)dealloc
{
	[_runButton unbind:NSImageBinding];
	[self.textField unbind:NSValueBinding];
}


@end


@interface TestFunctionFileItem : FileItem
{
	
}
@end

@implementation TestFunctionFileItem
+ (void)load
{
	[self registerClass:self forURLScheme:@"spmTestFunction"];
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
	// [SCMManager.sharedInstance removeObserver:_observer];
}

- (void)runTests:(id)sender
{
	NSLog(@"RUN TESTS - TEST FUNCTION");
}

- (BOOL)isDirectory
{
	return false;
}

- (NSString*)localizedName
{
	return super.localizedName;
}

- (NSURL*)parentURL
{
	return [NSURL fileURLWithPath:self.URL.path];
}
@end