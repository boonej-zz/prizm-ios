//
//  STKHomeCell.m
//  Prism
//
//  Created by Joe Conway on 11/13/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKHomeCell.h"
#import "STKPost.h"
#import "STKProfile.h"
#import "STKRelativeDateConverter.h"

@implementation STKHomeCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)populateWithPost:(STKPost *)p
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [[self contentImageView] setUrlString:[p imageURLString]];
    
    [[[self headerView] avatarView] setUrlString:[[p creatorProfile] profilePhotoPath]];
    [[[self headerView] posterLabel] setText:[[p creatorProfile] name]];
    [[[self headerView] timeLabel] setText:[STKRelativeDateConverter relativeDateStringFromDate:[p datePosted]]];
    //    if([p externalSystemID])
    //[[[c headerView] sourceLabel] setText:[p postOrigin]];
    [[[self headerView] postTypeView] setImage:[p typeImage]];
    
    [[self commentCountLabel] setText:[p commentCount]];
    [[self likeCountLabel] setText:[p likeCount]];
}

- (IBAction)toggleLike:(id)sender
{
    ROUTE(sender);
}

- (IBAction)showComments:(id)sender
{
    ROUTE(sender);
}

- (IBAction)addToPrism:(id)sender
{
    ROUTE(sender);
}

- (IBAction)sharePost:(id)sender
{
    ROUTE(sender);
}

- (IBAction)pinPost:(id)sender
{
    ROUTE(sender);
}

- (IBAction)imageTapped:(id)sender
{
    ROUTE(sender);
}

- (void)cellDidLoad
{
    static UIImage *fadeImage = nil;
    if(!fadeImage) {
        UIGraphicsBeginImageContext(CGSizeMake(2, 2));
        [[UIColor colorWithRed:0.06 green:0.15 blue:0.40 alpha:0.95] set];
        UIRectFill(CGRectMake(0, 0, 2, 2));
        fadeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [[[self headerView] backdropFadeView] setImage:fadeImage];
    
    [[self headerView] setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.33]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
