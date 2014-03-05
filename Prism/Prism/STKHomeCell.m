//
//  STKHomeCell.m
//  Prism
//
//  Created by Joe Conway on 11/13/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKHomeCell.h"
#import "STKPost.h"
#import "STKRelativeDateConverter.h"

@interface STKHomeCell ()
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hashTagTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *hashTagContainer;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;

@end

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
    [[self contentImageView] setUrlString:[p imageURLString]];
    
    [[[self headerView] avatarView] setUrlString:[[p creator] profilePhotoPath]];
    [[[self headerView] posterLabel] setText:[[p creator] name]];
    [[[self headerView] timeLabel] setText:[STKRelativeDateConverter relativeDateStringFromDate:[p datePosted]]];
    //    if([p externalSystemID])
    //[[[c headerView] sourceLabel] setText:[p postOrigin]];
    [[[self headerView] postTypeView] setImage:[p typeImage]];
    
    if([p commentCount] == 0) {
        [[self commentCountLabel] setText:@""];
        [[self commentButton] setImage:[UIImage imageNamed:@"action_comment"]
                              forState:UIControlStateNormal];
    } else {
        [[self commentCountLabel] setText:[NSString stringWithFormat:@"%d", [p commentCount]]];
        [[self commentButton] setImage:[UIImage imageNamed:@"action_comment_active"]
                              forState:UIControlStateNormal];
    }
    
    if([p likeCount] == 0)
        [[self likeCountLabel] setText:@""];
    else
        [[self likeCountLabel] setText:[NSString stringWithFormat:@"%d", [p likeCount]]];

    [[self likeButton] setHighlighted:[p postLikedByCurrentUser]];
    
    if([p locationName]) {
        [[self locationButton] setImage:[UIImage imageNamed:@"action_pin_selected"]
                               forState:UIControlStateNormal];
    } else {
        [[self locationButton] setImage:[UIImage imageNamed:@"action_pin"]
                               forState:UIControlStateNormal];
    }
    
    NSMutableString *tags = [[NSMutableString alloc] init];
    for(NSString *tag in [p hashTags]) {
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
        [[self headerHeightConstraint] setConstant:64];
        [[self hashTagContainer] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
        [[self buttonContainer] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];

        UIBezierPath *bp = [UIBezierPath bezierPathWithRect:CGRectMake(0, 27, 320, 1)];
        [[[self hashTagContainer] layer] setShadowOpacity:1];
        [[[self hashTagContainer] layer] setShadowColor:[[UIColor blackColor] CGColor]];
        [[[self hashTagContainer] layer] setShadowOffset:CGSizeMake(0, 2)];
        [[[self hashTagContainer] layer] setShadowRadius:5];
        [[[self hashTagContainer] layer] setShadowPath:[bp CGPath]];
    } else {
        
    }
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
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [[self headerView] setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    [[[self headerView] avatarButton] addTarget:self action:@selector(avatarTapped:) forControlEvents:UIControlEventTouchUpInside];
}

@end
