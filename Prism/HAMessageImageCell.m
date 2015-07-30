//
//  HAMessageImageCell.m
//  Prizm
//
//  Created by Jonathan Boone on 5/19/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAMessageImageCell.h"
#import "STKMessage.h"
#import "STKUser.h"
#import "STKRelativeDateConverter.h"

@interface HAMessageImageCell()

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *avatarTap;
@property (nonatomic, strong) UITapGestureRecognizer *creatorTap;

@end

@implementation HAMessageImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)prepareForReuse
{
    [self.postImage setImage:nil];
    [self.postImage setContentMode:UIViewContentModeCenter];
    [super prepareForReuse];
}

- (void)setup
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.containerView = [[UIView alloc] init];
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:self.containerView];
    self.avatarView = [[STKAvatarView alloc] init];
    self.creator = [[UILabel alloc] init];
    self.dateAgo = [[UILabel alloc] init];
    self.likesCount = [[UILabel alloc] init];
    self.postImage = [[STKResolvingImageView alloc] init];
    [self.postImage setContentMode:UIViewContentModeCenter];
    [self.postImage setUserInteractionEnabled:YES];
    [self.postImage setClipsToBounds:YES];
    self.likeButton = [[UIButton alloc] init];
    [self.likeButton addTarget:self action:@selector(likeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.viewedButton = [[UIButton alloc] init];
    [self.viewedButton setTitle:@"" forState:UIControlStateNormal];
    [self.viewedButton setImage:[UIImage imageNamed:@"view_icon"] forState:UIControlStateNormal];
    [self.viewedButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.viewedButton addTarget:self action:@selector(viewedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.viewedButton];
    self.viewedLabel = [[UILabel alloc] init];
    [self.viewedLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.viewedLabel setHidden:YES];
    [self.containerView addSubview:self.viewedLabel];
    self.clockImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_clock"]];
    NSArray *views = @[self.avatarView, self.creator, self.dateAgo, self.likesCount, self.postImage, self.likeButton, self.clockImage];
    [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.containerView addSubview:view];
    }];
    
    [self setConstraints];
}

- (void)setConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[cv]-0-|" options:0 metrics:nil views:@{@"cv": _containerView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[cv]-0-|" options:0 metrics:nil views:@{@"cv": _containerView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.f constant:-1.f]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.clockImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.creator attribute:NSLayoutAttributeBottom multiplier:1.f constant:5.f]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.postImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.clockImage attribute:NSLayoutAttributeBottom multiplier:1.f constant:8.f]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeTop multiplier:1.f constant:8.f]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.creator attribute:NSLayoutAttributeTop    relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[av(==30)]-8-[c]-0-[lb(==27)]-1-[lc(==18)]-0-|" options:0 metrics:nil views:@{@"av": self.avatarView, @"c": self.creator, @"lb": self.likeButton, @"lc": self.likesCount}]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.likeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.creator attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.likesCount attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.creator attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.clockImage attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.creator attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
   
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateAgo attribute:NSLayoutAttributeCenterY      relatedBy:NSLayoutRelationEqual toItem:self.clockImage attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateAgo attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:42.f]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewedButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.clockImage attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewedLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.clockImage attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[ci(==11)]-5-[da]" options:0 metrics:nil views:@{@"ci": self.clockImage, @"da": self.dateAgo}]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewedButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.clockImage attribute:NSLayoutAttributeTrailing multiplier:1.f constant:55]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewedLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.viewedButton attribute:NSLayoutAttributeTrailing multiplier:1.f constant:5]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewedButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute  multiplier:1.f constant:11.f]];
//    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.postImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:300]];
    [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[pi]-15-|" options:0 metrics:nil views:@{@"pi": self.postImage}]];
    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.postImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.postImage attribute:NSLayoutAttributeWidth multiplier:1.f constant:0]];
//    [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.postImage attribute:NSLayoutAttributeCenterX            relatedBy:NSLayoutRelationEqual toItem:_containerView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0]];
}

- (void)imageTapped:(id)sender
{
    if (self.delegate) {
        [self.delegate messageImageTapped:self.message];
    }
}

- (void)setMessage:(STKMessage *)message
{
    _message = message;
    [self setBackgroundColor:[UIColor clearColor]];
    [self.containerView setBackgroundColor:[UIColor colorWithWhite:1.f alpha:0.2f]];
    [self.avatarView setUrlString:message.creator.profilePhotoPath];
    if (!self.avatarTap) {
        self.avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageTapped:)];
    }
    
    if (!self.creatorTap) {
        self.creatorTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarImageTapped:)];
    }
    [self.avatarView setUserInteractionEnabled:YES];
    [self.creator setUserInteractionEnabled:YES];
    [self.avatarView removeGestureRecognizer:self.avatarTap];
    [self.avatarView addGestureRecognizer:self.avatarTap];
    [self.creator removeGestureRecognizer:self.creatorTap];
    [self.creator addGestureRecognizer:self.creatorTap];
    [self.creator setText:message.creator.name];
    [self.dateAgo setText:[NSString stringWithFormat:@"%@", [STKRelativeDateConverter relativeDateStringFromDate:message.createDate]]];
    [self.dateAgo sizeToFit];
    if ([message.likesCount integerValue] > 0) {
        [self.likesCount setText:[NSString stringWithFormat:@"%@", message.likesCount]];
    } else {
        [self.likesCount setText:@""];
    }
    [self.viewedLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)message.read.count]];
    [self.viewedLabel setFont:STKFont(9)];
    [self.viewedLabel setTextColor:[UIColor HATextColor]];
    [self.viewedLabel sizeToFit];
    [[STKImageStore store] fetchImageForURLString:message.imageURL preferredSize:STKImageStoreThumbnailMedium completion:^(UIImage *img) {
        if (img.size.width > 300 || img.size.height > 300) {
            [self.postImage setContentMode:UIViewContentModeScaleAspectFit];
        }
        [self.postImage setImage:img];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.creator setFont:STKFont(18.f)];
    [self.dateAgo setFont:STKFont(9.0f)];
    [self.creator setTextColor:[UIColor HATextColor]];
    [self.likesCount setTextColor:[UIColor HATextColor]];
    [self.likesCount setFont:[UIFont systemFontOfSize:13.f]];
    [self.dateAgo setTextColor:[UIColor colorWithRed:192.f/255.f green:193.f/255.f blue:213.f/255.f alpha:1]];
    [self.postImage setBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.2f]];
    if (!self.tapRecognizer) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
        [self.postImage addGestureRecognizer:self.tapRecognizer];
    }
}

- (void)setLiked:(BOOL)liked
{
    _liked = liked;
    if (liked) {
        [self.likeButton setImage:[UIImage imageNamed:@"action_heart_like"] forState:UIControlStateNormal];
    } else {
        [self.likeButton setImage:[UIImage imageNamed:@"action_heart"] forState:UIControlStateNormal];
    }
    [self.likeButton setEnabled:YES];
}

- (IBAction)likeButtonTapped:(id)sender
{
    [self.likeButton setEnabled:NO];
    if (self.delegate) {
        [self.delegate likeButtonTapped:(HAMessageCell *)self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)viewedButtonTapped:(id)sender
{
    if (self.delegate) {
        [self.delegate viewedButtonTapped:self];
    }
}

- (void)avatarImageTapped:(id)sender {
    if (self.delegate) {
        [self.delegate avatarTapped:self.message.creator];
    }
}


@end
