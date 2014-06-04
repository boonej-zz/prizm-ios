//
//  STKSearchTrustsViewController.h
//  Prism
//
//  Created by Jesse Stevens Black on 6/3/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    STKSearchUsersNotInTrust = 0,
    STKSearchUsersToFollow = 1
}STKSearchUsersType;

@interface STKSearchUsersViewController : UIViewController

- (id)initWithSearchType:(STKSearchUsersType)type;

@end
