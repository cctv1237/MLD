//
//  BSFlowLayoutViewCell.m
//  FlowLayout
//
//  Created by LF on 15/6/5.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "BSGridLayoutCell.h"

@implementation BSGridLayoutCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

@end
