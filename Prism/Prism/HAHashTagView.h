//
//  HAHashTagView.h
//  Prizm
//
//  Created by Jonathan Boone on 9/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAHashTagView;

@protocol HAHashTagViewDelegate

- (void)hashTagTapped:(HAHashTagView *)sender;

@end

@interface HAHashTagView : UIView

@property (nonatomic, strong) NSString * text;
@property (nonatomic, getter = isAnimating) BOOL animating;
@property (nonatomic, weak) id<HAHashTagViewDelegate> delegate;
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic, strong) UILabel * textLabel;
@property (nonatomic, weak) NSDictionary *sisterTags;


- (void)presentAndDismiss;
- (void)markSelected;

@end