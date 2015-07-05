//
//  BSGridCalculator.h
//  LogicGridLayout
//
//  Created by LF on 15/6/25.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class BSGridRect, BSGridBlock;

@interface BSGridLayoutLocator : NSObject

- (instancetype)initWithColCount:(NSInteger)colCount GridUnit:(CGSize)gridUnit;
- (NSMutableArray *) locateGridBlocksInAppendMode:(NSMutableArray *)gridBlocks;
- (BSGridRect *) locateOneBlockInAppendMode:(BSGridBlock *)gridBlock;
- (NSMutableArray *) locateGridBlocksFromScratch:(NSMutableArray *)gridBlocks;
- (void) printWholeLayout;

@end
