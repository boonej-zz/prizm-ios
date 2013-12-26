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
#import "STKProfileInformation.h"
#import "STKDateCell.h"
#import "STKUserStore.h"
#import "STKResolvingImageView.h"
#import "STKImageStore.h"
#import "STKProcessingView.h"

@import Social;
@import CoreLocation;

@interface STKCreateProfileViewController ()
    <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *items;

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (weak, nonatomic) IBOutlet STKResolvingImageView *coverPhotoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic, strong) NSIndexPath *editingIndexPath;

@property (weak, nonatomic) IBOutlet UIButton *profilePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *coverPhotoButton;

@property (nonatomic, weak) UIButton *photoTriggerButton;

- (IBAction)previousTapped:(id)sender;
- (IBAction)nextTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;
- (IBAction)changeCoverPhoto:(id)sender;
- (IBAction)changeProfilePhoto:(id)sender;
- (IBAction)showTOS:(id)sender;
- (IBAction)finishProfile:(id)sender;

@end

@implementation STKCreateProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _profileInformation = [[STKProfileInformation alloc] init];
        [_profileInformation setGender:@"female"];
        
        _items = @[
            @{@"title" : @"Email", @"key" : @"email", @"keyboardType" : @(UIKeyboardTypeEmailAddress)},
            @{@"title" : @"Password", @"key" : @"password", @"secure" : @(YES)},
            @{@"title" : @"First Name", @"key" : @"firstName", @"autocap" : @(UITextAutocapitalizationTypeWords)},
            @{@"title" : @"Last Name", @"key" : @"lastName", @"autocap" : @(UITextAutocapitalizationTypeWords)},
            @{@"title" : @"Gender", @"key" : @"gender", @"cellType" : @"gender"},
            @{@"title" : @"Date of Birth", @"key" : @"birthday", @"cellType" : @"date"},
            @{@"title" : @"Zip Code", @"key" : @"zipCode"}
        ];
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        [_locationManager setDelegate:self];
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setTableFooterView:[self footerView]];
    [[self tableView] setRowHeight:40];
    [[self tableView] setSeparatorColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:1]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [[self tableView] setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[self tableView] setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [[self tableView] setDelaysContentTouches:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self tableView] flashScrollIndicators];
}

- (void)dateChanged:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[self profileInformation] setBirthday:[sender date]];
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
        NSString *val = [[self profileInformation] valueForKey:[d objectForKey:@"key"]];
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
    
    if([[self profileInformation] externalService]) {
        NSArray *i = [[self items] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key != %@", @"password"]];
        _items = i;
    }
    
    if(![[self profileInformation] gender]) {
        [[self profileInformation] setGender:@"female"];
    }
    
    if([[self profileInformation] profilePhoto]) {
        [self setProfileImage:[[self profileInformation] profilePhoto]];
    }
    if([[self profileInformation] coverPhoto]) {
        [self setCoverImage:[[self profileInformation] coverPhoto]];
    }
    if([[self profileInformation] coverPhotoURLString]) {
        [[self coverPhotoImageView] setUrlString:[[self profileInformation] coverPhotoURLString]];
    }
    if([[self profileInformation] profilePhotoURLString]) {
        [[STKImageStore store] fetchImageForURLString:[[self profileInformation] profilePhotoURLString]
                                           completion:^(UIImage *img) {
                                               [self setProfileImage:img];
                                           }];
    }
    
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
    [[self profileInformation] setValue:text forKey:[item objectForKey:@"key"]];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
                     atIndexPath:(NSIndexPath *)ip
{
    if([[[[self items] objectAtIndex:[ip row]] objectForKey:@"cellType"] isEqualToString:@"date"]) {
        STKDateCell *c = (STKDateCell *)[[self tableView] cellForRowAtIndexPath:ip];
        [[self profileInformation] setBirthday:[c date]];
    }
    [self setEditingIndexPath:ip];
}

- (void)textFieldShouldReturn:(UITextField *)textField
                  atIndexPath:(NSIndexPath *)ip
{
    NSArray *allKeys = [[self items] valueForKey:@"key"];
    for(NSString *k in allKeys) {
        if([[self profileInformation] valueForKey:k]) {
            NSLog(@"OK");
        } else {
            NSLog(@"not ok %@", k);
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *l = [locations lastObject];
    if([[NSDate date] timeIntervalSinceDate:[l timestamp]] < 5 * 60) {
        
        _geocoder = [[CLGeocoder alloc] init];
        [_geocoder reverseGeocodeLocation:l
                        completionHandler:^(NSArray *placemarks, NSError *error) {
                            if(!error) {
                                CLPlacemark *cp = [placemarks lastObject];
                                if([cp postalCode] && ![[self profileInformation] zipCode]) {
                                    [[self profileInformation] setZipCode:[cp postalCode]];
                                    
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

- (void)promptForPhoto
{
    UIActionSheet *sheet = nil;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sheet = [[UIActionSheet alloc] initWithTitle:@"Select Option"
                                            delegate:self
                                   cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"Take New Photo", @"Choose Existing Photo", nil];
    } else {
        sheet = [[UIActionSheet alloc] initWithTitle:@"Select Option"
                                            delegate:self
                                   cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"Choose Existing Photo", nil];
    }
    
    [sheet showInView:[self view]];
    
    if(![self imagePickerController]) {
        [self setImagePickerController:[[UIImagePickerController alloc] init]];
        [[self imagePickerController] setAllowsEditing:YES];
        [[self imagePickerController] setDelegate:self];
    }
}

- (IBAction)changeCoverPhoto:(id)sender
{
    [self setPhotoTriggerButton:sender];
    [self promptForPhoto];
}

- (IBAction)changeProfilePhoto:(id)sender
{
    [self setPhotoTriggerButton:sender];
    [self promptForPhoto];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([actionSheet numberOfButtons] == 2) {
        if(buttonIndex == 0) {
            [[self imagePickerController] setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        } else {
            return;
        }
    } else if([actionSheet numberOfButtons] == 3) {
        if(buttonIndex == 0) {
            [[self imagePickerController] setSourceType:UIImagePickerControllerSourceTypeCamera];
        } else if(buttonIndex == 1) {
            [[self imagePickerController] setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        } else {
            return;
        }
    }
    
    [self presentViewController:[self imagePickerController] animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if([self photoTriggerButton] == [self profilePhotoButton])
        [self setProfileImage:img];
    else if([self photoTriggerButton] == [self coverPhotoButton])
        [self setCoverImage:img];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setProfileImage:(UIImage *)img
{
    CGRect b = [[self profilePhotoButton] bounds];
    UIGraphicsBeginImageContextWithOptions(b.size, NO, 0.0);
    
    UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(b, 6, 6)];
    [[UIColor colorWithRed:0 green:0 blue:1 alpha:1] set];
    [bp setLineWidth:6 * [[UIScreen mainScreen] scale]];
    [bp stroke];
    [bp addClip];
    
    [img drawInRect:b];
    
    [[self profilePhotoButton] setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateNormal];
    [[self profilePhotoButton] setTitle:@"" forState:UIControlStateNormal];
    
    UIGraphicsEndImageContext();
}

- (void)setCoverImage:(UIImage *)img
{
    [[self coverPhotoImageView] setImage:img];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
        [[STKUserStore store] registerAccount:[self profileInformation]
                                   completion:^(id user, NSError *err) {
                                       [STKProcessingView dismiss];
                                       if(!err) {
                                           [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                                       } else {
                                           [[STKErrorStore alertViewForError:err delegate:nil] show];
                                       }
                                   }];
    }

}


- (void)maleButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[self profileInformation] setGender:@"male"];
}

- (void)femaleButtonTapped:(id)sender atIndexPath:(NSIndexPath *)ip
{
    [[self profileInformation] setGender:@"female"];
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
            [c setBackdropColor:[UIColor clearColor]];
            if([[[self profileInformation] gender] isEqualToString:@"female"]) {
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
            [c setDate:[[self profileInformation] birthday]];
            [[c textField] setInputAccessoryView:[self toolbar]];
            return c;
        }
    }
    
    STKTextFieldCell *c = [STKTextFieldCell cellForTableView:tableView target:self];
    [c setBackdropColor:[UIColor clearColor]];
    
    [[c label] setText:[item objectForKey:@"title"]];
    NSString *value = [[self profileInformation] valueForKey:[item objectForKey:@"key"]];
    if(value) {
        [[c textField] setText:value];
    } else {
        [[c textField] setText:nil];
    }
    
    NSNumber *kbValue = [item objectForKey:@"keyboardType"];
    if(kbValue) {
        [[c textField] setKeyboardType:[kbValue intValue]];
    } else {
        [[c textField] setKeyboardType:UIKeyboardTypeDefault];
    }
    
    if([item objectForKey:@"inputView"]) {
        [[c textField] setInputView:[item objectForKey:@"inputView"]];
    } else {
        [[c textField] setInputView:nil];
    }
    
    if([item objectForKey:@"autocap"]) {
        [[c textField] setAutocapitalizationType:[[item objectForKey:@"autocap"] intValue]];
    } else {
        [[c textField] setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    }
    
    [[c textField] setSecureTextEntry:[[item objectForKey:@"secure"] boolValue]];
    
    
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
        [[(STKTextFieldCell *)c textField] becomeFirstResponder];
    } else {
        [self nextTapped:nil];
    }
}

- (IBAction)doneTapped:(id)sender
{
    [[self view] endEditing:YES];
}

@end
