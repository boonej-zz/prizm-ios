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
#import "STKContentStore.h"

NSString * const STKActivityTypeInstagram = @"STKActivityInstagram";
NSString * const STKActivityTypeTumblr = @"STKActivityTumblr";
NSString * const STKActivityTypeWhatsapp = @"STKActivityWhatsapp";

@class STKActivity;

@protocol STKActivityDelegate <NSObject>

- (void)activity:(STKActivity *)activity
wantsToPresentDocumentController:(UIDocumentInteractionController *)doc;


@end

@interface STKImageSharer () <STKActivityDelegate>

@end

@interface STKActivity : UIActivity

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, weak) id <STKActivityDelegate> delegate;

- (id)initWithDelegate:(id <STKActivityDelegate>)delegate;

@end

@implementation STKActivity
- (id)initWithDelegate:(id <STKActivityDelegate>)delegate
{
    self = [super init];
    if(self) {
        [self setDelegate:delegate];
    }
    return self;
}
+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}
/*
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for(id obj in activityItems) {
        if(!([obj isKindOfClass:[UIImage class]] || [obj isKindOfClass:[NSString class]])) {
            return NO;
        }
    }
    return YES;
}*/

@end

@interface STKActivityInstagram : STKActivity
@end
@implementation STKActivityInstagram

- (NSString *)activityType
{
    return STKActivityTypeInstagram;
}
- (NSString *)activityTitle
{
    return @"Instagram";
}
- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"instagram"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]])
        return NO;
    
    for(id obj in activityItems) {
        if([obj isKindOfClass:[UIImage class]]) {
            [self setImage:obj];
        }
        if([obj isKindOfClass:[NSString class]]) {
            [self setText:obj];
        }
    }
    
    if(![self image])
        return NO;
    
    return YES;
}

- (void)performActivity
{
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.igo"];
    [UIImageJPEGRepresentation([self image], 1.0) writeToFile:tempPath atomically:YES];

    UIDocumentInteractionController *doc = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:tempPath]];
    [doc setUTI:@"com.instagram.exclusivegram"];

    if([self text]) {
        [doc setAnnotation:@{@"InstagramCaption" : [self text]}];
    }

    [[self delegate] activity:self wantsToPresentDocumentController:doc];
}

@end

@interface STKActivityTumblr : STKActivity
@end
@implementation STKActivityTumblr
- (NSString *)activityType
{
    return STKActivityTypeTumblr;
}
- (NSString *)activityTitle
{
    return @"Tumblr";
}
- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"tumblr"];
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tumblr://"]])
        return NO;
    
    for(id obj in activityItems) {
        if([obj isKindOfClass:[UIImage class]]) {
            [self setImage:obj];
        }
        if([obj isKindOfClass:[NSString class]]) {
            [self setText:obj];
        }
    }
    
    if(![self image])
        return NO;
    
    return YES;
}

- (void)performActivity
{
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.tumblrphoto"];
    [UIImageJPEGRepresentation([self image], 1.0) writeToFile:tempPath atomically:YES];
    
    UIDocumentInteractionController *doc = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:tempPath]];
    [doc setUTI:@"com.tumblr.photo"];
    
    if([self text]) {
        [doc setAnnotation:@{@"TumblrCaption" : [self text]}];
    }
    
    [[self delegate] activity:self wantsToPresentDocumentController:doc];
}


@end

@interface STKActivityWhatsapp : STKActivity
@end
@implementation STKActivityWhatsapp
- (NSString *)activityType
{
    return STKActivityTypeWhatsapp;
}
- (NSString *)activityTitle
{
    return @"Whatsapp";
}
- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"whatsapp"];
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whatsapp://"]])
        return NO;
    
    for(id obj in activityItems) {
        if([obj isKindOfClass:[UIImage class]]) {
            [self setImage:obj];
        }
        if([obj isKindOfClass:[NSString class]]) {
            [self setText:obj];
        }
    }
    
    if(![self image])
        return NO;
    
    return YES;
}

- (void)performActivity
{
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.wai"];
    [UIImageJPEGRepresentation([self image], 1.0) writeToFile:tempPath atomically:YES];
    
    UIDocumentInteractionController *doc = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:tempPath]];
    [doc setUTI:@"net.whatsapp.image"];
    
    
    [[self delegate] activity:self wantsToPresentDocumentController:doc];
}


@end

@interface STKActivityReport : STKActivity
@property (nonatomic, strong) STKPost *currentPost;
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
    return [UIImage imageNamed:@"warning"];
}
+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for(id obj in activityItems) {
        if([obj isKindOfClass:[STKPost class]] && [obj respondsToSelector:@selector(uniqueID)]) {
            [self setCurrentPost:(STKPost *)obj];
        }
    }
    
    if(!_currentPost)
        return NO;

    return YES;
}

- (void)performActivity
{
    [[STKContentStore store] flagPost:_currentPost completion:^(STKPost *p, NSError *err) {
        if(err){
            //user must have already reported it -- need some sort of ui action?
            if ([err isConnectionError]) {
                [[STKErrorStore alertViewForError:err delegate:nil] show];
            }
        }
        [self activityDidFinish:YES];
    }];
}

@end

@interface STKImageSharer () <UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UIActivity *continuingActivity;
@property (nonatomic, strong) UIDocumentInteractionController *documentControllerRef;
@property (nonatomic, weak) STKPost *currentPost;
@property (nonatomic, strong) void (^finishHandler)(UIDocumentInteractionController *);

@property (nonatomic, strong) UIViewController *viewController;
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

- (NSArray *)activitiesForImage:(UIImage *)image title:(NSString *)title viewController:(UIViewController *)viewController
{
    [self setViewController:viewController];
    
    NSMutableArray *a = [NSMutableArray array];
    if(image)
        [a addObject:image];
    if(title)
        [a addObject:[NSString stringWithFormat:@"%@ @beprizmatic", title]];
    else
        [a addObject:@"@beprizmatic"];
    
    NSArray *activities = @[[[STKActivityInstagram alloc] initWithDelegate:self],
                            [[STKActivityTumblr alloc] initWithDelegate:self],
                            [[STKActivityWhatsapp alloc] initWithDelegate:self]];
    NSMutableArray *mutableCopy = [activities mutableCopy];
    for (UIActivity *activity in activities) {
        if ([activity canPerformWithActivityItems:a] == NO) {
            [mutableCopy removeObject:activity];
        }
    }
    
    return mutableCopy;
}

- (UIActivityViewController *)activityViewControllerForPost:(STKPost *)post
                                              finishHandler:(void (^)(UIDocumentInteractionController *))block
{
    UIImage *image = [[STKImageStore store] cachedImageForURLString:[post imageURLString]];
    UIActivityViewController *controller = [self activityViewControllerForImage:image object:post finishHandler:block];
    if (! controller) return nil;
    [self setViewController:controller];
    
    return controller;
}

- (UIActivityViewController *)activityViewControllerForImage:(UIImage *)image object:(id)object
                                               finishHandler:(void (^)(UIDocumentInteractionController *))block
{
    if(!image) {
        return nil;
    }
    
    NSMutableArray *a = [NSMutableArray array];
    if(image)
        [a addObject:image];
    if([object isKindOfClass:[STKPost class]])
        [a addObject:[NSString stringWithFormat:@"%@ @beprizmatic", [object valueForKey:@"text"]]];
    else
        [a addObject:object];
    
    
    [self setFinishHandler:block];
    NSArray *activities =  @[[[STKActivityInstagram alloc] initWithDelegate:self],
                             [[STKActivityReport alloc] initWithDelegate:self],
                             [[STKActivityTumblr alloc] initWithDelegate:self],
                             [[STKActivityWhatsapp alloc] initWithDelegate:self]];;
    NSArray *excludedActivities = nil;
    if ([object isKindOfClass:[STKPost class]]){
        excludedActivities = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeMail];
    } else {
        excludedActivities = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeCopyToPasteboard];
    }
    
    
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:a
                                                                                         applicationActivities:activities];
    [activityViewController setExcludedActivityTypes:excludedActivities];
    if (![object isKindOfClass:[STKPost class]]) {
        [activityViewController setTitle:@"Look who's on Prizm!"];
    }
    
#warning smelly, but we do not have direct access to system provided activities and their navigation controllers
    // revert appearance proxies to get default iOS behavior when sharing through Messages
    UIImage *backgroundImage = [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault];
    UIColor *tintColor = [[UITextField appearance] tintColor];
    [[UINavigationBar appearance] setBackgroundImage:nil
                                       forBarMetrics:UIBarMetricsDefault];
    [[UITextField appearance] setTintColor:nil];
    UIActivityViewControllerCompletionHandler handler = ^void (NSString *activityType, BOOL completed) {
        // restore appearance proxies to original
        [[UINavigationBar appearance] setBackgroundImage:backgroundImage
                                           forBarMetrics:UIBarMetricsDefault];
        [[UITextField appearance] setTintColor:tintColor];
    };
    [activityViewController setCompletionHandler:handler];
    [self setViewController:activityViewController];
    
    return activityViewController;
}


- (void)activity:(STKActivity *)activity
wantsToPresentDocumentController:(UIDocumentInteractionController *)doc
{
    void (^completion)(void) = ^{
        [doc setDelegate:self];
        [self setContinuingActivity:activity];
        [self setDocumentControllerRef:doc];
    };
    
    // finish handler is provided when we want to dismiss the view asking to share
    if ([self finishHandler]) {
        [[self viewController] dismissViewControllerAnimated:YES completion:^{
            completion();
            if ([self finishHandler]) {
                [self finishHandler](doc);
            }

        }];
        return;
    }
    

    completion();
    [doc presentOpenInMenuFromRect:[[[self viewController] view] bounds]
                                inView:[[self viewController] view]
                              animated:YES];
    
}


- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    [[self continuingActivity] activityDidFinish:YES];
    [self setContinuingActivity:nil];
    [self setDocumentControllerRef:nil];
}


@end



