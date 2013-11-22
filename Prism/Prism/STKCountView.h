//
//  STKCountView.h
//  Prism
//
//  Created by Joe Conway on 11/18/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKCountView : UIView
@property (nonatomic) int followerCount;
@property (nonatomic) int followingCount;
@property (nonatomic) int postCount;
@property (nonatomic, strong) NSDate *joinDate;
@end
