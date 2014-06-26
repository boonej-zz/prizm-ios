//
//  STKExploreFilterViewController.h
//  Prism
//
//  Created by DJ HAYDEN on 6/25/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    STKExploreFilterTypeCategory = 0,
    STKExploreFilterTypeCouncil
}STKExploreFilterType;

@protocol STKExploreFilterDelegate <NSObject>

@optional

- (void)didChangeFilter:(STKExploreFilterType)filterType withValue:(NSString *)filter;

@end

@interface STKExploreFilterViewController : UIViewController

@property (nonatomic, weak) id <STKExploreFilterDelegate> delegate;
@property (nonatomic, strong) NSString *filterSelected;
@end
