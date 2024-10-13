#import "TestClassTableCellView.h"
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
		
		_runButton = OakCreateTestUnknownButton();
		_runButton.refusesFirstResponder = YES;

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
		/*
		_repository = [SCMManager.sharedInstance repositoryAtURL:[NSURL fileURLWithPath:url.path isDirectory:YES]];
		if(_repository && _repository.enabled == NO)
		{
			self.disambiguationSuffix = @" (disabled)";
		}
		else if(![self.URL.query hasSuffix:@"unstaged"] && ![self.URL.query hasSuffix:@"untracked"])
		{
			if(_repository)
			{
				__weak SCMStatusFileItem* weakSelf = self;
				_observer = [SCMManager.sharedInstance addObserverToRepositoryAtURL:_repository.URL usingBlock:^(SCMRepository* repository){
					[weakSelf updateBranchName];
				}];
			}
			else
			{
				self.disambiguationSuffix = @" (no status)";
			}
		}
		*/
	}
	return self;
}

- (void)dealloc
{
	// [SCMManager.sharedInstance removeObserver:_observer];
}

- (void)runTests:(id)sender
{
	NSLog(@"RUN TESTS - TEST CLASS");
}

- (NSString*)localizedName
{
	/*
	if([self.URL.query hasSuffix:@"unstaged"])
		return @"Uncommitted Changes";
	else if([self.URL.query hasSuffix:@"untracked"])
		return @"Untracked Items";
	else if(_repository)
		return [NSFileManager.defaultManager displayNameAtPath:_repository.URL.path];
*/
	return super.localizedName;
}

- (NSURL*)parentURL
{
	/*
	if([self.URL.query hasSuffix:@"unstaged"] || [self.URL.query hasSuffix:@"untracked"])
		return [NSURL URLWithString:[NSString stringWithFormat:@"scm://localhost%@/", [self.URL.path stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet]]];
	*/
	return [NSURL fileURLWithPath:self.URL.path];
}
@end

