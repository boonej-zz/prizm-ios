//
//  STKCreatePostViewController.m
//  Prism
//
//  Created by Joe Conway on 11/7/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKCreatePostViewController.h"
#import "STKHashtagToolbar.h"
#import "STKTextImageCell.h"
#import "STKImageCollectionViewCell.h"
#import "STKImageChooser.h"
#import "STKPost.h"
#import "STKContentStore.h"
#import "UITextView+STKHashtagDetector.h"
#import "STKImageStore.h"
#import "STKProcessingView.h"
#import "STKBaseStore.h"
#import "STKUserStore.h"
#import "STKUser.h"
#import "STKLocationListViewController.h"
#import "STKFoursquareLocation.h"

NSString * const STKCreatePostPlaceholderText = @"Caption your post...";

@interface STKCreatePostViewController ()
    <STKHashtagToolbarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, STKHashtagToolbarDelegate, UIAlertViewDelegate, STKLocationListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *locationIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *postTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *categoryCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *optionCollectionView;
@property (nonatomic, strong) STKHashtagToolbar *hashtagToolbar;
@property (nonatomic) NSRange hashtagRange;
@property (weak, nonatomic) IBOutlet UILabel *locationField;

@property (nonatomic, getter = isUploadingImage) BOOL uploadingImage;
@property (nonatomic) BOOL waitingForImageToFinish;

@property (nonatomic, strong) NSArray *categoryItems;
@property (nonatomic, strong) NSArray *optionItems;

@property (nonatomic, strong) NSMutableDictionary *postInfo;
@property (nonatomic, strong) UIImage *postImage;
@property (nonatomic, strong) UIImage *originalPostImage;

- (void)changeImage:(id)sender;
- (IBAction)adjustImage:(id)sender;

@end

@implementation STKCreatePostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _postInfo = [[NSMutableDictionary alloc] init];
        UIBarButtonItem *bbiCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        UIBarButtonItem *bbiPost = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(post:)];
        
        [[self navigationItem] setLeftBarButtonItem:bbiCancel];
        [[self navigationItem] setRightBarButtonItem:bbiPost];
        [[self navigationItem] setTitle:@"Post"];
        
        _categoryItems = @[
            @{@"title" : @"Aspirations", STKPostTypeKey : STKPostTypeAspiration, @"image" : [UIImage imageNamed:@"category_aspiration_disabled"],
              @"selectedImage" : [UIImage imageNamed:@"category_aspirations_selected"]},
            @{@"title" : @"Passions", STKPostTypeKey : STKPostTypePassion, @"image" : [UIImage imageNamed:@"category_passions_disabled"],
              @"selectedImage" : [UIImage imageNamed:@"category_passions_selected"]},
            @{@"title" : @"Experiences", STKPostTypeKey : STKPostTypeExperience, @"image" : [UIImage imageNamed:@"category_experiences_disabled"],
              @"selectedImage" : [UIImage imageNamed:@"category_experiences_selected"]},
            @{@"title" : @"Achievements", STKPostTypeKey : STKPostTypeAchievement, @"image" : [UIImage imageNamed:@"category_achievements_disabled"],
              @"selectedImage" : [UIImage imageNamed:@"category_achievements_selected"]},
            @{@"title" : @"Inspirations", STKPostTypeKey : STKPostTypeInspiration, @"image" : [UIImage imageNamed:@"category_inspiration_disabled"],
              @"selectedImage" : [UIImage imageNamed:@"category_inspiration_selected"]},
            @{@"title" : @"Personal", STKPostTypeKey : STKPostTypePersonal, @"image" : [UIImage imageNamed:@"category_personal_disabled"],
              @"selectedImage" : [UIImage imageNamed:@"category_personal_selected"]}
        ];
        
        _optionItems = @[
                         @{@"key" : @"camera", @"image" : [UIImage imageNamed:@"btn_camera"], @"selectedImage" : [UIImage imageNamed:@"btn_camera_selected"], @"action" : @"changeImage:"},
                         @{@"key" : @"location", @"image" : [UIImage imageNamed:@"btn_pin"], @"selectedImage" : [UIImage imageNamed:@"btn_pin_selected"], @"action" : @"findLocation:"},
                         @{@"key" : @"user", @"image" : [UIImage imageNamed:@"btn_usertag"], @"selectedImage" : [UIImage imageNamed:@"btn_usertag_selected"]},
                         @{@"key" : @"visibility", @"image" : [UIImage imageNamed:@"btn_globe"], @"selectedImage" : [UIImage imageNamed:@"btn_globe_selected"], @"action" : @"toggleTrust:"},
                         @{@"key" : @"facebook", @"image" : [UIImage imageNamed:@"btn_facebook"], @"selectedImage" : [UIImage imageNamed:@"btn_facebook_selected"]},
                         @{@"key" : @"twitter", @"image" : [UIImage imageNamed:@"btn_twitter"], @"selectedImage" : [UIImage imageNamed:@"btn_twitter_selected"]},
                         @{@"key" : @"tumblr", @"image" : [UIImage imageNamed:@"btn_tumblr"], @"selectedImage" : [UIImage imageNamed:@"btn_tumblr_selected"]},
                         @{@"key" : @"personal", @"image" : [UIImage imageNamed:@"btn_foursquare"], @"selectedImage" : [UIImage imageNamed:@"btn_foursquare_selected"]}
        ];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
    [[[self navigationController] navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName : STKTextColor,
                                                                          NSFontAttributeName : STKFont(22)}];
    [[[self navigationController] navigationBar] setTintColor:[STKTextColor colorWithAlphaComponent:0.8]];

    if([[[STKUserStore store] currentUser] isInstitution]) {
        [[self postInfo] setObject:STKPostVisibilityPublic forKey:STKPostVisibilityKey];
    }
    
    [[self locationIndicator] setHidden:[[self postInfo] objectForKey:STKPostLocationNameKey] == nil];
    
    if([self originalPost]) {
        [[self navigationItem] setTitle:@"Repost"];
        [[self postInfo] setObject:[[self originalPost] imageURLString] forKey:STKPostURLKey];
        [[self postInfo] setObject:[[self originalPost] uniqueID] forKey:STKPostOriginIDKey];
        [[STKImageStore store] fetchImageForURLString:[[self originalPost] imageURLString]
                                           completion:^(UIImage *img) {
                                               [[self imageView] setImage:img];
                                           }];
        [[self optionHeightConstraint] setConstant:47];
    }
    
    [[self optionCollectionView] reloadData];
}

- (void)setPostImage:(UIImage *)postImage
{
    _postImage = postImage;
    [self setUploadingImage:YES];
    [[self optionCollectionView] reloadData];
    
    [[STKImageStore store] uploadImage:_postImage thumbnailCount:2 intoDirectory:[[[STKUserStore store] currentUser] uniqueID] completion:^(NSString *URLString, NSError *err) {
        if(postImage == [self postImage]) {
            
            [self setUploadingImage:NO];
            
            if(!err) {
                [[self postInfo] setObject:URLString forKey:STKPostURLKey];
                if([self waitingForImageToFinish]) {
                    [self createPost];
                }
            } else {
                [self setWaitingForImageToFinish:NO];
                
                [[self imageView] setImage:nil];
                
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Uploading Image"
                                                             message:@"The image you selected failed to upload. Make sure you have an internet connection and try again."
                                                            delegate:self
                                                   cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Try Again", nil];
                [av show];
            }
        }
    }];
}

- (void)findLocation:(id)sender
{
    STKLocationListViewController *lvc = [[STKLocationListViewController alloc] init];
    [lvc setDelegate:self];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:lvc];
    [[nvc navigationBar] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)locationListViewController:(STKLocationListViewController *)lvc choseLocation:(STKFoursquareLocation *)loc
{
    [[self postInfo] setObject:[NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:[loc location].latitude]] forKey:STKPostLocationLatitudeKey];
    [[self postInfo] setObject:[NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:[loc location].longitude]] forKey:STKPostLocationLongitudeKey];
    if([loc name]) {
        [[self postInfo] setObject:[loc name] forKey:STKPostLocationNameKey];
        [[self locationField] setText:[loc name]];
    }
    [[self locationIndicator] setHidden:[[self postInfo] objectForKey:STKPostLocationNameKey] == nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        [self setPostImage:[self postImage]];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([[textView text] isEqualToString:STKCreatePostPlaceholderText]) {
        [textView setText:@""];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    __block NSString *stringBasis = nil;
    NSRange cursorRange = [textView selectedRange];
    if(cursorRange.length == 0) {
        // Then we are in 'cursor mode'
        NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"#([A-Za-z0-9]*)"
                                                                        options:0
                                                                          error:nil];
        [exp enumerateMatchesInString:textView.text options:0 range:NSMakeRange(0, textView.text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSRange r = [result range];
            if(r.location != NSNotFound) {
                if(cursorRange.location >= r.location && cursorRange.location <= r.location + r.length) {
                    NSRange hashtagRange = [result rangeAtIndex:1];
                    stringBasis = [textView.text substringWithRange:hashtagRange];
                    [self setHashtagRange:hashtagRange];
                    *stop = YES;
                }
            }
        }];
        
    }

    if (stringBasis)    {
        [[STKContentStore store] fetchRecommendedHashtags:stringBasis completion:^(NSArray *hashtags) {
            if ([hashtags count] > 0) {
                [[self hashtagToolbar] setHashtags:hashtags];
            } else {
                [[self hashtagToolbar] setHashtags:@[stringBasis]];
            }
        }];
    } else {
        [[self hashtagToolbar] setHashtags:nil];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if([textView text] == nil || [[textView text] isEqualToString:@""]) {
        [textView setText:STKCreatePostPlaceholderText];
    }
}

- (void)toggleTrust:(id)sender
{
    NSString *postType = [[self postInfo] objectForKey:STKPostTypeKey];
    if([postType isEqualToString:STKPostTypePersonal]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Visibility"
                                                     message:@"This button changes whether this post is visible to everyone or just members of your trust. However, you have selected that this is a 'Personal' post which is only viewable to you. You can select another category and then choose the visibility options for this post."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    
    NSString *postVisibility = [[self postInfo] objectForKey:STKPostVisibilityKey];
    if(!postVisibility) {
        [[self postInfo] setObject:STKPostVisibilityPublic forKey:STKPostVisibilityKey];
    } else if([postVisibility isEqualToString:STKPostVisibilityPublic]) {
        [[self postInfo] setObject:STKPostVisibilityTrust forKey:STKPostVisibilityKey];
    } else {
        [[self postInfo] setObject:STKPostVisibilityPublic forKey:STKPostVisibilityKey];
    }
    
    [[self optionCollectionView] reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _hashtagToolbar = [[STKHashtagToolbar alloc] init];
    [[self hashtagToolbar] setDelegate:self];
    
    [[self postTextView] setText:STKCreatePostPlaceholderText];
    [[self postTextView] setInputAccessoryView:[self hashtagToolbar]];
    
    [[self categoryCollectionView] registerNib:[UINib nibWithNibName:@"STKTextImageCell" bundle:nil]
                    forCellWithReuseIdentifier:@"STKTextImageCell"];
    [[self categoryCollectionView] setBackgroundColor:[UIColor clearColor]];
    [[self categoryCollectionView] setScrollEnabled:NO];
    
    [[self optionCollectionView] registerNib:[UINib nibWithNibName:@"STKImageCollectionViewCell" bundle:nil]
                    forCellWithReuseIdentifier:@"STKImageCollectionViewCell"];
    [[self optionCollectionView] setBackgroundColor:[UIColor clearColor]];
    [[self optionCollectionView] setScrollEnabled:NO];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == [self categoryCollectionView]) {
        return [[self categoryItems] count];
    }
    

    return [[self optionItems] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == [self categoryCollectionView]) {
        NSDictionary *item = [[self categoryItems] objectAtIndex:[indexPath row]];
        STKTextImageCell *cell = (STKTextImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKTextImageCell"
                                                                                               forIndexPath:indexPath];
        [[cell label] setText:[item objectForKey:@"title"]];
        [[cell label] setTextColor:STKTextColor];
        [[cell imageView] setImage:[item objectForKey:@"image"]];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        
        
        if([[[self postInfo] objectForKey:STKPostTypeKey] isEqual:[item objectForKey:STKPostTypeKey]]) {
            [[cell imageView] setImage:[item objectForKey:@"selectedImage"]];
            [[cell label] setTextColor:[UIColor whiteColor]];
        }
        
        return cell;
    }
    
    if(collectionView == [self optionCollectionView]) {
        NSDictionary *item = [[self optionItems] objectAtIndex:[indexPath row]];
        STKImageCollectionViewCell *cell = (STKImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKImageCollectionViewCell"
                                                                                               forIndexPath:indexPath];
        [cell setBackgroundColor:[UIColor clearColor]];
        [[cell imageView] setImage:[item objectForKey:@"image"]];

        if([[item objectForKey:@"key"] isEqualToString:@"visibility"]) {
            if([[[self postInfo] objectForKey:STKPostVisibilityKey] isEqualToString:STKPostVisibilityPublic]) {
                [[cell imageView] setImage:[item objectForKey:@"selectedImage"]];
            }
        }
        if([[item objectForKey:@"key"] isEqualToString:@"location"]) {
            if([[self postInfo] objectForKey:STKPostLocationNameKey]) {
                [[cell imageView] setImage:[item objectForKey:@"selectedImage"]];
            }
        }
        
        if([[item objectForKey:@"key"] isEqualToString:@"camera"]) {
            if([self postImage]) {
                [[cell imageView] setImage:[item objectForKey:@"selectedImage"]];
            }
        }
        
        return cell;
    }


    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == [self categoryCollectionView]) {
        NSString *category = [[[self categoryItems] objectAtIndex:[indexPath row]] objectForKey:STKPostTypeKey];
        [[self postInfo] setObject:category
                            forKey:STKPostTypeKey];
        [collectionView reloadData];
        
        if([category isEqualToString:STKPostTypePersonal]) {
            [[self postInfo] removeObjectForKey:STKPostVisibilityKey];
            [[self optionCollectionView] reloadData];
        }
    } else if(collectionView == [self optionCollectionView]) {
        NSString *action = [[[self optionItems] objectAtIndex:[indexPath row]] objectForKey:@"action"];
        if(action) {
            [self performSelector:NSSelectorFromString(action) withObject:nil];
        }
    }
}


- (void)cancel:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


- (void)createPost
{
    
    if(![[self postInfo] objectForKey:STKPostURLKey]) {
        // Do a card
        UIImage *img = [STKPost imageForTextPost:[[self postInfo] objectForKey:STKPostTextKey]];
        [self setPostImage:img];
    }
    
    if([self isUploadingImage]) {
        [STKProcessingView present];
        [self setWaitingForImageToFinish:YES];
        return;
    }

    // If we were waiting, the processing view is already up, but if we were not, make sure it goes up
    if(![self waitingForImageToFinish]) {
        [STKProcessingView present];
    }
    
    [[STKContentStore store] addPostWithInfo:[self postInfo] completion:^(STKPost *post, NSError *err) {
        [STKProcessingView dismiss];
        if(!err) {
            [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        } else {
            [[STKErrorStore alertViewForError:err delegate:nil] show];
        }
    }];
}

- (void)post:(id)sender
{
    NSString *msg = nil;
    // Verify that we have everything
    if(![[self postInfo] objectForKey:STKPostTypeKey]) {
        msg = @"Choose the category this post belongs to from the bottom of the screen before posting.";
    }
    
    
    if(msg) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    if([[[self postTextView] text] length] > 0 && ![[[self postTextView] text] isEqualToString:STKCreatePostPlaceholderText]) {
        [[self postInfo] setObject:[[self postTextView] text]
                            forKey:STKPostTextKey];
    }
    

    NSArray *tags = [self hashTagsFromText:[[self postInfo] objectForKey:STKPostTextKey]];
    if([tags count] > 0) {
        [[self postInfo] setObject:[tags copy] forKey:STKPostHashTagsKey];
    }
    
    if(![[self postInfo] objectForKey:STKPostTextKey] && ![[self postInfo] objectForKey:STKPostURLKey]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"A post must contain an image, text or both." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
    [self createPost];
}

- (NSArray *)hashTagsFromText:(NSString *)text
{
    if(!text)
        return nil;
    
    NSMutableArray *tags = [NSMutableArray array];
    NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"#([^\\s]*)" options:0 error:nil];
    [exp enumerateMatchesInString:text options:0 range:NSMakeRange(0, [text length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if([result numberOfRanges] == 2) {
            NSString *tag = [text substringWithRange:[result rangeAtIndex:1]];
            [tags addObject:tag];
        }
    }];
    
    return [tags copy];
}

- (void)hashtagToolbarClickedDone:(STKHashtagToolbar *)tb
{
    [[self view] endEditing:YES];
}

- (void)hashtagToolbar:(STKHashtagToolbar *)tb didPickHashtag:(NSString *)hashtag
{
    if([self hashtagRange].location != NSNotFound) {
        NSString *replacementString = [NSString stringWithFormat:@"%@ ", hashtag];
        [[[self postTextView] textStorage] replaceCharactersInRange:[self hashtagRange]
                                                         withString:replacementString];
        NSRange newRange = NSMakeRange([self hashtagRange].location + [replacementString length], 0);
        [[self postTextView] setSelectedRange:newRange];
        
        [self setHashtagRange:NSMakeRange(NSNotFound, 0)];
    }
}

- (void)changeImage:(id)sender
{
    [[STKImageChooser sharedImageChooser] initiateImageChooserForViewController:self
                                                                        forType:STKImageChooserTypeImage
                                                                     completion:^(UIImage *img, UIImage *originalImage) {
                                                                         [self setOriginalPostImage:originalImage];
                                                                         [self setPostImage:img];
                                                                         [[self imageView] setImage:img];
                                                                     }];
}

- (IBAction)adjustImage:(id)sender
{
    if(![self postImage]) {
        return;
    }
    
    [[STKImageChooser sharedImageChooser] initiateImageEditorForViewController:self
                                                                       forType:STKImageChooserTypeImage
                                                                         image:[self originalPostImage]
                                                                    completion:^(UIImage *img, UIImage *originalImage) {
                                                                        [self setOriginalPostImage:originalImage];
                                                                        [self setPostImage:img];
                                                                        [[self imageView] setImage:img];

                                                                    }];
}


@end
