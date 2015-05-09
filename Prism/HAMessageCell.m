//
//  HAMessageCell.m
//  Prizm
//
//  Created by Jonathan Boone on 4/28/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HAMessageCell.h"
#import "STKAvatarView.h"
#import "STKMessage.h"
#import "STKUser.h"
#import "STKRelativeDateConverter.h"
#import "STKMarkupUtilities.h"
#import "UITextView+STKHashtagDetector.h"
#import "STKMessageMetaData.h"
#import "STKMessageMetaDataImage.h"
#import "STKImageStore.h"

@interface HAMessageCell()<UITextViewDelegate>



@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageViewHeight;
@property (nonatomic, weak) IBOutlet UIImageView *iv;
- (IBAction)likeButtonTapped:(id)sender;

@end

@implementation HAMessageCell


- (void)awakeFromNib {
    // Initialization code
    [self.creator setFont:STKFont(18.0f)];
    [self.dateAgo setFont:STKFont(9.0f)];
    [self.postText setFont:STKFont(14.f)];
    [self.creator setTextColor:[UIColor HATextColor]];
    
    [self.dateAgo setTextColor:[UIColor colorWithRed:192.f/255.f green:193.f/255.f blue:213.f/255.f alpha:1]];
    [self setBackgroundColor:[UIColor clearColor]];
   
    [self.postText setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessage:(STKMessage *)message
{
    _message = message;
    self.imageViewHeight.constant = 0;
    [self layoutIfNeeded];
    [self.avatarView setUrlString:message.creator.profilePhotoPath];
    [self.postText setAttributedText:[self renderedText]];
    [self.creator setText:message.creator.name];
    [self.postText setTextColor:[UIColor HATextColor]];
    [self.dateAgo setText:[NSString stringWithFormat:@"%@", [STKRelativeDateConverter relativeDateStringFromDate:message.createDate]]];
    if ([message.likesCount integerValue] > 0) {
        [self.likesCount setText:[NSString stringWithFormat:@"%@", message.likesCount]];
    } else {
        [self.likesCount setText:@""];
    }
    if (message.metaData){
        STKMessageMetaData *meta = message.metaData;
        if (meta.image && meta.image.urlString) {
            self.imageViewHeight.constant = 163;
            [self layoutIfNeeded];
            [[STKImageStore store] fetchImageForURLString:meta.image.urlString completion:^(UIImage *img) {
                [self.iv setImage:img];
            }];
        }
    }
}


- (NSAttributedString *)renderedText
{
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] init];
    NSDictionary *baseAttributes = @{NSFontAttributeName : STKFont(14), NSForegroundColorAttributeName : [UIColor HATextColor]};
    
    NSAttributedString *mainMessage = [STKMarkupUtilities renderedTextForText:self.message.text attributes:baseAttributes];
    [s appendAttributedString:mainMessage];
    if (self.message.metaData) {
        STKMessageMetaData *meta = self.message.metaData;
        NSDictionary *titleAttributes = nil;
        NSDictionary *descAttributes = nil;
        NSLog(@"%@", meta);
        if (meta.urlString) {
            titleAttributes = @{NSFontAttributeName : STKBoldFont(14), NSForegroundColorAttributeName : [UIColor HATextColor], NSLinkAttributeName: [NSURL URLWithString:meta.urlString]};
            descAttributes = @{NSFontAttributeName : STKFont(13), NSForegroundColorAttributeName : [UIColor HATextColor], NSLinkAttributeName: [NSURL URLWithString:meta.urlString]};
        } else {
            titleAttributes = @{NSFontAttributeName : STKBoldFont(14), NSForegroundColorAttributeName : [UIColor HATextColor]};
            descAttributes = @{NSFontAttributeName : STKFont(13), NSForegroundColorAttributeName : [UIColor HATextColor]};
        }
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"" attributes:titleAttributes];
        NSAttributedString *description = [[NSAttributedString alloc] initWithString:@"" attributes:descAttributes];
        if (meta.title) {
            NSString *titleBreak = [NSString stringWithFormat:@"\n\n%@", meta.title];
            title = [[NSAttributedString alloc] initWithString:titleBreak attributes:titleAttributes];
            [s appendAttributedString:title];
        } if (meta.linkDescription) {
            NSString *descriptionBreak = [[NSString stringWithFormat:@"\n%@", meta.linkDescription] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
            description = [[NSAttributedString alloc] initWithString:descriptionBreak attributes:descAttributes];
            [s appendAttributedString:description];
        }
    }
    
    
    
    
    return s;
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
        [self.delegate likeButtonTapped:self];
    }
}

- (CGFloat)heightForCell
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentLeft];

    CGRect r = [self.postText.attributedText boundingRectWithSize:CGSizeMake(254, 10000)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                                  context:nil];
    return r.size.height + 80;
}



@end
