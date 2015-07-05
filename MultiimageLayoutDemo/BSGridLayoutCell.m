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
        self.backgroundColor = [UIColor redColor];
//        CGRect colorFrame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
//        printf("contentView.frame.size:%f, %f", self.contentView.frame.size.width, self.contentView.frame.size.height);
//        UIView *colorView = [[UIView alloc] initWithFrame:colorFrame];
//        colorView.backgroundColor = [UIColor redColor];
//        [self.contentView addSubview:colorView];
    }
    return self;
}

@end
