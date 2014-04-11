//
//  STKAccountChooserViewController.h
//  Prism
//
//  Created by Joe Conway on 12/23/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACAccount, STKAccountChooserViewController;

@protocol STKAccountChooserDelegate <NSObject>

- (void)accountChooser:(STKAccountChooserViewController *)chooser
      didChooseAccount:(ACAccount *)account;

@end

@interface STKAccountChooserViewController : UIViewController

- (id)initWithAccounts:(NSArray *)accounts;

@property (nonatomic, weak) id <STKAccountChooserDelegate> delegate;
@property (nonatomic, strong) UIImage *backgroundImage;

@end
