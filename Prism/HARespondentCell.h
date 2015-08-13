//
//  HARespondentCell.h
//  Prizm
//
//  Created by Jonathan Boone on 8/13/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STKUser;

@interface HARespondentResult : NSObject

@property (nonatomic, strong) STKUser *user;
@property (nonatomic, strong) NSDate *completeDate;
@property (nonatomic, strong) NSDate *startDate;

@end

@class STKUser;

@interface HARespondentCell : UITableViewCell

@property (nonatomic, strong) HARespondentResult *result;

@end
