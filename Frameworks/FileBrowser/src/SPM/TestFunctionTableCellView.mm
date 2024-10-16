#import "TestFunctionTableCellView.h"
#import <OakAppKit/NSImage Additions.h>
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/OakFinderTag.h>
#import <TMFileReference/TMFileReference.h>

#import "SPMManager.h"
#import "RunTestButton.h"
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
		
		_runButton = [[RunTestButton alloc] initWithFrame:NSZeroRect];
		
		NSStackView* stackView = [NSStackView stackViewWithViews:@[
			_openButton, textField, _runButton
		]];
		stackView.spacing = 4;

		[self addSubview:stackView];

		[textField setContentHuggingPriority:NSLayoutPriorityDefaultLow-1 forOrientation:NSLayoutConstraintOrientationHorizontal];

		[stackView.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor  constant: 4].active = YES;
		[stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8].active = YES;
		[stackView.topAnchor      constraintEqualToAnchor:self.topAnchor      constant: 0].active = YES;
		[stackView.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor   constant: 0].active = YES;
		
		[_openButton bind:NSImageBinding toObject:self withKeyPath:@"objectValue.test.fileIcon" options:nil];
		[_runButton bind:NSImageBinding toObject:self withKeyPath:@"objectValue.test.runIcon" options:nil];
		[textField bind:NSValueBinding toObject:self withKeyPath:@"objectValue.test.functionName" options:nil];
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
	SPMTest * _test;
}
@end

@implementation TestFunctionFileItem
+ (void)load
{
	[self registerClass:self forURLScheme:@"spmTestFunction"];
}

+ (id)makeObserverForURL:(NSURL*)url usingBlock:(void(^)(NSArray<NSURL*>*))handler
{
	return nil;
}

- (instancetype)initWithURL:(NSURL*)url
{
	if(self = [super initWithURL:url])
	{
		_test = [[SPMManager sharedInstance] existingTestAtURL: url];
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
	SPMObserver * observer = [[SPMManager sharedInstance] existingObserverAtURL: self.URL];
	[observer runTests: @[_test]];
}

- (BOOL)isDirectory
{
	return false;
}

- (NSString*)localizedName
{
	return _test.functionName;
}

- (NSURL*)parentURL
{
	return [NSURL fileURLWithPath:self.URL.path];
}

- (NSURL *) openFileURL {
	return [NSURL fileURLWithPath: _test.filePath];
}

@end