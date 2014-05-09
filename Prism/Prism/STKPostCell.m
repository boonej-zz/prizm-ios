//
//  STKHomeCell.m
//  Prism
//
//  Created by Joe Conway on 11/13/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKPostCell.h"
#import "STKPost.h"
#import "STKRelativeDateConverter.h"
#import "STKAvatarView.h"
#import "STKUserStore.h"
#import "STKHashTag.h"
#import "STKGradientView.h"

@interface STKPostCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashTagHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashTagTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;
@property (weak, nonatomic) IBOutlet STKGradientView *hashTagContainer;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (nonatomic, weak) STKPost *post;
@end

@implementation STKPostCell

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
    [self setPost:p];
    
    [[self contentImageView] setUrlString:[p imageURLString]];
    
    if(![self displayFullBleed]) {
        [[[self headerView] avatarView] setUrlString:[[p creator] profilePhotoPath]];
        [[[self headerView] posterLabel] setText:[[p creator] name]];
        [[[self headerView] timeLabel] setText:[STKRelativeDateConverter relativeDateStringFromDate:[p datePosted]]];
    
        [[[self headerView] postTypeView] setImage:[p typeImage]];
    }
    
    //if the post object is a re-post set FROM the original creator name in the headerviews source label
    if([p originalPost] && [[[p originalPost] creator] name]){
        NSString * fromUser = [NSString stringWithFormat:@"Via %@", [[[p originalPost] creator] name]];
        [[[self headerView] sourceLabel] setText:fromUser];
    }

    
    if([p commentCount] == 0) {
        [[self commentCountLabel] setText:@""];
        [[self commentButton] setImage:[UIImage imageNamed:@"action_comment"]
                              forState:UIControlStateNormal];
    } else {
        [[self commentCountLabel] setText:[NSString stringWithFormat:@"%d", [p commentCount]]];
        [[self commentButton] setImage:[UIImage imageNamed:@"action_comment_active"]
                              forState:UIControlStateNormal];
    }
    
    if([p text]) {
        [[self commentButton] setImage:[UIImage imageNamed:@"action_comment_active"]
                              forState:UIControlStateNormal];
    }
    
    if([p likeCount] == 0)
        [[self likeCountLabel] setText:@""];
    else
        [[self likeCountLabel] setText:[NSString stringWithFormat:@"%d", [p likeCount]]];
    
    [[self likeButton] setSelected:[p isPostLikedByUser:[[STKUserStore store] currentUser]]];
    
    if([p locationName]) {
        [[self locationButton] setImage:[UIImage imageNamed:@"action_pin_selected"]
                               forState:UIControlStateNormal];
    } else {
        [[self locationButton] setImage:[UIImage imageNamed:@"action_pin"]
                               forState:UIControlStateNormal];
    }
    
    NSMutableString *tags = [[NSMutableString alloc] init];
    for(NSString *tag in [[p hashTags] valueForKey:@"title"]) {
        [tags appendFormat:@"#%@ ", tag];
    }
    [[self hashTagLabel] setText:tags];
}

- (void)setDisplayFullBleed:(BOOL)displayFullBleed
{
    _displayFullBleed = displayFullBleed;
    
    if(_displayFullBleed) {
        [[self topInset] setConstant:0];
        [[self leftInset] setConstant:0];
        [[self rightInset] setConstant:0];
        [[self hashTagTopOffset] setConstant:300];
        [[self hashTagHeightConstraint] setConstant:21];
        [[self headerHeightConstraint] setConstant:64];
//        [[self hashTagContainer] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
        [[self hashTagContainer] setColors:@[[UIColor colorWithWhite:1 alpha:0.3], [UIColor colorWithWhite:1 alpha:0.3]]];
        [[self buttonContainer] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];

        UIBezierPath *bp = [UIBezierPath bezierPathWithRect:CGRectMake(0, 19, 320, 1)];
        [[[self hashTagContainer] layer] setShadowOpacity:1];
        [[[self hashTagContainer] layer] setShadowColor:[[UIColor blackColor] CGColor]];
        [[[self hashTagContainer] layer] setShadowOffset:CGSizeMake(0, 1)];
        [[[self hashTagContainer] layer] setShadowRadius:4];
        [[[self hashTagContainer] layer] setShadowPath:[bp CGPath]];
    } else {
        
    }
}

- (IBAction)toggleLike:(id)sender
{
    if([[self likeButton] isSelected]) {
        [[self likeButton] setSelected:NO];
        int count = [[self post] likeCount] - 1;
        if(count <= 0) {
            [[self likeCountLabel] setHidden:YES];
        } else {
            [[self likeCountLabel] setText:[NSString stringWithFormat:@"%d", count]];
            [[self likeCountLabel] setHidden:NO];
        }
    } else {
        [[self likeButton] setSelected:YES];
        int count = [[self post] likeCount] + 1;
        [[self likeCountLabel] setHidden:NO];
        [[self likeCountLabel] setText:[NSString stringWithFormat:@"%d", count]];
    }
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

- (IBAction)showLocation:(id)sender
{
    ROUTE(sender);
}

- (IBAction)imageTapped:(id)sender
{
    ROUTE(sender);
}

- (void)avatarTapped:(id)sender 
{
    ROUTE(sender);
}

- (void)sourceTapped:(id)sender
{
    ROUTE(sender);
}

- (void)cellDidLoad
{
    static UIImage *fadeImage = nil;
    if(!fadeImage) {
        UIGraphicsBeginImageContext(CGSizeMake(2, 2));
        [[UIColor colorWithRed:11.0 / 255.0 green:53.0 / 255.0 blue:110.0 / 255.0 alpha:0.95] set];
        UIRectFill(CGRectMake(0, 0, 2, 2));
        fadeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [[[self headerView] backdropFadeView] setImage:fadeImage];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[self headerView] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    [[[self headerView] avatarButton] addTarget:self action:@selector(avatarTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [[[self headerView] sourceButton] addTarget:self action:@selector(sourceTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self contentImageView] setPreferredSize:STKImageStoreThumbnailLarge];
}

@end
