//
//  STKMessageMetaData.h
//  Prizm
//
//  Created by Jonathan Boone on 5/8/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKMessage, STKMessageMetaDataImage;

@interface STKMessageMetaData : NSManagedObject<STKJSONObject>

@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSString * linkDescription;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) STKMessage *message;
@property (nonatomic, retain) STKMessageMetaDataImage *image;

@end
