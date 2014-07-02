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
#import "STKImageStore.h"

@implementation STKMarkupUtilities

+ (UIImage *)imageForText:(NSString *)text
{
    return [self imageForText:text withAvatarImage:nil];
}

+ (UIImage *)imageForText:(NSString *)text withAvatarImage:(UIImage *)avatarImage;
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
    
    UIImage *prismCard = [UIImage imageNamed:@"prismcard"];
    [prismCard drawInRect:CGRectMake(0, 0, 640, 640)];
    
    CGRect textRect = CGRectMake(48, (640 - 416) / 2.0, 640 - 48 * 2, 416);
    if (avatarImage) {
        textRect = CGRectMake(48, 640 - 32, 640 - 48 * 2, 64);
        

        CGContextSaveGState(UIGraphicsGetCurrentContext());
        CGPoint avatarOrigin = CGPointZero;
        avatarOrigin.y = 96;
        avatarOrigin.x = (640 - avatarImage.size.width)/2;

        CGRect avatarRect = CGRectMake(avatarOrigin.x, avatarOrigin.y, avatarImage.size.width, avatarImage.size.height);
        UIBezierPath *bpInner = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(avatarRect, 2, 2)];
        
        [bpInner addClip];
        
        [avatarImage drawAtPoint:avatarOrigin];
        
        CGContextRestoreGState(UIGraphicsGetCurrentContext());
        
        UIBezierPath *bpInnerStroke = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(avatarRect, 2, 2)];
        [STKTextColor set];
        [bpInnerStroke setFlatness:1];
        [bpInnerStroke setLineJoinStyle:kCGLineJoinRound];
        [bpInnerStroke setLineWidth:3];
        [bpInnerStroke stroke];
    }
    
    
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
    
    if (avatarImage) {
        centeredRect.origin.y += 96;
    }
    
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
            NSString *urlString = [NSString stringWithFormat:@"%@://%@", STKPostHashTagURLScheme, hashTagName];
            NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            if(url){
                [str addAttribute:NSLinkAttributeName value:url range:fullRange];
            }
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
            
            if(u){
                NSAttributedString *userTag = [[self class] userTagForUser:u attributes:attributes];
                [str replaceCharactersInRange:fullRange withAttributedString:userTag];
            }
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

+ (void)imageForInviteCard:(STKUser *)user withCompletion:(void (^)(UIImage *img))block
{
    [[STKImageStore store] fetchImageForURLString:[user profilePhotoPath] completion:^(UIImage *img) {
        if (img == nil) {
            img = [UIImage imageNamed:@"trust_user_missing_144"];
        }
        // created avatar image at 256x256px
        int dim = STKUserProfilePhotoSize.height*2;
        CGSize size = CGSizeMake(dim,dim);
        
        UIGraphicsBeginImageContextWithOptions(size, YES, 1);
        [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
        
        UIImage *avatarImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
                
        block([self imageForText:[user name] withAvatarImage:avatarImage]);
    }];
}

@end
