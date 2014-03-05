//
//  STKImageSharer.m
//  Prism
//
//  Created by Joe Conway on 3/5/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKImageSharer.h"
#import "STKPost.h"
#import "STKImageStore.h"
@interface STKActivity : UIActivity
@end

@implementation STKActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for(id obj in activityItems) {
        if(!([obj isKindOfClass:[UIImage class]] || [obj isKindOfClass:[NSString class]])) {
            return NO;
        }
    }
    return YES;
}


@end

@interface STKActivityInstagram : STKActivity
@end
@implementation STKActivityInstagram
- (NSString *)activityType
{
    return @"STKActivityInstagram";
}
- (NSString *)activityTitle
{
    return @"Instagram";
}
- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"instagram"];
}

@end

@interface STKActivityTumblr : STKActivity
@end
@implementation STKActivityTumblr
- (NSString *)activityType
{
    return @"STKActivityTumblr";
}
- (NSString *)activityTitle
{
    return @"Tumblr";
}
- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"tumblr"];
}
@end

@interface STKActivityWhatsapp : STKActivity
@end
@implementation STKActivityWhatsapp
- (NSString *)activityType
{
    return @"STKActivityWhatsapp";
}
- (NSString *)activityTitle
{
    return @"Whatsapp";
}
- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"whatsapp"];
}
@end

@interface STKActivityReport : STKActivity
@end
@implementation STKActivityReport
- (NSString *)activityType
{
    return @"STKActivityReport";
}
- (NSString *)activityTitle
{
    return @"Report as Inappropriate";
}
- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"action_heart_like"];
}
+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}



@end

@interface STKImageSharer ()
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic, weak) STKPost *currentPost;
@end

@implementation STKImageSharer

+ (STKImageSharer *)defaultSharer
{
    static STKImageSharer *sharer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharer = [[STKImageSharer alloc] init];
    });
    
    return sharer;
}

- (UIActivityViewController *)activityViewControllerForImage:(UIImage *)image text:(NSString *)text
{
    NSMutableArray *a = [NSMutableArray array];
    if(image)
        [a addObject:image];
    if(text)
        [a addObject:text];
    _activityViewController = [[UIActivityViewController alloc] initWithActivityItems:a
                                                                applicationActivities:@[[[STKActivityInstagram alloc] init],
                                                                                        [[STKActivityReport alloc] init],
                                                                                        [[STKActivityTumblr alloc] init],
                                                                                        [[STKActivityWhatsapp alloc] init]]];
    [_activityViewController setExcludedActivityTypes:@[UIActivityTypeAssignToContact, UIActivityTypePrint]];
    
//    [self setCurrentPost:p];
    return [self activityViewController];
}

@end



