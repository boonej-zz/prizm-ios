//
//  STKCreateAccoladeViewController.m
//  Prism
//
//  Created by Joe Conway on 5/23/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKCreateAccoladeViewController.h"
#import "STKImageCollectionViewCell.h"
#import "STKMarkupController.h"
#import "STKPost.h"
#import "STKImageChooser.h"
#import "STKUser.h"
#import "STKMarkupUtilities.h"
#import "STKProcessingView.h"
#import "STKContentStore.h"
#import "STKImageStore.h"
#import "STKUserStore.h"

@interface STKCreateAccoladeViewController () <STKMarkupControllerDelegate, UICollectionViewDataSource, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UITextView *postTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *optionCollectionView;
@property (nonatomic, strong) STKMarkupController *markupController;

@property (nonatomic, getter = isUploadingImage) BOOL uploadingImage;
@property (nonatomic) BOOL waitingForImageToFinish;

@property (nonatomic, strong) NSArray *optionItems;

@property (nonatomic, strong) NSMutableDictionary *postInfo;
@property (nonatomic, strong) UIImage *postImage;
@property (nonatomic, strong) UIImage *originalPostImage;

- (void)changeImage:(id)sender;
- (IBAction)adjustImage:(id)sender;

@end

@implementation STKCreateAccoladeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _postInfo = [[NSMutableDictionary alloc] init];
        [_postInfo setObject:STKPostVisibilityPublic forKey:STKPostVisibilityKey];
        UIBarButtonItem *bbiCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        UIBarButtonItem *bbiPost = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(post:)];
        
        [[self navigationItem] setLeftBarButtonItem:bbiCancel];
        [[self navigationItem] setRightBarButtonItem:bbiPost];
        [[self navigationItem] setTitle:@"Accolades"];
    
        _optionItems = @[
                         @{@"key" : @"camera", @"image" : [UIImage imageNamed:@"btn_camera"], @"selectedImage" : [UIImage imageNamed:@"btn_camera_selected"], @"action" : @"changeImage:"}
   ];

        
    }
    return self;
}

- (NSString *)captionPlaceholder
{
    return [NSString stringWithFormat:@"Caption %@'s accolade...", [[self user] name]];
}

- (void)cancel:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)createPost
{
    
    if(![[self postInfo] objectForKey:STKPostURLKey]) {
        // Do a card
        NSString *postText = [[self postInfo] objectForKey:STKPostTextKey];
        UIImage *img = [STKMarkupUtilities imageForText:postText];
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
    
    [[self postInfo] setObject:STKPostTypeAccolade forKey:STKPostTypeKey];
    
    [[STKContentStore store] addPostWithInfo:[self postInfo] completion:^(STKPost *post, NSError *err) {
        [STKProcessingView dismiss];
        if(!err) {
            [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        } else {
            [[STKErrorStore alertViewForError:err delegate:nil] show];
        }
    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([[textView text] isEqualToString:[self captionPlaceholder]]) {
        [textView setText:@""];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [[self markupController] textView:textView updatedWithText:[textView text]];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if([textView text] == nil || [[textView text] isEqualToString:@""]) {
        [textView setText:[self captionPlaceholder]];
    }
}

- (void)post:(id)sender
{
    if([[[self postTextView] text] length] > 0 && ![[[self postTextView] text] isEqualToString:[self captionPlaceholder]]) {
        NSMutableAttributedString *text = [[[self postTextView] attributedText] mutableCopy];
    /*    [text enumerateAttributesInRange:NSMakeRange(0, [text length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            NSTextAttachment *attachment = [attrs objectForKey:NSAttachmentAttributeName];
            if(attachment) {
                NSURL *userURL = [attrs objectForKey:NSLinkAttributeName];
                if(userURL) {
                    NSString *uniqueID = [userURL host];
                    [text replaceCharactersInRange:range withString:[NSString stringWithFormat:@"@%@", uniqueID]];
                }
            }
        }];*/
        
        NSString *str = [text string];
        str = [str stringByAppendingFormat:@" @%@", [[self user] uniqueID]];
        [[self postInfo] setObject:str
                            forKey:STKPostTextKey];
    }
    
    if(![[self postInfo] objectForKey:STKPostTextKey] && ![[self postInfo] objectForKey:STKPostURLKey]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"A post must contain an image, text or both." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
    [self createPost];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    [[[self imageView] layer] setBorderColor:[STKTextColor CGColor]];
    //    [[[self imageView] layer] setBorderWidth:2];
    
    _markupController = [[STKMarkupController alloc] initWithDelegate:self];
    [[self markupController] setPreventsUserTagging:YES];
    
    [[self postTextView] setText:[self captionPlaceholder]];
    [[self postTextView] setInputAccessoryView:[[self markupController] view]];
    
    [[self optionCollectionView] registerNib:[UINib nibWithNibName:@"STKImageCollectionViewCell" bundle:nil]
                  forCellWithReuseIdentifier:@"STKImageCollectionViewCell"];
    [[self optionCollectionView] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
    [[self optionCollectionView] setScrollEnabled:NO];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
    [[[self navigationController] navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName : STKTextColor,
                                                                          NSFontAttributeName : STKFont(22)}];
    [[[self navigationController] navigationBar] setTintColor:[STKTextColor colorWithAlphaComponent:0.8]];

    [[self optionCollectionView] reloadData];

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


- (void)markupController:(STKMarkupController *)markupController
           didSelectUser:(STKUser *)user
        forMarkerAtRange:(NSRange)range
{
        // Disallow tagging
}

- (void)markupController:(STKMarkupController *)markupController
        didSelectHashTag:(NSString *)hashTag
        forMarkerAtRange:(NSRange)range
{
    if(range.location == NSNotFound) {
        range = NSMakeRange([[[self postTextView] textStorage] length], 0);
    }
    
    [[[self postTextView] textStorage] replaceCharactersInRange:range
                                                     withString:[NSString stringWithFormat:@"#%@ ", hashTag]];
    [[[self postTextView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:@" "
                                                                                              attributes:@{NSFontAttributeName : STKFont(14), NSForegroundColorAttributeName : STKTextColor}]];
    
    NSInteger newIndex = range.location + [hashTag length] + 2;
    [[self postTextView] setSelectedRange:NSMakeRange(newIndex, 0)];

}

- (void)markupControllerDidFinish:(STKMarkupController *)markupController
{
    [[self postTextView] resignFirstResponder];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self optionItems] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [[self optionItems] objectAtIndex:[indexPath row]];
    STKImageCollectionViewCell *cell = (STKImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"STKImageCollectionViewCell"
                                                                                                               forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
    [[cell backdropView] setBackgroundColor:[UIColor clearColor]];
    [[cell imageView] setImage:[item objectForKey:@"image"]];
    
    if([[item objectForKey:@"key"] isEqualToString:@"camera"]) {
        if([self postImage]) {
            [[cell imageView] setImage:[item objectForKey:@"selectedImage"]];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *action = [[[self optionItems] objectAtIndex:[indexPath row]] objectForKey:@"action"];
    if(action) {
        [self performSelector:NSSelectorFromString(action) withObject:nil];
    }
    
}

@end
