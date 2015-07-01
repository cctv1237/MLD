//
//  BSGridLayout.h
//  MultiimageLayoutDemo
//
//  Created by LF on 15/6/29.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSGridBlock;

@protocol BSGridLayoutDelegate <UICollectionViewDelegate>

@required
- (BSGridBlock *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout itemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface BSGridLayout : UICollectionViewLayout

@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

@property (nonatomic, weak) id<BSGridLayoutDelegate> delegate;

@end
