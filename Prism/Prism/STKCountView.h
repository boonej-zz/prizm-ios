//
//  STKCountView.h
//  Prism
//
//  Created by Joe Conway on 11/18/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKCountView;

@protocol STKCountViewDelegate <NSObject>

- (void)countView:(STKCountView *)countView didSelectCircleAtIndex:(int)index;

@end

@interface STKCountView : UIView

@property (nonatomic, weak) id <STKCountViewDelegate> delegate;
@property (nonatomic, copy) NSArray *circleTitles; // Must be 3
@property (nonatomic, copy) NSArray *circleValues; // Must be 3

@end
