//
//  BSGridCoordTranslator.h
//  MultiimageLayoutDemo
//
//  Created by LF on 15/6/29.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_COL_COUNT 6
#define MAX_ROW_COUNT 1000

#define MULTIIMAGE_ITEM_SPACING 10
#define MULTIIMAGE_MARGIN 20

@class BSGridRect;

@interface BSGridCoordTranslator : NSObject

- (instancetype)initWithItemSpacing:(CGFloat)itemSpacing margin:(CGFloat)margin background:(UIView *)background;

- (CGRect)itemFrameByGridRect:(BSGridRect *)gridRect;

@end
