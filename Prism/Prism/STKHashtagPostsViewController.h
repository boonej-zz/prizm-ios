//
//  STKHashtagPostsViewController.h
//  Prism
//
//  Created by Joe Conway on 4/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKHashtagPostsViewController : UIViewController

- (id)initWithHashTag:(NSString *)hashTag;
@property (nonatomic) BOOL showsOwnBackButton;
@end
