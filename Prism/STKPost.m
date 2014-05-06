//
//  STKPost.m
//  Prism
//
//  Created by Joe Conway on 11/20/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import "STKPost.h"
#import "STKUser.h"
#import "STKUserStore.h"
#import "STKPostComment.h"



NSString * const STKPostLocationLatitudeKey = @"location_latitude";
NSString * const STKPostLocationLongitudeKey = @"location_longitude";
NSString * const STKPostLocationNameKey = @"location_name";

NSString * const STKPostVisibilityKey = @"scope";
NSString * const STKPostHashTagsKey = @"hash_tags";

NSString * const STKPostDateCreatedKey = @"create_date";
NSString * const STKPostURLKey = @"file_path";
NSString * const STKPostTextKey = @"text";
NSString * const STKPostTypeKey = @"category";
NSString * const STKPostOriginIDKey = @"origin_post_id";

NSString * const STKPostVisibilityPublic = @"public";
NSString * const STKPostVisibilityPrivate = @"private";
NSString * const STKPostVisibilityTrust = @"trust";

NSString * const STKPostTypeAspiration = @"aspiration";
NSString * const STKPostTypeInspiration = @"inspiration";
NSString * const STKPostTypeExperience = @"experience";
NSString * const STKPostTypeAchievement = @"achievement";
NSString * const STKPostTypePassion = @"passion";
NSString * const STKPostTypePersonal = @"personal";
NSString * const STKPostTypeAccolade = @"accolade";

NSString * const STKPostStatusDeleted = @"deleted";

@interface STKPost ()
@property (nonatomic) double locationLatitude;
@property (nonatomic) double locationLongitude;
@end

@implementation STKPost
@dynamic coordinate;
@dynamic hashTags, imageURLString, uniqueID, datePosted, locationLatitude, locationLongitude, locationName,
visibility, status, repost, text, comments, commentCount, creator, originalPost, likes, likeCount,
type, fInverseFeed, activities, derivativePosts, tags;
@dynamic fInverseProfile;


+ (NSDictionary *)remoteToLocalKeyMap
{
    return @{
             @"_id" : @"uniqueID",
             STKPostTypeKey : @"type",
             
             STKPostURLKey : @"imageURLString",
             STKPostLocationNameKey : @"locationName",
             STKPostLocationLatitudeKey : @"locationLatitude",
             STKPostLocationLongitudeKey : @"locationLongitude",
             STKPostVisibilityKey : @"visibility",
             @"status" : @"status",
             @"is_repost" : @"repost",
             STKPostTextKey : @"text",
             
             @"likes_count" : @"likeCount",
             @"comments_count" : @"commentCount",
             @"hash_tags" : [STKBind bindMapForKey:@"hashTags" matchMap:@{@"title" : @"title"}],
             @"tags" : [STKBind bindMapForKey:@"tags" matchMap:@{@"uniqueID" : @"_id"}],
             
             @"creator" : [STKBind bindMapForKey:@"creator" matchMap:@{@"uniqueID" : @"_id"}],
             @"likes" : [STKBind bindMapForKey:@"likes" matchMap:@{@"uniqueID" : @"_id"}],
             @"comments" : [STKBind bindMapForKey:@"comments" matchMap:@{@"uniqueID" : @"_id"}],
             
             @"origin_post_id" : [STKBind bindMapForKey:@"originalPost" matchMap:@{@"uniqueID" : @"_id"}],
             
             STKPostDateCreatedKey : [STKBind bindMapForKey:@"datePosted" transform:STKBindTransformDateTimestamp]
    };
}

- (NSError *)readFromJSONObject:(id)jsonObject
{
    if([jsonObject isKindOfClass:[NSString class]]) {
        [self setUniqueID:jsonObject];
        return nil;
    }
    
    [self bindFromDictionary:jsonObject keyMap:[[self class] remoteToLocalKeyMap]];
    
    return nil;
}

- (NSString *)renderText
{
    // ensure text property is set
    if([[self text] length]> 0){
        
        //check that tags array is avaialbe, if not just return regular text
        if(![[self tags] count] >0){
            return [self text];
        }else{
            NSMutableString *renderedText = [[self text] mutableCopy];
            for(STKUser *user in [[self tags] allObjects]) {
                NSString *replaceToken = [NSString stringWithFormat:@"@%@", [user uniqueID]];
                NSString *replaceString = [NSString stringWithFormat:@"@%@", [user name]];
                [renderedText replaceOccurrencesOfString:replaceToken withString:replaceString options:0 range:NSMakeRange(0, [renderedText length])];
            }
            
            return renderedText;
        }
    }
    
    return [self text];
}

- (BOOL)isPostLikedByUser:(STKUser *)u
{
    return [[self likes] member:u] != nil;
}


+ (UIImage *)imageForTextPost:(NSString *)text
{
    NSMutableDictionary *found = [NSMutableDictionary dictionary];
    NSRegularExpression *tagFinder = [[NSRegularExpression alloc] initWithPattern:@"@([A-Za-z0-9]*)" options:0 error:nil];
    [tagFinder enumerateMatchesInString:text options:0 range:NSMakeRange(0, [text length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if([result range].location != NSNotFound) {
            NSRange idRange = [result rangeAtIndex:1];
            if(idRange.location != NSNotFound) {
                NSString *idNum = [text substringWithRange:idRange];
                STKUser *u = [[STKUserStore store] userForID:idNum];
                if(u) {
                    [found setObject:u forKey:idNum];
                }
            }
        }
    }];
    
    NSMutableString *mStr = [[NSMutableString alloc] initWithString:text];
    for(NSString *idNum in found) {
        [mStr replaceOccurrencesOfString:idNum withString:[[found objectForKey:idNum] name] options:0 range:NSMakeRange(0, [mStr length])];
    }
    text = [mStr copy];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(640, 640), YES, 1);
    
    [[UIImage imageNamed:@"prismcard"] drawInRect:CGRectMake(0, 0, 640, 640)];
    
    CGRect textRect = CGRectMake(48, (640 - 416) / 2.0, 640 - 48 * 2, 416);
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    
    int fontSize = 60;
    UIFont *f = STKFont(fontSize);
    
    CGRect sizeRect = textRect;
    int iterations = 16;
    
    for(int i = 0; i < iterations; i++) {
        CGRect r = [text boundingRectWithSize:CGSizeMake(textRect.size.width - 10, 10000)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName : f, NSParagraphStyleAttributeName : style} context:nil];
        
        // Does it fit?
        if(r.size.width < textRect.size.width && r.size.height < textRect.size.height) {
            sizeRect = r;
            break;
        }
        
        fontSize -= 2;
        f = STKFont(fontSize);
    }
    
    float w = ceilf(sizeRect.size.width);
    float h = ceilf(sizeRect.size.height);
    
    CGRect centeredRect = CGRectMake(0, 0, w, h);
    centeredRect.origin.x = (640 - w) / 2.0;
    centeredRect.origin.y = (640 - h) / 2.0;
    
    [text drawInRect:centeredRect withAttributes:@{NSFontAttributeName : f, NSForegroundColorAttributeName : STKTextColor, NSParagraphStyleAttributeName : style}];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self setLocationLatitude:coordinate.latitude];
    [self setLocationLongitude:coordinate.longitude];
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self locationLatitude],
                                      [self locationLongitude]);
}

- (UIImage *)typeImage
{
    return [[self class] imageForType:[self type]];
}

+ (UIImage *)imageForType:(NSString *)t
{
    NSDictionary *m = @{STKPostTypeAchievement : @"category_achievements_sm",
                        STKPostTypeAspiration : @"category_aspirations_sm",
                        STKPostTypeExperience : @"category_experiences_sm",
                        STKPostTypeInspiration : @"category_inspiration_sm",
                        STKPostTypePassion : @"category_passions_sm"};
    
    NSString *imageName = m[t];
    
    if(imageName) {
        return [UIImage imageNamed:imageName];
    }
    
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"0x%x %@ %@", (int)self, [self uniqueID], [self renderText]];
}

@end
