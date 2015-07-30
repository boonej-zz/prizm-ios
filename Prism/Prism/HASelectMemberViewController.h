//
//  HASelectMemberViewController.h
//  Prizm
//
//  Created by Jonathan Boone on 5/3/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKOrgStatus;

@protocol HASelectMemberProtocol<NSObject>

@optional
- (void)didSelectMember:(STKOrgStatus *)member;
- (void)finishedMakingSelections:(NSArray *)selections;

@end

@interface HASelectMemberViewController : UIViewController

@property (nonatomic, strong) NSArray *members;
@property (nonatomic, weak) id<HASelectMemberProtocol> delegate;
@property (nonatomic, strong) NSMutableArray *selections;

- (id)initWithSelection:(id)selection predicate:(NSPredicate *)predicate;

@end
