//
//  STKMarkupUtilities.m
//  Prism
//
//  Created by Joe Conway on 5/14/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKMarkupUtilities.h"
#import "STKUser.h"
#import "STKUserStore.h"
#import "STKPost.h"

@implementation STKMarkupUtilities


+ (UIImage *)imageForText:(NSString *)text
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

+ (NSAttributedString *)renderedTextForText:(NSString *)text attributes:(NSDictionary *)attributes
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text
                                                                            attributes:attributes];
    NSRegularExpression *hashTagExpression = [[NSRegularExpression alloc] initWithPattern:@"#(\\S*)" options:0 error:nil];
    
    NSArray *matches = [hashTagExpression matchesInString:[str string] options:0 range:NSMakeRange(0, [[str string] length])];
    for(int i = [matches count] - 1; i >= 0; i--) {
        NSTextCheckingResult *result = [matches objectAtIndex:i];
        if([result numberOfRanges] == 2) {
            NSRange fullRange = [result range];
            NSRange nameRange = [result rangeAtIndex:1];
            
            NSString *hashTagName = [[str string] substringWithRange:nameRange];
            [str addAttribute:NSLinkAttributeName value:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", STKPostHashTagURLScheme, hashTagName]] range:fullRange];
        }
    }
    
    NSRegularExpression *userTagExpression = [[NSRegularExpression alloc] initWithPattern:@"@(\\S*)" options:0 error:nil];
    matches = [userTagExpression matchesInString:[str string] options:0 range:NSMakeRange(0, [[str string] length])];
    for(int i = [matches count] - 1; i >= 0; i--) {
        NSTextCheckingResult *result = [matches objectAtIndex:i];
        if([result numberOfRanges] == 2) {
            NSRange fullRange = [result range];
            NSRange nameRange = [result rangeAtIndex:1];
            
            NSString *userID = [[str string] substringWithRange:nameRange];
            STKUser *u = [[STKUserStore store] userForID:userID];
            
            NSAttributedString *userTag = [[self class] userTagForUser:u attributes:attributes];
            
            [str replaceCharactersInRange:fullRange withAttributedString:userTag];
        }
    }
    
    return str;
}

+ (NSAttributedString *)userTagForUser:(STKUser *)user attributes:(NSDictionary *)attributes
{
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    UIImage *img = [[self class] imageForUserTag:[NSString stringWithFormat:@"@%@", [user name]]
                                      attributes:attributes];
    [attach setImage:img];
    [attach setBounds:CGRectMake(0, -3, [img size].width, [img size].height)];
    NSMutableAttributedString *replacement = [[NSAttributedString attributedStringWithAttachment:attach] mutableCopy];
    [replacement addAttribute:NSLinkAttributeName value:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", STKPostUserURLScheme, [user uniqueID]]]
                        range:NSMakeRange(0, [replacement length])];
    
    return replacement;
}

+ (UIImage *)imageForUserTag:(NSString *)name attributes:(NSDictionary *)attributes
{
    NSMutableDictionary *d = [attributes mutableCopy];
    [d setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    CGSize sz = [name sizeWithAttributes:d];
    UIGraphicsBeginImageContextWithOptions(sz, NO, [[UIScreen mainScreen] scale]);
    
    [name drawInRect:CGRectMake(0, 0, sz.width, sz.height) withAttributes:d];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

@end