//
//  STKMessageMetaDataImage.h
//  Prizm
//
//  Created by Jonathan Boone on 5/8/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface STKMessageMetaDataImage : NSManagedObject<STKJSONObject>

@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSManagedObject *metaData;

@end
