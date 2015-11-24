//
//  STKTextFieldCell.m
//  Prism
//
//  Created by Joe Conway on 12/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKTextFieldCell.h"
#import "STKPhoneNumberFormatter.h"

@interface STKTextFieldCell ()
@property (weak, nonatomic) IBOutlet UIView *backdropView;
@property (nonatomic, strong) UIGestureRecognizer *tapRecognizer;

@end


@implementation STKTextFieldCell

- (void)setBackdropColor:(UIColor *)backdropColor
{
    _backdropColor = backdropColor;
    [[self backdropView] setBackgroundColor:_backdropColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    ROUTE(textField);
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    ROUTE(textField);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:NO];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Ugly
    if([[self textFormatter] isKindOfClass:[STKPhoneNumberFormatter class]]) {
        // This really is just nonsense
        
        NSString *convertString = nil;
        if([string isEqualToString:@""]) {
            // If we are deleting, account for ()-
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"[^0-9]" options:0 error:nil];
            NSString *trimmedBeforeRange = [regex stringByReplacingMatchesInString:[textField text] options:0 range:NSMakeRange(0, range.location + range.length) withTemplate:@""];
            
            long offset = [[textField text] length] - [trimmedBeforeRange length];
            range.location -= offset;
            NSString *rawString = [regex stringByReplacingMatchesInString:[textField text] options:0 range:NSMakeRange(0, [[textField text] length]) withTemplate:@""];
            convertString = [rawString stringByReplacingCharactersInRange:range withString:string];
        } else {
            convertString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        }
        
        
        NSString *str = [[self textFormatter] stringForObjectValue:convertString];
        
        [textField setText:str];
        [textField sendActionsForControlEvents:UIControlEventEditingChanged];
        /*
        UITextPosition *start = [textField positionFromPosition:[textField beginningOfDocument]
                                                         offset:indexToInsertCursor];
        UITextPosition *end = [textField positionFromPosition:start offset:0];
        [textField setSelectedTextRange:[textField textRangeFromPosition:start toPosition:end]];*/
        
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    ROUTE(textField);
}


- (void)cellDidLoad
{
    if (!self.tapRecognizer) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [[self contentView] addGestureRecognizer:self.tapRecognizer];
        [self.tapRecognizer setCancelsTouchesInView:NO];
    }
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)tap:(id)sender
{
    [[self textField] becomeFirstResponder];
}

- (void)layoutContent
{
    
}

@end
