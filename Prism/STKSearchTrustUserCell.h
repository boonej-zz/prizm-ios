//
//  STKSearchTrustUserCell.h
//  Prism
//
//  Created by DJ HAYDEN on 5/2/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"
#import "STKAvatarView.h"
#import "STKUser.h"

@interface STKSearchTrustUserCell : STKTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet STKAvatarView *avatarView;

- (void)populateWithUser:(STKUser *)user;

@end
