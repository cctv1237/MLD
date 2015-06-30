//
//  BSGridCalculator.h
//  LogicGridLayout
//
//  Created by LF on 15/6/25.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSGridCalculator : NSObject

@property (nonatomic, strong) NSMutableArray *gridBlocks;
@property (nonatomic, strong) NSMutableArray *gridRects;

- (void)doGridCalculate;

@end
