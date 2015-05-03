//
//  HASelectLeaderControllerViewController.h
//  Prizm
//
//  Created by Jonathan Boone on 5/3/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKOrgStatus;

@protocol HASelectLeaderProtocol

- (void)didSelectLeader:(STKOrgStatus *)leader;

@end

@interface HASelectLeaderControllerViewController : UIViewController

@property (nonatomic, strong) NSArray *members;
@property (nonatomic, weak) id<HASelectLeaderProtocol> delegate;

- (id)initWithSelection:(NSString *)selection;

@end
