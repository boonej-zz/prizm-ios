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

NSString * const STKCreatePostPlaceholderText = @"Caption your post...";

NSString * const STKCreatePostTypeKey = @"type";
NSString * const STKCreatePostURLKey = @"url";
NSString * const STKCreatePostTextKey = @"text";

@interface STKCreatePostViewController ()
    <STKHashtagToolbarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, STKHashtagToolbarDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *postTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *categoryCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *optionCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (nonatomic, strong) STKHashtagToolbar *hashtagToolbar;
@property (nonatomic) NSRange hashtagRange;

@property (nonatomic, strong) NSArray *categoryItems;
@property (nonatomic, strong) NSArray *optionItems;

@property (nonatomic, strong) NSMutableDictionary *postInfo;
@property (nonatomic, strong) UIImage *postImage;

- (IBAction)changeImage:(id)sender;

@end

@implementation STKCreatePostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _postInfo = [[NSMutableDictionary alloc] init];
        UIBarButtonItem *bbiCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        UIBarButtonItem *bbiPost = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(post:)];
        
        [[self navigationItem] setLeftBarButtonItem:bbiCancel];
        [[self navigationItem] setRightBarButtonItem:bbiPost];
        
        
        _categoryItems = @[
                           @{@"title" : @"Aspirations", STKCreatePostTypeKey : @(STKPostTypeAspiration), @"image" : [UIImage imageNamed:@"category_aspirations"]},
                           @{@"title" : @"Passions", STKCreatePostTypeKey : @(STKPostTypePassion), @"image" : [UIImage imageNamed:@"category_passion"]},
                           @{@"title" : @"Experiences", STKCreatePostTypeKey : @(STKPostTypeExperience), @"image" : [UIImage imageNamed:@"category_experiences"]},
                           @{@"title" : @"Achievements", STKCreatePostTypeKey : @(STKPostTypeAchievement), @"image" : [UIImage imageNamed:@"category_achievements"]},
                           @{@"title" : @"Inspirations", STKCreatePostTypeKey : @(STKPostTypeInspiration), @"image" : [UIImage imageNamed:@"category_inspirations"]},
                           @{@"title" : @"Personal", STKCreatePostTypeKey : @(-1)}
        ];
        
        _optionItems = @[
                         @{@"key" : @"camera", @"image" : [UIImage imageNamed:@"category_aspirations"]},
                         @{@"key" : @"location", @"image" : [UIImage imageNamed:@"category_aspirations"]},
                         @{@"key" : @"user", @"image" : [UIImage imageNamed:@"category_aspirations"]},
                         @{@"key" : @"web", @"image" : [UIImage imageNamed:@"category_aspirations"]},
                         @{@"key" : @"facebook", @"image" : [UIImage imageNamed:@"category_aspirations"]},
                         @{@"key" : @"twitter", @"image" : [UIImage imageNamed:@"category_aspirations"]},
                         @{@"key" : @"tumblr", @"image" : [UIImage imageNamed:@"category_aspirations"]},
                         @{@"key" : @"noidea", @"image" : [UIImage imageNamed:@"category_aspirations"]}
        ];
    }
    return self;
}

- (void)setPostImage:(UIImage *)postImage
{
    _postImage = postImage;
    
    [[STKImageStore store] uploadImage:_postImage completion:^(NSString *URLString, NSError *err) {
        if(postImage == [self postImage]) {
            if(!err) {
                [[self postInfo] setObject:URLString forKey:STKCreatePostURLKey];
            } else {
                [[self imageView] setImage:nil];
                [[self imageButton] setImage:[UIImage imageNamed:@"upload_camera"]
                                    forState:UIControlStateNormal];
                
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Uploading Image"
                                                             message:@"The image you selected failed to upload. Make sure you have an internet connection and try again."
                                                            delegate:self
                                                   cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Try Again", nil];
                [av show];
            }
        }
    }];
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
    
    [[self optionCollectionView] registerNib:[UINib nibWithNibName:@"STKImageCollectionViewCell" bundle:nil]
                    forCellWithReuseIdentifier:@"STKImageCollectionViewCell"];
    [[self optionCollectionView] setBackgroundColor:[UIColor clearColor]];
    
    [self configureGridBackgroundImages];
}

- (void)configureGridBackgroundImages
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 128), NO, 0.0);
    [[UIColor colorWithWhite:0 alpha:0.5] set];
    UIBezierPath *bp = [UIBezierPath bezierPath];
    
    // Horizontal lines
    [bp moveToPoint:CGPointMake(0, 0)];
    [bp addLineToPoint:CGPointMake(320.0, 0)];
    [bp moveToPoint:CGPointMake(0.0, 64.0)];
    [bp addLineToPoint:CGPointMake(320, 64)];
    [bp moveToPoint:CGPointMake(0, 128)];
    [bp addLineToPoint:CGPointMake(320, 128)];
    
    // Vertical
    [bp moveToPoint:CGPointMake(320 / 3, 0)];
    [bp addLineToPoint:CGPointMake(320 / 3, 128)];
    [bp moveToPoint:CGPointMake(2 * 320 / 3, 0)];
    [bp addLineToPoint:CGPointMake(2 * 320 / 3, 128)];
    
    [bp stroke];
    [[self categoryCollectionView] setBackgroundView:[[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()]];
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 82), NO, 0.0);
    [[UIColor colorWithWhite:0 alpha:0.5] set];
    bp = [UIBezierPath bezierPath];
    
    // Horizontal lines
    [bp moveToPoint:CGPointMake(0, 0)];
    [bp addLineToPoint:CGPointMake(320.0, 0)];
    [bp moveToPoint:CGPointMake(0.0, 41.0)];
    [bp addLineToPoint:CGPointMake(320, 41)];
    [bp moveToPoint:CGPointMake(0.0, 82.0)];
    [bp addLineToPoint:CGPointMake(320, 82)];
    
    // Vertical
    [bp moveToPoint:CGPointMake(320 / 4, 0)];
    [bp addLineToPoint:CGPointMake(320 / 4, 82)];
    [bp moveToPoint:CGPointMake(2 * 320 / 4, 0)];
    [bp addLineToPoint:CGPointMake(2 * 320 / 4, 82)];
    [bp moveToPoint:CGPointMake(3 * 320 / 4, 0)];
    [bp addLineToPoint:CGPointMake(3 * 320 / 4, 82)];
    
    [bp stroke];
    [[self optionCollectionView] setBackgroundView:[[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()]];
    UIGraphicsEndImageContext();

}

- (int)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (int)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == [self categoryCollectionView])
        return [[self categoryItems] count];
    
    return [[self optionItems] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == [self categoryCollectionView]) {
        NSDictionary *item = [[self categoryItems] objectAtIndex:[indexPath row]];
        STKTextImageCell *cell = (STKTextImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKTextImageCell"
                                                                                               forIndexPath:indexPath];
        [[cell label] setText:[item objectForKey:@"title"]];
        [[cell imageView] setImage:[item objectForKey:@"image"]];
        
        [[cell label] setTextColor:[UIColor whiteColor]];
        
        if([[[self postInfo] objectForKey:STKCreatePostTypeKey] isEqual:[item objectForKey:STKCreatePostTypeKey]]) {
            [cell setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
        } else {
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        
        return cell;
    }
    
    if(collectionView == [self optionCollectionView]) {
        NSDictionary *item = [[self optionItems] objectAtIndex:[indexPath row]];
        STKImageCollectionViewCell *cell = (STKImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKImageCollectionViewCell"
                                                                                               forIndexPath:indexPath];

        [[cell imageView] setImage:[item objectForKey:@"image"]];

        return cell;
    }


    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == [self categoryCollectionView]) {
        [[self postInfo] setObject:[[[self categoryItems] objectAtIndex:[indexPath row]] objectForKey:STKCreatePostTypeKey]
                            forKey:STKCreatePostTypeKey];
        [collectionView reloadData];
    }
}

- (void)cancel:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)post:(id)sender
{
    NSString *msg = nil;
    // Verify that we have everything
    if(![[self postInfo] objectForKey:STKCreatePostTypeKey]) {
        msg = @"Choose the category this post belongs to from the bottom of the screen before posting.";
    } else if(![[self postInfo] objectForKey:STKCreatePostURLKey]) {
        msg = @"Choose an image for this post before posting.";
    }
    
    if(msg) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    if([[[self postTextView] text] length] > 0 && ![[[self postTextView] text] isEqualToString:STKCreatePostPlaceholderText]) {
        [[self postInfo] setObject:[[self postTextView] text]
                            forKey:STKCreatePostTextKey];
    }
    
    [[STKContentStore store] addPostWithCaption:[[self postInfo] objectForKey:STKCreatePostTextKey]
                                 imageURLString:[[self postInfo] objectForKey:STKCreatePostURLKey]
                                           type:[[[self postInfo] objectForKey:STKCreatePostTypeKey] intValue]
                                     completion:^(STKPost *post, NSError *err) {
                                         if(!err) {
                                             [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                                         } else {
                                             
                                         }
                                     }];
    
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

- (IBAction)changeImage:(id)sender
{
    [[STKImageChooser sharedImageChooser] initiateImageChooserForViewController:self
                                                                     completion:^(UIImage *img) {
                                                                         [self setPostImage:img];
                                                                         [[self imageView] setImage:img];
                                                                         if(img) {
                                                                             [[self imageButton] setImage:nil forState:UIControlStateNormal];
                                                                         }
                                                                     }];
}


@end
