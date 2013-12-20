//
//  STKErrorStore.h
//  Prism
//
//  Created by Joe Conway on 12/19/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKErrorStore : NSObject

+ (UIAlertView *)alertViewForError:(NSError *)err
                          delegate:(id <UIAlertViewDelegate>)delegate;
+ (NSString *)errorStringForError:(NSError *)err;

@end
