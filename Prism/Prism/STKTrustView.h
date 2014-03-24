//
//  STKTrustView.h
//  Prism
//
//  Created by Joe Conway on 11/18/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKUser, STKTrustView;

@protocol STKTrustViewDelegate <NSObject>

- (void)trustView:(STKTrustView *)tv didSelectCircleAtIndex:(int)idx;

@end

@interface STKTrustView : UIView

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) STKUser *user;
@property (nonatomic, weak) id <STKTrustViewDelegate> delegate;

@end
