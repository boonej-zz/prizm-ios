//
//  STKMessage.m
//  Prizm
//
//  Created by Jonathan Boone on 4/28/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "STKMessage.h"
#import "STKGroup.h"
#import "STKOrganization.h"
#import "STKUser.h"
#import "STKMarkupUtilities.h"
#import "STKMessageMetaData.h"
#import "STKMessageMetaDataImage.h"

@interface STKMessage()

@property (nonatomic, strong) NSAttributedString *storedAttributedText;

@end

@implementation STKMessage

@dynamic createDate;
@dynamic text;
@dynamic likesCount;
@dynamic creator;
@dynamic group;
@dynamic organization;
@dynamic likes;
@dynamic uniqueID;
@dynamic metaData;
@dynamic imageURL;
@synthesize storedAttributedText;

- (NSError *)readFromJSONObject:(id)jsonObject
{
    if([jsonObject isKindOfClass:[NSString class]]) {
        [self setUniqueID:jsonObject];
        return nil;
    }
    
    [self bindFromDictionary:jsonObject keyMap:[[self class] remoteToLocalKeyMap]];
    
    return nil;
}

+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"_id": @"uniqueID",
             @"text": @"text",
             @"likes_count": @"likesCount",
             @"organization": [STKBind bindMapForKey:@"organization" matchMap:@{@"uniqueID": @"_id"}],
             @"creator": [STKBind bindMapForKey:@"creator" matchMap:@{@"uniqueID": @"_id"}],
             @"group": [STKBind bindMapForKey:@"group" matchMap:@{@"uniqueID": @"_id"}],
             @"likes": [STKBind bindMapForKey:@"likes" matchMap:@{@"uniqueID": @"_id"}],
             @"create_date": [STKBind bindMapForKey:@"createDate" transform:STKBindTransformDateTimestamp],
             @"meta": [STKBind bindMapForKey:@"metaData" matchMap:@{@"messageID": @"message_id"}],
             @"image_url": @"imageURL",
             @"read": [STKBind bindMapForKey:@"read" matchMap:@{@"uniqueID": @"_id"}]
             };
}

- (NSAttributedString *)attributedMessageText
{
    if (self.storedAttributedText) {
        return self.storedAttributedText;
    }
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] init];
    NSDictionary *baseAttributes = @{NSFontAttributeName : STKFont(14), NSForegroundColorAttributeName : [UIColor HATextColor]};
    
    NSAttributedString *mainMessage = [STKMarkupUtilities renderedTextForText:self.text attributes:baseAttributes];
    [s appendAttributedString:mainMessage];
    if (self.metaData) {
        STKMessageMetaData *meta = self.metaData;
        NSDictionary *titleAttributes = nil;
        NSDictionary *descAttributes = nil;
//        NSLog(@"%@", meta);
        if (meta.urlString) {
            titleAttributes = @{NSFontAttributeName : STKBoldFont(14), NSForegroundColorAttributeName : [UIColor HATextColor], NSLinkAttributeName: [NSURL URLWithString:meta.urlString]};
            descAttributes = @{NSFontAttributeName : STKFont(13), NSForegroundColorAttributeName : [UIColor HATextColor], NSLinkAttributeName: [NSURL URLWithString:meta.urlString]};
        } else {
            titleAttributes = @{NSFontAttributeName : STKBoldFont(14), NSForegroundColorAttributeName : [UIColor HATextColor]};
            descAttributes = @{NSFontAttributeName : STKFont(13), NSForegroundColorAttributeName : [UIColor HATextColor]};
        }
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"" attributes:titleAttributes];
        NSAttributedString *description = [[NSAttributedString alloc] initWithString:@"" attributes:descAttributes];
        if (meta.title) {
            NSString *titleBreak = [NSString stringWithFormat:@"\n\n%@", meta.title];
            title = [[NSAttributedString alloc] initWithString:titleBreak attributes:titleAttributes];
            [s appendAttributedString:title];
        } if (meta.linkDescription) {
            NSString *descriptionBreak = [[NSString stringWithFormat:@"\n%@", meta.linkDescription] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
            description = [[NSAttributedString alloc] initWithString:descriptionBreak attributes:descAttributes];
            [s appendAttributedString:description];
        }
    }
    self.storedAttributedText = [s copy];
    return self.storedAttributedText;
}

- (CGRect)boundingBoxForMessageWithWidth:(CGFloat)width
{
    NSAttributedString *string = [self attributedMessageText];
    return [string boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
}

- (void)setText:(NSString *)text
{
    [self willChangeValueForKey:@"text"];
    [self setPrimitiveValue:text forKey:@"text"];
    [self didChangeValueForKey:@"text"];
    self.storedAttributedText = nil;
}

@end
