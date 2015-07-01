//
//  BSGridLayout.m
//  MultiimageLayoutDemo
//
//  Created by LF on 15/6/29.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "BSGridLayout.h"
#import "BSGridBlock.h"
#import "BSGridCalculator.h"
#import "BSGridCoordTranslator.h"

@interface BSGridLayout ()

@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) CGFloat contentSizeHeight;

@property (nonatomic, strong) BSGridCalculator *gridCalculator;
@property (nonatomic, strong) BSGridCoordTranslator *gridCoordTranslator;

@property (nonatomic, strong) NSMutableDictionary *itemAttributes;
@property (nonatomic, strong) NSMutableArray *gridBlocks;

@property (nonatomic, strong) NSArray* previousLayoutAttributes;
@property (nonatomic, assign) CGRect previousLayoutRect;

@end

@implementation BSGridLayout

- (void)setInitialDefaults {
    _scrollDirection = UICollectionViewScrollDirectionVertical;
    _itemSpacing = MULTIIMAGE_ITEM_SPACING;
    _margin = MULTIIMAGE_MARGIN;
    
    _gridCalculator = [[BSGridCalculator alloc] init];
    _gridCoordTranslator = [[BSGridCoordTranslator alloc] initWithItemSpacing:self.itemSpacing
                                                                       margin:self.margin
                                                                   background:self.collectionView];
    _itemAttributes = [NSMutableDictionary dictionary];
    _gridBlocks = [NSMutableArray array];
    _itemCount = [self.collectionView numberOfItemsInSection:0];
    
}

- (void)prepareLayout {
    [super prepareLayout];
    [self setInitialDefaults];
    
    for (NSInteger i = 0; i < self.itemCount; i ++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [self.gridBlocks addObject:[self.delegate collectionView:self.collectionView layout:self itemAtIndexPath:indexPath]];
    }
    self.gridCalculator.gridBlocks = self.gridBlocks;
    [self.gridCalculator doGridCalculate];

    
}

- (CGSize)collectionViewContentSize {
    
    CGFloat contentWidth = self.collectionView.frame.size.width;
    CGFloat contentHeight = (self.contentSizeHeight > self.collectionView.frame.size.height?  self.contentSizeHeight :  self.collectionView.frame.size.height + _margin);
    
    return CGSizeMake(contentWidth, contentHeight);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    if ([self.itemAttributes objectForKey:indexPath]) {
        attrs = [self.itemAttributes objectForKey:indexPath];
    }
    else {
        attrs.frame = [self.gridCoordTranslator itemFrameByGridRect:[self.gridCalculator.gridRects objectAtIndex:indexPath.item]];
        [self.itemAttributes setObject:attrs forKey:indexPath];
        CGFloat contentSizeHeight = attrs.frame.origin.y + attrs.frame.size.height;
        if (contentSizeHeight > self.contentSizeHeight) {
            self.contentSizeHeight = contentSizeHeight;
        }
        
    }
    
    return attrs;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    if(CGRectEqualToRect(rect, self.previousLayoutRect)) {
        return self.previousLayoutAttributes;
    }
    self.previousLayoutRect = rect;
    
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.itemCount; i ++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        if (indexPath) [layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    
    return self.previousLayoutAttributes = layoutAttributes;
}

- (void)invalidateLayout {
    [super invalidateLayout];
}


@end
