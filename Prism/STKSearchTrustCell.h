//
//  STKSearchTrustCell.h
//  Prism
//
//  Created by Jesse Stevens Black on 6/3/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"
#import "STKAvatarView.h"

@interface STKSearchTrustCell : STKTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet STKAvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UIButton *trustButton;

- (IBAction)toggleTrust:(id)sender;

@end
