#import "TestTargetTableCellView.h"
#import <OakAppKit/NSImage Additions.h>
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/OakFinderTag.h>
#import <TMFileReference/TMFileReference.h>

#import "SPMManager.h"
#import "RunTestButton.h"
#import "../FileItem.h"

@interface TestTargetTableCellView () <NSTextFieldDelegate>
@end

@implementation TestTargetTableCellView
- (instancetype)init
{
	if((self = [super initWithFrame:NSZeroRect]))
	{
		NSTextField* textField = OakCreateLabel(@"", [NSFont controlContentFontOfSize:0]);
		textField.cell = [[NSTextFieldCell alloc] initTextCell:@""];
		[textField.cell setWraps:NO];
		[textField.cell setLineBreakMode:NSLineBreakByTruncatingMiddle];
		
		_runButton = [[RunTestButton alloc] initWithFrame:NSZeroRect];

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
		
		[_runButton bind:NSImageBinding toObject:self withKeyPath:@"objectValue.testTarget.runIcon" options:nil];
		[textField bind:NSValueBinding toObject:self withKeyPath:@"objectValue.testTarget.targetName" options:nil];
	}
	return self;
}

- (void)dealloc
{

}

@end


@interface TestTargetFileItem : FileItem
{
	SPMTestTarget * _testTarget;
}
@end

@implementation TestTargetFileItem
+ (void)load
{
	[self registerClass:self forURLScheme:@"spmTestTarget"];
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
		_testTarget = [[SPMManager sharedInstance] existingTestTargetAtURL: url];
		self.sortingGroup = 1;
	}
	return self;
}

- (void)dealloc
{
	
}

- (void)runTests:(id)sender
{
	NSLog(@"RUN TESTS - TEST TARGET");
	SPMObserver * observer = [[SPMManager sharedInstance] existingObserverAtURL: self.URL];
	//[observer runTests: @[_testTarget]];	
	[observer runTargetTests: _testTarget];	
}

- (NSString*)localizedName
{
	return _testTarget.targetName;
}

- (NSURL*)parentURL
{
	return [NSURL fileURLWithPath:self.URL.path];
}
@end

