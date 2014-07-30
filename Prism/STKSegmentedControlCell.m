//
//  STKSegmentedControlCell.m
//  Prism
//
//  Created by Joe Conway on 4/22/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKSegmentedControlCell.h"
#import "Mixpanel.h"

@implementation STKSegmentedControlCell

- (void)cellDidLoad
{
    
}


- (void)layoutContent
{

}

- (IBAction)controlChanged:(id)sender
{
    NSString *event = [NSString stringWithFormat:@"Segment %@ tapped", [self.control titleForSegmentAtIndex:self.control.selectedSegmentIndex]];
    [[Mixpanel sharedInstance] track:event];
    ROUTE(sender);
}
@end
