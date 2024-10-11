#import "TestClassTableCellView.h"
#import <OakAppKit/OakUIConstructionFunctions.h>
#import <OakAppKit/OakFinderTag.h>
#import <TMFileReference/TMFileReference.h>

@interface TestClassTableCellView () <NSTextFieldDelegate>
@end

@implementation TestClassTableCellView
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

		NSStackView* stackView = [NSStackView stackViewWithViews:@[
			// _openButton, textField
			textField
		]];
		stackView.spacing = 4;

		[self addSubview:stackView];

		[textField setContentHuggingPriority:NSLayoutPriorityDefaultLow-1 forOrientation:NSLayoutConstraintOrientationHorizontal];

		[stackView.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor  constant: 4].active = YES;
		[stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8].active = YES;
		[stackView.topAnchor      constraintEqualToAnchor:self.topAnchor      constant: 0].active = YES;
		[stackView.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor   constant: 0].active = YES;
		
		//[_openButton bind:NSImageBinding      toObject:self withKeyPath:@"fileReference.icon"                options:nil];
		[textField bind:NSValueBinding        toObject:self withKeyPath:@"objectValue.displayName" options:nil];
		
		/*
		[_openButton bind:NSImageBinding      toObject:self withKeyPath:@"fileReference.icon"                options:nil];
		[textField bind:NSValueBinding        toObject:self withKeyPath:@"objectValue.editingAndDisplayName" options:nil];
		[textField bind:NSEditableBinding     toObject:self withKeyPath:@"objectValue.canRename"             options:nil];
		[textField bind:NSToolTipBinding      toObject:self withKeyPath:@"objectValue.toolTip"               options:nil];
		[_closeButton bind:NSHiddenBinding    toObject:self withKeyPath:@"fileReference.closable"            options:@{ NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName }];
*/
		//self.textField = textField;

		/*
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
		]];*/
	}
	return self;
}

- (void)dealloc
{

}

@end
