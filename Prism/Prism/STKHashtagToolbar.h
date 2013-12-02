//
//  STKHashtagToolbar.h
//  Prism
//
//  Created by Jesse Stevens Black on 11/28/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKHashtagToolbar;

@protocol STKHashtagToolbarDelegate <NSObject, UIToolbarDelegate>

@optional

- (void)textToolbarIsDone:(STKHashtagToolbar *)tb;

@end


@interface STKHashtagToolbar : UIToolbar

@property (nonatomic, weak) id <STKHashtagToolbarDelegate> delegate;
@property (nonatomic, strong) NSArray *hashtags;

+ (void)attachToTextView:(UITextView *)tv withDelegate:(id <STKHashtagToolbarDelegate>)del;

@end
