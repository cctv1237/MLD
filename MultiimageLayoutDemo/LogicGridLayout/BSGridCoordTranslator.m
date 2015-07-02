//
//  BSGridCoordTranslator.m
//  MultiimageLayoutDemo
//
//  Created by LF on 15/6/29.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "BSGridCoordTranslator.h"
#import "BSGridRect.h"
#import "BSGridPosition.h"
#import "BSGridBlock.h"

@interface BSGridCoordTranslator ()

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation BSGridCoordTranslator {
//    CGFloat _itemSpacing;
//    CGFloat _margin;
    CGFloat _backgroundWidth;
    NSInteger _gridCountInUnscrollDirection;
    CGFloat _gridAbsSideLength;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    if (self = [super init]) {
//        _itemSpacing = itemSpacing;
//        _margin = margin;
//        _backgroundWidth = background.frame.size.width;
        _collectionView = collectionView;
        _gridCountInUnscrollDirection = MAX_COL_COUNT;
        _gridAbsSideLength = [self calculateGridAbsSideLength];
    }
    return self;

}

- (CGFloat)gridSideLength {
    return _gridAbsSideLength;
}

- (CGRect)itemFrameByGridRect:(BSGridRect *)gridRect {
    
    CGPoint origin = [self translateToAbsPosition:gridRect.gridPosition];
    CGSize size = [self translateToAbsSize:gridRect.gridBlock];
    
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}

#pragma mark - Private

- (CGFloat)calculateGridAbsSideLength {
    return (_collectionView.frame.size.width
            - (_collectionView.contentInset.left + _collectionView.contentInset.right)) / _gridCountInUnscrollDirection;
}

- (CGFloat)translateToAbsLengthByGridLength:(NSInteger)Length {
    return Length * _gridAbsSideLength;
}

- (CGSize)translateToAbsSize:(BSGridBlock *)gridBlock {
    
    CGFloat widthOfAbsSize= [self translateToAbsLengthByGridLength:gridBlock.colSpan];
    CGFloat heightOfAbsSize= [self translateToAbsLengthByGridLength:gridBlock.rowSpan];
    
    return CGSizeMake(widthOfAbsSize, heightOfAbsSize);
}

- (CGFloat)translateToAbsCoordByGridCoord:(NSInteger)coord {
    return coord * _gridAbsSideLength;
}

- (CGPoint)translateToAbsPosition:(BSGridPosition *)gridPosition {
    
    CGFloat xOfAbsPosition= [self translateToAbsCoordByGridCoord:gridPosition.colStart];
    CGFloat yOfAbsPosition= [self translateToAbsCoordByGridCoord:gridPosition.rowStart];
    
    return CGPointMake(xOfAbsPosition, yOfAbsPosition);
}


@end
