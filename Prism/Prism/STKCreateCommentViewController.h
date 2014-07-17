//
//  STKCreateCommentViewController.h
//  Prism
//
//  Created by Joe Conway on 7/15/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKPost;


@interface STKCreateCommentViewController : UIViewController

@property (nonatomic, strong) STKPost *post;
@property (nonatomic) BOOL editingPostText;
@end
