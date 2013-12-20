//
//  STKDateCell.m
//  Prism
//
//  Created by Joe Conway on 12/13/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKDateCell.h"

@interface STKDateCell () <UITextFieldDelegate>
@property (nonatomic, strong) UIDatePicker *datePicker;
@end

@implementation STKDateCell

- (void)setDate:(NSDate *)date
{
    _date = date;
    if(_date)
        [[self textField] setText:[[self dateFormatter] stringFromDate:_date]];
}

- (void)cellDidLoad
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    _datePicker = [[UIDatePicker alloc] init];
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    [_datePicker addTarget:self
                    action:@selector(dateChanged:)
          forControlEvents:UIControlEventValueChanged];

    [[self textField] setInputView:_datePicker];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([self date])
        [[self datePicker] setDate:[self date]];
    else {
        [self setDate:[self defaultDate]];
        [[self datePicker] setDate:[self defaultDate]];
    }
    ROUTE(textField);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    ROUTE(textField);
    [[self textField] resignFirstResponder];
    return YES;
}

- (void)dateChanged:(UIDatePicker *)dp
{
    [self setDate:[dp date]];
    [[self textField] setText:[[self dateFormatter] stringFromDate:[self date]]];
    ROUTE(dp);
}

- (void)layoutContent
{
    
}

@end
