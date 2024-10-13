#import "SeparatorTableCellView.h"
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/OakFinderTag.h>
#import <TMFileReference/TMFileReference.h>

#import "SPMManager.h"
#import "../FileItem.h"

@interface SeparatorTableCellView () <NSTextFieldDelegate>
@end

@implementation SeparatorTableCellView
- (instancetype)init
{
	if((self = [super initWithFrame:NSZeroRect]))
	{
		NSView * separatorLine = [[NSView alloc] init];
		
		separatorLine.wantsLayer = true;
		separatorLine.layer.backgroundColor = CGColorCreateGenericGray(0.50, 0.50);
		
		[self addSubview: separatorLine];

		// Setup constraints for separatorLine
		separatorLine.translatesAutoresizingMaskIntoConstraints = NO;
		[NSLayoutConstraint activateConstraints:@[
		   [separatorLine.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
		   [separatorLine.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
		   [separatorLine.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
		   [separatorLine.heightAnchor constraintEqualToConstant:1]
		]];
	}
	return self;
}

- (void)dealloc
{

}

@end

@interface SeparatorFileItem : FileItem
{
	
}
@end

@implementation SeparatorFileItem
+ (void)load
{
	[self registerClass:self forURLScheme:@"separator"];
}

+ (id)makeObserverForURL:(NSURL*)url usingBlock:(void(^)(NSArray<NSURL*>*))handler
{
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
@end