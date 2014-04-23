//
//  STKSettingsShareCell.h
//  Prism
//
//  Created by Joe Conway on 4/3/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"

@interface STKSettingsShareCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *networkImageView;
@property (weak, nonatomic) IBOutlet UILabel *networkTitleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;
- (IBAction)toggleNetwork:(id)sender;

@end
