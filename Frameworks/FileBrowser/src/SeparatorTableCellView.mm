#import "SeparatorTableCellView.h"
#import "FileItem.h"
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/OakFinderTag.h>
#import <TMFileReference/TMFileReference.h>

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
