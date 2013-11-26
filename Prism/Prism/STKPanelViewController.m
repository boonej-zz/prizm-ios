//
//  STKPanelViewController.m
//  Prism
//
//  Created by Joe Conway on 11/25/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKPanelViewController.h"

@interface STKPanelViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *backgroundImage;
@end

@implementation STKPanelViewController

- (id)initWithBackgroundImage:(UIImage *)image
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _backgroundImage = image;
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self
                                                                             action:@selector(dismiss:)];
        [[self navigationItem] setLeftBarButtonItem:bbi];
    }
    return self;

}

- (void)dismiss:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithBackgroundImage:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self imageView] setImage:[self backgroundImage]];
}

@end
