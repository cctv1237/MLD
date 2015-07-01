//
//  BSGridLayout.m
//  MultiimageLayoutDemo
//
//  Created by LF on 15/6/29.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "BSGridLayout.h"
#import "BSGridPosition.h"
#import "BSGridBlock.h"
#import "BSGridRect.h"
#import "BSGridCalculator.h"
#import "BSGridCoordTranslator.h"

@interface BSGridLayout ()

@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, assign) CGFloat contentSizeHeight;
@property (nonatomic, assign) CGSize blockPixels;

@property (nonatomic, strong) BSGridCalculator *gridCalculator;
@property (nonatomic, strong) BSGridCoordTranslator *gridCoordTranslator;

@property (nonatomic, strong) NSMutableDictionary *itemAttributes;
@property (nonatomic, strong) NSMutableArray *gridBlocks;

// previous layout cache.  this is to prevent choppiness
// when we scroll to the bottom of the screen - uicollectionview
// will repeatedly call layoutattributesforelementinrect on
// each scroll event.  pow!
@property (nonatomic, strong) NSArray* previousLayoutAttributes;
@property (nonatomic, assign) CGRect previousLayoutRect;

@property (nonatomic) BOOL prelayoutEverything;

@property(nonatomic) NSMutableDictionary* indexPathByPosition;

// remember the last indexpath placed, as to not
// relayout the same indexpaths while scrolling
@property(nonatomic) NSIndexPath* lastIndexPathPlaced;

@end

@implementation BSGridLayout

- (void)setInitialDefaults {
    _direction = UICollectionViewScrollDirectionVertical;
    _itemSpacing = MULTIIMAGE_ITEM_SPACING;
    _margin = MULTIIMAGE_MARGIN;
    
    _gridCalculator = [[BSGridCalculator alloc] init];
    _gridCoordTranslator = [[BSGridCoordTranslator alloc] initWithItemSpacing:self.itemSpacing
                                                                       margin:self.margin
                                                                   background:self.collectionView];
    _blockPixels = CGSizeMake(_gridCoordTranslator.gridSideLength, _gridCoordTranslator.gridSideLength);
    _indexPathByPosition = [NSMutableDictionary dictionary];
    
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
    
    for (NSInteger i = 0; i < self.itemCount; i ++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        BSGridRect *gridRect = [self.gridCalculator.gridRects objectAtIndex:indexPath.item];
        [self setPosition:CGPointMake((CGFloat)gridRect.gridPosition.colStart, (CGFloat)gridRect.gridPosition.rowStart)
             forIndexPath:indexPath];
        CGRect frame = [self.gridCoordTranslator itemFrameByGridRect:[self.gridCalculator.gridRects objectAtIndex:indexPath.item]];
        CGFloat contentSizeHeight = frame.origin.y + frame.size.height;
        if (contentSizeHeight > self.contentSizeHeight) {
            self.contentSizeHeight = contentSizeHeight;
        }
        
    }

    
}

- (CGSize)collectionViewContentSize {
    
    CGFloat contentWidth = self.collectionView.frame.size.width;
    CGFloat contentHeight = (self.contentSizeHeight > self.collectionView.frame.size.height?  self.contentSizeHeight + _margin : self.collectionView.frame.size.height);
    
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
//        CGFloat contentSizeHeight = attrs.frame.origin.y + attrs.frame.size.height;
//        if (contentSizeHeight > self.contentSizeHeight) {
//            self.contentSizeHeight = contentSizeHeight;
//        }
        
    }
    
    return attrs;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    // 如果即将显示的内容区域(其大小略等于屏幕大小)在collection view整个内容区域中的位置与稍前已经显示的区域相同，
    // 就直接返回已缓存的位置属性集合
    if(CGRectEqualToRect(rect, self.previousLayoutRect)) {
        return self.previousLayoutAttributes;
    }
    
    self.previousLayoutRect = rect;
    
    
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    
    int unrestrictedDimensionStart = isVert? rect.origin.y / self.blockPixels.height : rect.origin.x / self.blockPixels.width;
    int unrestrictedDimensionLength = (isVert? rect.size.height / self.blockPixels.height : rect.size.width / self.blockPixels.width) + 1;
    int unrestrictedDimensionEnd = unrestrictedDimensionStart + unrestrictedDimensionLength;
    
//    [self fillInBlocksToUnrestrictedRow:self.prelayoutEverything? INT_MAX : unrestrictedDimensionEnd];
    
    // find the indexPaths between those rows
    NSMutableSet* attributes = [NSMutableSet set];
    [self traverseTilesBetweenUnrestrictedDimension:unrestrictedDimensionStart and:unrestrictedDimensionEnd iterator:^(CGPoint point) {
            NSIndexPath* indexPath = [self indexPathForPosition:point];
        
            if(indexPath) {
                [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
            }
        
            return YES;
        }
    ];
    
    return (self.previousLayoutAttributes = [attributes allObjects]);
    
//    NSMutableArray *layoutAttributes = [NSMutableArray array];
//    
//    for (NSInteger i = 0; i < self.itemCount; i ++) {
//        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
//        if (indexPath) [layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
//    }
//    
//    return self.previousLayoutAttributes = layoutAttributes;
}

- (void)invalidateLayout {
    [super invalidateLayout];
}

#pragma mark private methods

- (BOOL) traverseTilesBetweenUnrestrictedDimension:(int)begin and:(int)end iterator:(BOOL(^)(CGPoint))block {
    BOOL isVert = (self.direction == UICollectionViewScrollDirectionVertical);
    
    // the double ;; is deliberate, the unrestricted dimension should iterate indefinitely
    for(int unrestrictedDimension = begin; unrestrictedDimension < end; unrestrictedDimension++) {
        for(int restrictedDimension = 0; restrictedDimension < [self restrictedDimensionBlockSize]; restrictedDimension++) {
            CGPoint point = CGPointMake(
                                        (isVert? restrictedDimension : unrestrictedDimension),
                                        (isVert? unrestrictedDimension : restrictedDimension)
                                    );
            
            if(!block(point)) { return NO; }
        }
    }
    
    return YES;
}

- (int) restrictedDimensionBlockSize {
    BOOL isVert = self.direction == UICollectionViewScrollDirectionVertical;
    
    CGRect contentRect = UIEdgeInsetsInsetRect(self.collectionView.frame, self.collectionView.contentInset);
    int size = isVert? CGRectGetWidth(contentRect) / self.blockPixels.width : CGRectGetHeight(contentRect) / self.blockPixels.height;
    
    if(size == 0) {
        static BOOL didShowMessage;
        if(!didShowMessage) {
            NSLog(@"%@: cannot fit block of size: %@ in content rect %@!  Defaulting to 1", [self class], NSStringFromCGSize(self.blockPixels), NSStringFromCGRect(contentRect));
            didShowMessage = YES;
        }
        return 1;
    }
    
    return size;
}

- (NSIndexPath*)indexPathForPosition:(CGPoint)point {
    BOOL isVert = (self.direction == UICollectionViewScrollDirectionVertical);
    
    // to avoid creating unbounded nsmutabledictionaries we should
    // have the innerdict be the unrestricted dimension
    
    NSNumber* unrestrictedPoint = @(isVert? point.y : point.x);
    NSNumber* restrictedPoint = @(isVert? point.x : point.y);
    
    return self.indexPathByPosition[restrictedPoint][unrestrictedPoint];
}

- (void) setPosition:(CGPoint)point forIndexPath:(NSIndexPath*)indexPath {
    BOOL isVert = (self.direction == UICollectionViewScrollDirectionVertical);
    
    // to avoid creating unbounded nsmutabledictionaries we should
    // have the innerdict be the unrestricted dimension
    
    NSNumber* unrestrictedPoint = @(isVert? point.y : point.x);
    NSNumber* restrictedPoint = @(isVert? point.x : point.y);
    
    NSMutableDictionary* innerDict = self.indexPathByPosition[restrictedPoint];
    if (!innerDict)
        self.indexPathByPosition[restrictedPoint] = [NSMutableDictionary dictionary];
    
    self.indexPathByPosition[restrictedPoint][unrestrictedPoint] = indexPath;
}


@end
