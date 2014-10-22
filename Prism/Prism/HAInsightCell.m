//
//  HAInsightCell.m
//  Prizm
//
//  Created by Jonathan Boone on 10/1/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "HAInsightCell.h"
#import "STKInsightTarget.h"
#import "STKInsight.h"
#import "STKUser.h"
#import "STKResolvingImageView.h"
#import "STKInsightHeaderView.h"
#import "STKAvatarView.h"
#import "STKGradientView.h"

@interface HAInsightCell()

@property (nonatomic, weak) IBOutlet STKInsightHeaderView *headerView;
@property (nonatomic, weak) IBOutlet STKGradientView *hashtagView;
@property (nonatomic, weak) IBOutlet UILabel *hashtagLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topInset;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *rightInset;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftInset;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *hashtagTopOffset;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *hashtagHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *hashtagLeftOffset;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *hashtagRightOffset;

@property (nonatomic, strong) UIControl *postControl;

@end

@implementation HAInsightCell

- (void)setFullBleed:(BOOL)fullBleed
{
    _fullBleed = fullBleed;
    if (_fullBleed) {
        UIBezierPath *bp = [UIBezierPath bezierPathWithRect:CGRectMake(0, 19, 320, 1)];
        [self.hashtagTopOffset setConstant:302];
        [self.hashtagHeight setConstant:21];
        [self.hashtagView setColors:@[[UIColor colorWithWhite:1 alpha:0.3], [UIColor colorWithWhite:1 alpha:0.3]]];
        [self.hashtagView.layer setShadowOpacity:1.f];
        [self.hashtagView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [self.hashtagView.layer setShadowOffset:CGSizeMake(0.f, 1.f)];
        [self.hashtagView.layer setShadowRadius:4];
        [self.hashtagView.layer setShadowPath:[bp CGPath]];
        [self.hashtagLeftOffset setConstant:-8];
        [self.hashtagRightOffset setConstant:-8];
//        if (self.postControl) {
//            [self.postControl removeFromSuperview];
//        }
        [self.rightInset setConstant:-8];
        [self.leftInset setConstant:-8];
    }
}

- (void)awakeFromNib {
    // Initialization code
    NSLog(@"Woke up");
//    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    
    [self.headerView.likeButton addTarget:self action:@selector(likeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView.dislikeButton addTarget:self action:@selector(dislikeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.postControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, self.postImageView.frame.size.width, self.postImageView.frame.size.height)];
    [self addSubview:self.postControl];
    [self.postControl setBackgroundColor:[UIColor clearColor]];
    [self.postControl setCenter:self.postImageView.center];
    [self.postControl addTarget:self action:@selector(controlTapped:) forControlEvents:UIControlEventTouchUpInside];
   
}

- (void)controlTapped:(id)sender
{
    if (self.delegate) {
        [self.delegate insightImageTapped:self];
    }
}

- (void)avatarTapped:(id)sender
{
    if (self.delegate){
        [self.delegate avatarImageTapped:self.insightTarget.insight.creator];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setArchived:(BOOL)archived
{
    _archived = archived;
//    [self.headerView.likeButton setHidden:archived];
//    [self.headerView.dislikeButton setHidden:archived];
}

- (void)setInsightTarget:(STKInsightTarget *)insightTarget
{
    _insightTarget = insightTarget;
    [self.postImageView setUrlString:insightTarget.insight.filePath];
    NSLog(@"%@", insightTarget.insight);
    [self.headerView.avatarView setUrlString:self.insightTarget.insight.creator.profilePhotoPath];
    [self.headerView.posterLabel setText:self.insightTarget.insight.creator.name];
    CGRect frame = [self convertRect:self.headerView.avatarView.frame fromView:self.headerView];
    frame.size.width = 60;
    frame.size.height = 44;
    UIControl *avatarControl = [[UIControl alloc] initWithFrame:frame];
    [avatarControl setBackgroundColor:[UIColor clearColor]];
    [avatarControl addTarget:self action:@selector(avatarTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:avatarControl];
    NSMutableString *tags = [[NSMutableString alloc] init];
    for(NSString *tag in [[self.insightTarget.insight hashTags] valueForKey:@"title"]) {
        [tags appendFormat:@"#%@ ", tag];
    }
    [self.hashtagLabel setText:tags];
}

- (void)likeButtonTapped:(id)sender
{
    if (self.delegate) {
        [self.delegate likeButtonTapped:self.insightTarget];
    }
}

- (void)dislikeButtonTapped:(id)sender
{
    if (self.delegate) {
        [self.delegate dislikeButtonTapped:self.insightTarget];
    }
}

- (void)setFrame:(CGRect)frame
{
    if (! [self isFullBleed]){
        frame.origin.x += 5;
        frame.size.width -= 10;
        frame.origin.y += 2;
        frame.size.height -= 4;
    }
    [super setFrame:frame];
}

@end
