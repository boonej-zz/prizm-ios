//
//  STKBackdropView.h
//  Prism
//
//  Created by Joe Conway on 12/3/13.
//  Copyright (c) 2013 Higher Altitude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKBackdropView : UIView

- (id)initWithFrame:(CGRect)frame relativeTo:(UIView *)blurView;

@property (nonatomic, strong) UIColor *blurBackgroundColor;
@property (nonatomic, strong) UIImage *blurBackgroundImage;

- (void)invalidateCache;

#pragma mark UITableView
- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;
- (id)dequeueCellForReuseIdentifier:(NSString *)identifier;
- (BOOL)shouldBlurImageForIndexPath:(NSIndexPath *)ip;
- (void)addBlurredImageFromCell:(UITableViewCell *)cell
                        forRect:(CGRect)rect
                      indexPath:(NSIndexPath *)ip;


@end
