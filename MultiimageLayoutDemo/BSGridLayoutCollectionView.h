//
//  BSFlowLayoutView.h
//  FlowLayout
//
//  Created by LF on 15/6/5.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ReuseIdentifier @"multiImageCell"

@class BSGridLayout;

@interface BSGridLayoutCollectionView : UICollectionView

@property (nonatomic,strong) BSGridLayout *gridLayout;

@end
