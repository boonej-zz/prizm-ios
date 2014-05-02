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

- (void)hashtagToolbarClickedDone:(STKHashtagToolbar *)tb;
- (void)hashtagToolbar:(STKHashtagToolbar *)tb didPickHashtag:(NSString *)hashtag;

@end


@interface STKHashtagToolbar : UIView

@property (nonatomic, weak) id <STKHashtagToolbarDelegate> delegate;
@property (nonatomic, strong) NSArray *hashtags;


@end
