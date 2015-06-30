//
//  BSFlowLayoutView.m
//  FlowLayout
//
//  Created by LF on 15/6/5.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "BSGridLayoutCollectionView.h"
#import "BSGridLayoutCell.h"
#import "BSGridLayout.h"

@interface BSGridLayoutCollectionView ()

@end

@implementation BSGridLayoutCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    
    self.gridLayout = [[BSGridLayout alloc] init];
    
    if (self = [super initWithFrame:frame collectionViewLayout:self.gridLayout]) {
        [self registerClass:[BSGridLayoutCell class] forCellWithReuseIdentifier:ReuseIdentifier];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end
