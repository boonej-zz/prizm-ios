//
//  STKExploreViewController.h
//  Prism
//
//  Created by Joe Conway on 11/6/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    STKExploreTypeLatest = 0,
    STKExploreTypePopular = 1,
    STKExploreTypeFeatured = 2
} STKExploreType;

@interface STKExploreViewController : UIViewController

- (void)setExploreType:(STKExploreType)type;
@end
