//
//  STKFilterCell.h
//  Prism
//
//  Created by Joe Conway on 2/24/14.
//  Copyright (c) 2014 Higher Altitude. All rights reserved.
//

#import "STKTableViewCell.h"

@interface STKFilterCell : STKTableViewCell

- (IBAction)showSinglePanePosts:(id)sender;
- (IBAction)showGridPosts:(id)sender;
- (IBAction)toggleFilterByUserPost:(id)sender;
- (IBAction)toggleFilterbyLocation:(id)sender;

@end
