 //
//  STKCreateProfileViewController.m
//  Prism
//
//  Created by Joe Conway on 12/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKCreateProfileViewController.h"
#import "STKTextFieldCell.h"
#import "STKGenderCell.h"
#import "STKWebViewController.h"
#import "STKDateCell.h"
#import "STKUserStore.h"
#import "STKResolvingImageView.h"
#import "STKImageStore.h"
#import "STKProcessingView.h"
#import "STKImageChooser.h"
#import "STKUser.h"
#import "STKBaseStore.h"
#import "STKTextInputViewController.h"

@import AddressBook;
@import Social;
@import CoreLocation;

const long STKCreateProgressUploadingCover = 1;
const long STKCreateProgressUploadingProfile = 2;
const long STKCreateProgressGeocoding = 4;

@interface STKCreateProfileViewController ()
    <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) STKUser *user;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic) long progressMask;
@property (nonatomic) BOOL retryRegisterOnProgressMaskClear;

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *items;

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet STKResolvingImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic, strong) NSIndexPath *editingIndexPath;

@property (weak, nonatomic) IBOutlet UIButton *profilePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *coverPhotoButton;

@property (weak, nonatomic) IBOutlet UIButton *tosButton;

@property (weak, nonatomic) IBOutlet UIView *coverOverlayView;
@property (nonatomic, getter = isEditingProfile) BOOL editingProfile;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topOffset;

- (IBAction)previousTapped:(id)sender;
- (IBAction)nextTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;
- (IBAction)changeCoverPhoto:(id)sender;
- (IBAction)changeProfilePhoto:(id)sender;
- (IBAction)showTOS:(id)sender;
- (IBAction)finishProfile:(id)sender;

@end

@implementation STKCreateProfileViewController

- (id)initWithProfileForCreating:(STKUser *)user
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        [self setUser:user];
        if(![self user])
            [self setUser:[[STKUser alloc] init]];
        
        _items = @[
                   @{@"title" : @"Email", @"key" : @"email",
                     @"options" : @{@"keyboardType" : @(UIKeyboardTypeEmailAddress)}},
                   
                   @{@"title" : @"Password", @"key" : @"password",
                     @"options" : @{@"secureTextEntry" : @(YES)}},
                   
                   @{@"title" : @"First Name", @"key" : @"firstName",
                     @"options" : @{@"autocapitalizationType" : @(UITextAutocapitalizationTypeWords)}},
                   
                   @{@"title" : @"Last Name", @"key" : @"lastName",
                     @"options" : @{@"autocapitalizationType" : @(UITextAutocapitalizationTypeWords)}},
                   
                   @{@"title" : @"Gender", @"key" : @"gender", @"cellType" : @"gender"},
                   
                   @{@"title" : @"Date of Birth", @"key" : @"birthday", @"cellType" : @"date"},
                   
                   @{@"title" : @"Zip Code", @"key" : @"zipCode", @"options" : @{@"keyboardType" : @(UIKeyboardTypeNumberPad)}}
                   ];
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        [_locationManager setDelegate:self];
        
    }
    return self;

}

- (id)initWithProfileForEditing:(STKUser *)user
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        [self setUser:user];
        [self setEditingProfile:YES];
        [[self navigationItem] setTitle:@"Edit Profile"];
        
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveChanges:)];
        [[self navigationItem] setRightBarButtonItem:bbi];
        
        _items = @[
                   // Public
                   @{@"title" : @"First Name", @"key" : @"firstName",
                     @"options" : @{@"autocapitalizationType" : @(UITextAutocapitalizationTypeWords)}},
                   
                   @{@"title" : @"Last Name", @"key" : @"lastName",
                     @"options" : @{@"autocapitalizationType" : @(UITextAutocapitalizationTypeWords)}},

                   @{@"title" : @"Info", @"key" : @"blurb", @"cellType" : @"textView"},
                   
                   @{@"title" : @"Website", @"key" : @"website",
                     @"options" : @{@"keyboardType" : @(UIKeyboardTypeURL)}},
                   
                   
                   // Private
                   @{@"title" : @"Private", @"image" : [UIImage imageNamed:@"lockpassword"], @"cellType" : @"none"},
                   
                   @{@"title" : @"Email", @"key" : @"email",
                     @"options" : @{@"keyboardType" : @(UIKeyboardTypeEmailAddress)}},
                   
                   @{@"title" : @"Password", @"key" : @"password",
                     @"options" : @{@"secureTextEntry" : @(YES)}},
                   
                   
                   @{@"title" : @"Gender", @"key" : @"gender", @"cellType" : @"gender"},
                   
                   @{@"title" : @"Date of Birth", @"key" : @"birthday", @"cellType" : @"date"},
                   
                   @{@"title" : @"Zip Code", @"key" : @"zipCode", @"options" : @{@"keyboardType" : @(UIKeyboardTypeNumberPad)}}
                   ];
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        [_locationManager setDelegate:self];

    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"STKCreateProfileViewController"
                                   reason:@"Must pick editing/editing"
                                 userInfo:nil];
    return nil;
}

- (void)configureInterface
{
    [[self backgroundImageView] setHidden:![self isEditingProfile]];
    
    
    if([[self user] coverPhotoPath] || [[self user] coverPhoto] || [self progressMask] & STKCreateProgressUploadingCover) {
        [[self coverOverlayView] setHidden:NO];
        [[self coverPhotoButton] setTitle:@"Edit" forState:UIControlStateNormal];
        [[self coverPhotoButton] setTitleColor:STKTextColor forState:UIControlStateNormal];
        [[self coverPhotoButton] setImage:[UIImage imageNamed:@"btn_pic_uploadedit"] forState:UIControlStateNormal];
    } else {
        [[self coverOverlayView] setHidden:YES];
        [[self coverPhotoButton] setTitleColor:STKLightBlueColor forState:UIControlStateNormal];
        [[self coverPhotoButton] setTitle:@"Upload" forState:UIControlStateNormal];
        [[self coverPhotoButton] setImage:[UIImage imageNamed:@"upload_image"] forState:UIControlStateNormal];
    }
    
    if([[self user] profilePhotoPath] || [[self user] profilePhoto] || [self progressMask] & STKCreateProgressUploadingProfile) {
        [[self profilePhotoButton] setTitle:@"Edit" forState:UIControlStateNormal];
        [[self profilePhotoButton] setTitleColor:STKTextColor forState:UIControlStateNormal];
        [[self profilePhotoButton] setBackgroundImage:[[self user] profilePhoto] forState:UIControlStateNormal];
    } else {
        [[self profilePhotoButton] setBackgroundImage:[UIImage imageNamed:@"upload_camera"] forState:UIControlStateNormal];
        [[self profilePhotoButton] setTitle:@"Upload" forState:UIControlStateNormal];
        [[self profilePhotoButton] setTitleColor:STKLightBlueColor forState:UIControlStateNormal];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(![self isEditingProfile]) {
        [[self tableView] setTableFooterView:[self footerView]];
    } else {
        [[self topOffset] setConstant:64];
    }
    [[self tableView] setRowHeight:44];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[self tableView] setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [[self tableView] setDelaysContentTouches:NO];
    
    NSMutableAttributedString *title = [[[self tosButton] attributedTitleForState:UIControlStateNormal] mutableCopy];
    [title addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, [title length])];
    [title addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:33.0 / 255.0
                                                                             green:144.0 / 255.0
                                                                              blue:255.0 / 255.0
                                                                             alpha:1] range:NSMakeRange(0, [title length])];
    [[self tosButton] setAttributedTitle:title forState:UIControlStateNormal];
    
    [[self coverOverlayView] setHidden:YES];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self tableView] flashScrollIndicators];
}

- (void)setProgressMask:(long)progressMask
{
    long old = _progressMask;
    _progressMask = progressMask;
    
    if([self retryRegisterOnProgressMaskClear] && old != 0 && _progressMask == 0) {
        [self setRetryRegisterOnProgressMaskClear:NO];
        [self finishProfile:nil];
    }
}

- (void)saveChanges:(id)sender
{
    [STKProcessingView present];
    [[STKUserStore store] updateUserDetails:[self user] completion:^(STKUser *u, NSError *err) {
        [STKProcessingView dismiss];
        if(err) {
            UIAlertView *av = [STKErrorStore alertViewForError:err delegate:nil];
            [av show];
        }
    }];
}

- (void)dateChanged:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[self user] setBirthday:[sender date]];
}

- (BOOL)verifyValue:(id)val forKey:(NSString *)key errorMessage:(NSString **)msg
{
    if(!msg)
        @throw [NSException exceptionWithName:@"STKCreateProfileViewController" reason:@"Have to pass errorMessage param to verifyValue:forKey:errorMessage:" userInfo:nil];
    
    
    __block NSString *title = nil;
    [[self items] enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        if([[d objectForKey:@"key"] isEqualToString:key]) {
            title = [d objectForKey:@"title"];
            *stop = YES;
        }
    }];

    if(!val) {
        *msg = [NSString stringWithFormat:@"%@ is required.", title];
        return NO;
    }
    
    if([key isEqualToString:@"email"]) {
        NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:@"[^@]*@[^\\.]*\\..{2,}" options:0 error:nil];
        NSTextCheckingResult *tr = [exp firstMatchInString:val options:0 range:NSMakeRange(0, [val length])];
        if(!tr) {
            *msg = [NSString stringWithFormat:@"Email address must be valid."];
            return NO;
        }
    }

    
    if([key isEqualToString:@"firstName"] || [key isEqualToString:@"lastName"] || [key isEqualToString:@"zipCode"]) {
        if([val length] < 1) {
            *msg = [NSString stringWithFormat:@"%@ is required.", title];
            return NO;
        }
    }
    if([key isEqualToString:@"password"]) {
        if([val length] < 6) {
            *msg = [NSString stringWithFormat:@"Please choose a password that is at least 6 characters long."];
            return NO;
        }
    }
    if([key isEqualToString:@"birthday"]) {
        NSDate *ageMin = [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 365.25 * 13];
        if([val timeIntervalSinceDate:ageMin] > 0) {
            *msg = @"You must be 13 years of age to create an account.";
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)verifyFields:(BOOL)displayFailures
{
    __block BOOL result = YES;
    [[self items] enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        NSString *outMsg = nil;
        NSString *val = [[self user] valueForKey:[d objectForKey:@"key"]];
        if(![self verifyValue:val forKey:[d objectForKey:@"key"] errorMessage:&outMsg]) {
            result = NO;
            *stop = YES;
            if(displayFailures) {
                
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Something is Missing" message:outMsg
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];
                
                NSIndexPath *ip = [NSIndexPath indexPathForRow:idx inSection:0];
                [[self tableView] scrollToRowAtIndexPath:ip
                                        atScrollPosition:UITableViewScrollPositionNone
                                                animated:NO];
                UITableViewCell *c = [[self tableView] cellForRowAtIndexPath:ip];
                
                CAKeyframeAnimation *kf = [CAKeyframeAnimation animationWithKeyPath:@"backgroundColor"];
                
                [kf setValues:@[(__bridge id)[[UIColor clearColor] CGColor],
                                (__bridge id)[[UIColor colorWithRed:1 green:0 blue:0 alpha:0.4] CGColor],
                                (__bridge id)[[UIColor clearColor] CGColor],
                                (__bridge id)[[UIColor colorWithRed:1 green:0 blue:0 alpha:0.4] CGColor],
                                (__bridge id)[[UIColor clearColor] CGColor]]];
                [kf setDuration:0.45];
                [[[c contentView] layer] addAnimation:kf forKey:@"pulse"];
            }
        }
    }];

    if(result) {
        if(![[self user] coverPhotoPath]) {
            if(!([self progressMask] & STKCreateProgressUploadingCover)) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Choose a Cover Photo" message:@"Upload a cover photo before continuing." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                return NO;
            }
        }
        if(![[self user] profilePhotoPath]) {
            if(!([self progressMask] & STKCreateProgressUploadingProfile)) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Choose a Profile Photo" message:@"Upload a profile photo before continuing." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                return NO;
            }
        }
    }
    
    return result;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[self locationManager] startUpdatingLocation];
    
    // If we are using an external service, remove password from options
    if([[self user] externalServiceType]) {
        NSArray *i = [[self items] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key != %@", @"password"]];
        _items = i;
    }
    
    if(![[self user] gender]) {
        [[self user] setGender:STKUserGenderFemale];
    }
    
    // If we got the profile/cover photo from ane external service, upload it to our server
    if([[self user] profilePhoto]) {
        [self setProfileImage:[[self user] profilePhoto]];
    }
    if([[self user] coverPhoto]) {
        [self setCoverImage:[[self user] coverPhoto]];
    }
    if([[self user] coverPhotoPath]) {
        NSString *imageURLString = [[self user] coverPhotoPath];
        [[self user] setCoverPhotoPath:nil];
        [self setProgressMask:STKCreateProgressUploadingCover | [self progressMask]];
        [[STKImageStore store] fetchImageForURLString:imageURLString
                                           completion:^(UIImage *img) {
                                               [self setCoverImage:img];
                                           }];
    }
    if([[self user] profilePhotoPath]) {
        NSString *imageURLString = [[self user] profilePhotoPath];
        [[self user] setProfilePhotoPath:nil];
        [self setProgressMask:STKCreateProgressUploadingProfile | [self progressMask]];

        [[STKImageStore store] fetchImageForURLString:imageURLString
                                           completion:^(UIImage *img) {
                                               [self setProfileImage:img];
                                           }];
    }
    [self configureInterface];
    [[self tableView] reloadData];
}

- (void)keyboardWillAppear:(NSNotification *)note
{
    CGRect r = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, r.size.height, 0)];
    
    
}

- (void)keyboardWillDisappear:(NSNotification *)note
{
    [[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (UITableViewCell *)visibleCellForKey:(NSString *)key
{
    NSArray *visibleCells = [[self tableView] visibleCells];
    
    __block int zipIndex = -1;
    [[self items] enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        if([[d objectForKey:@"key"] isEqualToString:key]) {
            zipIndex = idx;
            *stop = YES;
        }
    }];
    
    for(UITableViewCell *c in visibleCells) {
        NSIndexPath *ip = [[self tableView] indexPathForCell:c];
        if([ip row] == zipIndex) {
            return c;
        }
    }
    return nil;
}

- (void)textFieldDidChange:(UITextField *)sender atIndexPath:(NSIndexPath *)ip
{
    NSDictionary *item = [[self items] objectAtIndex:[ip row]];
    NSString *text = [sender text];
    [[self user] setValue:text forKey:[item objectForKey:@"key"]];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
                     atIndexPath:(NSIndexPath *)ip
{
    if([[[[self items] objectAtIndex:[ip row]] objectForKey:@"cellType"] isEqualToString:@"date"]) {
        STKDateCell *c = (STKDateCell *)[[self tableView] cellForRowAtIndexPath:ip];
        [[self user] setBirthday:[c date]];
    }
    [self setEditingIndexPath:ip];
}

- (void)textFieldShouldReturn:(UITextField *)textField
                  atIndexPath:(NSIndexPath *)ip
{
    NSArray *allKeys = [[self items] valueForKey:@"key"];
    for(NSString *k in allKeys) {
        if(![k isKindOfClass:[NSNull class]]) {
            if([[self user] valueForKey:k]) {
                NSLog(@"OK");
            } else {
                NSLog(@"not ok %@", k);
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *l = [locations lastObject];
    if([[NSDate date] timeIntervalSinceDate:[l timestamp]] < 5 * 60) {
        
        [self setProgressMask:[self progressMask] | STKCreateProgressGeocoding];
        _geocoder = [[CLGeocoder alloc] init];
        [_geocoder reverseGeocodeLocation:l
                        completionHandler:^(NSArray *placemarks, NSError *error) {
                            [self setProgressMask:[self progressMask] & ~STKCreateProgressGeocoding];
                            if(!error) {
                                CLPlacemark *cp = [placemarks lastObject];
                                if([cp postalCode] && ![[self user] zipCode]) {
                                    [[self user] setZipCode:[cp postalCode]];
                                    [[self user] setCity:[cp locality]];
                                    
                                    [[self user] setState:[cp administrativeArea]];

                                    
                                    UITableViewCell *c = [self visibleCellForKey:@"zipCode"];
                                    [[self tableView] reloadRowsAtIndexPaths:@[[[self tableView] indexPathForCell:c]]
                                                            withRowAnimation:UITableViewRowAnimationAutomatic];
                                }
                            }
                            _geocoder = nil;
                        }];
        [[self locationManager] stopUpdatingLocation];
    }
}


- (IBAction)changeCoverPhoto:(id)sender
{
    [[STKImageChooser sharedImageChooser] initiateImageChooserForViewController:self
                                                                        forType:STKImageChooserTypeCover
                                                                     completion:^(UIImage *img) {
        if(img)
            [self setCoverImage:img];
        [self configureInterface];
    }];
}

- (IBAction)changeProfilePhoto:(id)sender
{
    [[STKImageChooser sharedImageChooser] initiateImageChooserForViewController:self
                                                                        forType:STKImageChooserTypeProfile
                                                                     completion:^(UIImage *img) {
        if(img)
            [self setProfileImage:img];
        [self configureInterface];
    }];
}


- (void)setProfileImage:(UIImage *)img
{
    if(img) {
        [self setProgressMask:[self progressMask] | STKCreateProgressUploadingProfile];
        
        CGRect r = CGRectZero;
        r.size = STKUserProfilePhotoSize;
        r.size.width *= 2.0;
        r.size.height *= 2.0;
        UIImage *resizedImage = [[STKImageStore store] uploadImage:img size:r.size intoDirectory:@"profile" completion:^(NSString *URLString, NSError *err) {
            if(!err) {
                [[self user] setProfilePhotoPath:URLString];
            } else {
                [[self user] setProfilePhotoPath:nil];
                [[self user] setProfilePhoto:nil];
                
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Profile Image Upload Failed"
                                                             message:@"The profile image failed to upload. Ensure you have an internet connection and try again."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];
                
            }

            [self setProgressMask:[self progressMask] & ~STKCreateProgressUploadingProfile];
            [self configureInterface];
        }];
        
        UIGraphicsBeginImageContextWithOptions(r.size, NO, 0.0);
        
        UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(r, 6, 6)];
        

        [STKTextTransparentColor set];
        [bp setLineWidth:6 * [[UIScreen mainScreen] scale]];
        [bp stroke];
        [bp addClip];
        
        [resizedImage drawInRect:r];
        
        [[UIColor colorWithWhite:0 alpha:0.5] set];
        [bp fill];

        [[self user] setProfilePhoto:UIGraphicsGetImageFromCurrentImageContext()];

        UIGraphicsEndImageContext();
    }
    [self configureInterface];
}

- (void)setCoverImage:(UIImage *)img
{
    UIImage *resizedImage = img;
    if(img) {
        [self setProgressMask:[self progressMask] | STKCreateProgressUploadingCover];
        CGSize sz = STKUserCoverPhotoSize;
        sz.width *= 2.0;
        sz.height *= 2.0;
        resizedImage = [[STKImageStore store] uploadImage:img size:STKUserCoverPhotoSize intoDirectory:@"covers" completion:^(NSString *URLString, NSError *err) {
            if(!err) {
                [[self user] setCoverPhotoPath:URLString];
            } else {
                [[self user] setCoverPhotoPath:nil];
                [self setCoverImage:nil];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cover Image Upload Failed"
                                                             message:@"The cover image failed to upload. Ensure you have an internet connection and try again."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];
            }
            [self setProgressMask:[self progressMask] & ~STKCreateProgressUploadingCover];
        }];
    }

    [[self coverPhotoImageView] setImage:resizedImage];
    [self configureInterface];
}



- (IBAction)showTOS:(id)sender
{
    STKWebViewController *vc = [[STKWebViewController alloc] init];
    [vc setUrl:[NSURL URLWithString:@"http://higheraltitude.co"]];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];

    [self presentViewController:nvc animated:YES completion:nil];
}

- (IBAction)finishProfile:(id)sender
{
    [[self view] endEditing:YES];
    if([self verifyFields:YES]) {
        [STKProcessingView present];
        
        if([self progressMask] != 0) {
            [self setRetryRegisterOnProgressMaskClear:YES];
            return;
        }
        
        void (^registerBlock)(void) = ^{
            [[STKUserStore store] registerAccount:[self user]
                                       completion:^(id user, NSError *err) {
                                           [STKProcessingView dismiss];
                                           if(!err) {
                                               [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                                           } else {
                                               [[STKErrorStore alertViewForError:err delegate:nil] show];
                                           }
                                       }];
        };
        
        if(![[self user] city]) {
            CLGeocoder *gc = [[CLGeocoder alloc] init];
            [gc geocodeAddressDictionary:@{(__bridge NSString *)kABPersonAddressZIPKey : [[self user] zipCode]}
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           if(!error) {
                               CLPlacemark *cp = [placemarks lastObject];
                               [[self user] setCity:[cp locality]];

                               NSString *state = [cp administrativeArea];
                               [[self user] setState:state];
                               
                               registerBlock();
                           } else {
                               [STKProcessingView dismiss];
                               UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Zip Code Error"
                                                                            message:@"There was a problem determining your location from the provided zip code. Ensure you have an internet connection and a valid zip code and try again."
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                               [av show];
                           }
                       }];
        } else {
            registerBlock();
        }
    }
}


- (void)maleButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[self user] setGender:STKUserGenderMale];
}

- (void)femaleButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[self user] setGender:STKUserGenderFemale];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [[self items] objectAtIndex:[indexPath row]];
    NSLog(@"%@", item);
    if([[item objectForKey:@"cellType"] isEqualToString:@"textView"]) {
        STKTextInputViewController *ivc = [[STKTextInputViewController alloc] init];
        [ivc setText:[[self user] valueForKeyPath:[item objectForKey:@"key"]]];
        
        __weak STKTextInputViewController *wivc = ivc;
        [ivc setCompletion:^(NSString *str) {
            [[self user] setValue:str forKeyPath:[item objectForKey:@"key"]];
            [[STKUserStore store] updateUserDetails:[self user] completion:^(STKUser *u, NSError *err) {
                
            }];
            [[wivc navigationController] popViewControllerAnimated:YES];
        }];
        [[self navigationController] pushViewController:ivc animated:YES];
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self items] count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [[self items] objectAtIndex:[indexPath row]];

    NSString *cellType = [item objectForKey:@"cellType"];
    if(cellType) {
        if([cellType isEqualToString:@"gender"]) {
            STKGenderCell *c = [STKGenderCell cellForTableView:tableView target:self];
            if([[[self user] gender] isEqualToString:STKUserGenderFemale]) {
                [[c femaleButton] setSelected:YES];
                [[c maleButton] setSelected:NO];
            } else {
                [[c femaleButton] setSelected:NO];
                [[c maleButton] setSelected:YES];
            }
            return c;
        } else if([cellType isEqualToString:@"date"]) {
            STKDateCell *c = [STKDateCell cellForTableView:tableView target:self];
            [c setDefaultDate:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*365.25*16]];
            [[c label] setText:[item objectForKey:@"title"]];
            [c setDate:[[self user] birthday]];
            [[c textField] setInputAccessoryView:[self toolbar]];
            return c;
        } else if([cellType isEqualToString:@"none"]) {
            UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
            if(!c) {
                c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
                [[c textLabel] setFont:STKFont(14)];
                [[c textLabel] setTextColor:[UIColor whiteColor]];
            }
            
            [[c textLabel] setText:[item objectForKey:@"title"]];
            [[c imageView] setImage:[item objectForKey:@"image"]];
            return c;
        }
    }
    
    STKTextFieldCell *c = [STKTextFieldCell cellForTableView:tableView target:self];
    
    if([cellType isEqual:@"textView"]) {
        [[c textField] setEnabled:NO];
    } else {
        [[c textField] setEnabled:YES];
    }
    
    [[c label] setText:[item objectForKey:@"title"]];
    NSString *value = [[self user] valueForKey:[item objectForKey:@"key"]];
    if(value) {
        [[c textField] setText:value];
    } else {
        [[c textField] setText:nil];
    }
    
    NSDictionary *textOptions = [item objectForKey:@"options"];
    for(NSString *optKey in textOptions) {
        if([optKey isEqualToString:@"autocapitalizationType"])
            [[c textField] setAutocapitalizationType:[[textOptions objectForKey:optKey] intValue]];
        else
            [[c textField] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        
        if([optKey isEqualToString:@"secureTextEntry"])
            [[c textField] setSecureTextEntry:[[textOptions objectForKey:optKey] boolValue]];
        else
            [[c textField] setSecureTextEntry:NO];
        
        if([optKey isEqualToString:@"keyboardType"])
            [[c textField] setKeyboardType:[[textOptions objectForKey:optKey] intValue]];
        else
            [[c textField] setKeyboardType:UIKeyboardTypeDefault];
    }

    [[c textField] setInputAccessoryView:[self toolbar]];
    
    return c;
}
- (IBAction)previousTapped:(id)sender
{
    int row = (int)[[self editingIndexPath] row] - 1;
    if(row < 0)
        row = (int)[[self items] count] - 1;
    
    [self setEditingIndexPath:[NSIndexPath indexPathForRow:row
                                                 inSection:0]];
    UITableViewCell *c = [[self tableView] cellForRowAtIndexPath:[self editingIndexPath]];
    if(!c) {
        [[self tableView] scrollToRowAtIndexPath:[self editingIndexPath]
                                atScrollPosition:UITableViewScrollPositionNone
                                        animated:NO];
        c = [[self tableView] cellForRowAtIndexPath:[self editingIndexPath]];
    }
    if([c respondsToSelector:@selector(textField)]) {
        [[(STKTextFieldCell *)c textField] becomeFirstResponder];
    } else {
        [self previousTapped:nil];
    }
}

- (IBAction)nextTapped:(id)sender
{
    int row = (int)[[self editingIndexPath] row] + 1;
    if(row >= [[self items] count])
        row = 0;
    
    [self setEditingIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    UITableViewCell *c = [[self tableView] cellForRowAtIndexPath:[self editingIndexPath]];
    if(!c) {
        [[self tableView] scrollToRowAtIndexPath:[self editingIndexPath]
                                atScrollPosition:UITableViewScrollPositionNone
                                        animated:NO];
        c = [[self tableView] cellForRowAtIndexPath:[self editingIndexPath]];
    }
    if([c respondsToSelector:@selector(textField)]) {
        if([[(STKTextFieldCell *)c textField] canBecomeFirstResponder]) {
            [[(STKTextFieldCell *)c textField] becomeFirstResponder];
        } else {
            [self nextTapped:nil];
        }
    } else {
        [self nextTapped:nil];
    }
}

- (IBAction)doneTapped:(id)sender
{
    [[self view] endEditing:YES];
}

@end
