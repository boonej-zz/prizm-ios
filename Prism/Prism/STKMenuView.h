//
//  STKMenuView.h
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKMenuView;

@protocol STKMenuViewDelegate <NSObject>

- (void)menuView:(STKMenuView *)menuView didSelectItemAtIndex:(int)idx;
- (void)menuView:self didLongPressItemAtIndex:(int)idx;

@end

@interface STKMenuView : UIControl

@property (nonatomic, getter = isVisible) BOOL visible;
@property (nonatomic, weak) id <STKMenuViewDelegate> delegate;
@property (nonatomic) int selectedIndex;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic) int notificationCount;

- (void)setVisible:(BOOL)visible animated:(BOOL)animated;

- (void)setItems:(NSArray *)items;

- (void)performInAnimation;
- (void)performOutAnimationWithCompletion:(void (^)(void))block;
@end
