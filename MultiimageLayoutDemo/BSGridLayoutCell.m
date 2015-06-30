//
//  BSFlowLayoutViewCell.m
//  FlowLayout
//
//  Created by LF on 15/6/5.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "BSGridLayoutCell.h"

@implementation BSGridLayoutCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = [UIColor redColor];
        UIView *colorView = [[UIView alloc] initWithFrame:self.contentView.frame];
        colorView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:colorView];
    }
    
    return self;
}

@end
