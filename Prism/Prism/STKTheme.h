//
//  STKTheme.h
//  Prizm
//
//  Created by Jonathan Boone on 11/18/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface STKTheme : NSManagedObject

@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * backgroundURL;
@property (nonatomic, retain) NSString * textColor;
@property (nonatomic, retain) NSString * dominantColor;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * modifyDate;
@property (nonatomic, retain) NSManagedObject *organization;

@end
