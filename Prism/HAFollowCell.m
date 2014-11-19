//
//  HAFollowCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/27/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAFollowCell.h"
#import "STKAvatarView.h"
#import "STKUser.h"
#import "STKPost.h"
#import "STKResolvingImageView.h"
#import "STKContentStore.h"
#import "STKUserStore.h"

@interface HAFollowCell()

@property (nonatomic, weak) IBOutlet STKAvatarView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;

@property (nonatomic, weak) IBOutlet UIImageView *luminaryIcon;
@property (nonatomic, weak) IBOutlet UIButton *followButton;

- (IBAction)followTapped:(id)sender;
- (IBAction)leftPostTapped:(id)sender;
- (IBAction)centerPostTapped:(id)sender;
- (IBAction)rightPostTapped:(id)sender;
- (IBAction)avatarTapped:(id)sender;

@end

@implementation HAFollowCell


- (void)awakeFromNib
{
    // Initialization code
    [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
    [self.nameLabel setTextColor:[UIColor HATextColor]];
    [self.locationLabel setTextColor:[UIColor HATextColor]];
    [self.leftImage setLoadingContentMode:UIViewContentModeCenter];
    [self.centerImage setLoadingContentMode:UIViewContentModeCenter];
    [self.rightImage setLoadingContentMode:UIViewContentModeCenter];
    [self.leftImage setPreferredSize:STKImageStoreThumbnailMedium];
    [self.centerImage setPreferredSize:STKImageStoreThumbnailMedium];
    [self.rightImage setPreferredSize:STKImageStoreThumbnailMedium];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setProfile:(STKUser *)profile
{
    _profile = profile;
    [self.nameLabel setText:profile.name];
    [self.avatarView setUrlString:[profile profilePhotoPath]];
    [self.luminaryIcon setHidden:![profile isLuminary]];
    NSString *location = [NSString stringWithFormat:@"%@, %@", profile.city, profile.state];
    [self.locationLabel setText:location];
    if([[self profile] isFollowedByUser:[[STKUserStore store] currentUser]]) {
        [[self followButton] setTitle:@"Following" forState:UIControlStateNormal];
        [[self followButton] setImage:[UIImage imageNamed:@"following.png"]
                          forState:UIControlStateNormal];
        [[self followButton] setImageEdgeInsets:UIEdgeInsetsMake(0, 66, 0, 0)];
    } else {
        [[self followButton] setTitle:@"Follow" forState:UIControlStateNormal];
        [[self followButton] setImage:[UIImage imageNamed:@"arrowblue.png"]
                          forState:UIControlStateNormal];
        [[self followButton] setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
    }
}

- (void)prepareForReuse
{
    self.leftImage.image = nil;
    self.centerImage.image = nil;
    self.rightImage.image = nil;
}

- (void)setPosts:(NSArray *)posts
{
    if ([posts isKindOfClass:[NSArray class]]) {
        _posts = posts;
        [posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            STKPost *post = obj;
            switch (idx) {
                case 0:
                    [self.leftImage setLoadingImage:[post disabledTypeImage]];
                    [self.leftImage setUrlString:post.imageURLString];
                    break;
                case 1:
                    [self.centerImage setLoadingImage:[post disabledTypeImage]];
                    [self.centerImage setUrlString:post.imageURLString];
                    break;
                case 2:
                    [self.rightImage setLoadingImage:[post disabledTypeImage]];
                    [self.rightImage setUrlString:post.imageURLString];
                    break;
            }
        }];
    }
}

- (void)setFrame:(CGRect)frame
{
    frame.origin.x += 5;
    frame.size.width -= 10;
    frame.origin.y += 2;
    frame.size.height -= 4;
    [super setFrame:frame];
}

- (IBAction)followTapped:(id)sender
{
    ROUTE(sender);
}

- (IBAction)leftPostTapped:(id)sender
{
    ROUTE(sender);
}

- (IBAction)centerPostTapped:(id)sender
{
    ROUTE(sender);
}

- (IBAction)rightPostTapped:(id)sender
{
    ROUTE(sender);
}

- (void)avatarTapped:(id)sender
{
    ROUTE(sender);
}

@end
