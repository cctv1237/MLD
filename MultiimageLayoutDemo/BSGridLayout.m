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
#import "BSGridLayoutLocator.h"

@interface BSGridLayout ()

@property (nonatomic, assign) NSInteger numOfGridInRestrictedDimension;

@property (nonatomic, assign) CGSize gridUnit;
@property (nonatomic, assign) NSInteger furthestRow;

@property (nonatomic, strong) BSGridLayoutLocator *locator;

//@property (nonatomic, strong) NSMutableDictionary *itemAttributes;

// previous layout cache.  this is to prevent choppiness
// when we scroll to the bottom of the screen - uicollectionview
// will repeatedly call layoutattributesforelementinrect on
// each scroll event.  pow!
@property (nonatomic, strong) NSArray* previousLayoutAttributes;
@property (nonatomic, assign) CGRect previousLayoutRect;

@property (nonatomic, assign) BOOL prelayoutEverything;

@property(nonatomic, strong) NSMutableDictionary *indexPathByPosition;
@property(nonatomic, strong) NSMutableDictionary *gridRectByIndexPath;

// remember the last indexpath placed, as to not
// relayout the same indexpaths while scrolling
@property(nonatomic, strong) NSIndexPath* lastIndexPathPlaced;

// arrays to keep track of insert, delete index paths
@property (nonatomic, strong) NSMutableArray *deleteIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertIndexPaths;

@end

@implementation BSGridLayout

- (instancetype)init {
    if (self = [super init]) {
        _direction = UICollectionViewScrollDirectionVertical;
        _indexPathByPosition = [NSMutableDictionary dictionary];
        _gridRectByIndexPath = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setInitialDefaults {
    _numOfGridInRestrictedDimension = 6;
    [self initGridUnit];
    if (!_locator) {
        _locator = [[BSGridLayoutLocator alloc] initWithColCount:_numOfGridInRestrictedDimension GridUnit:_gridUnit];
    }
    
}

- (void)initGridUnit {
    CGFloat sideLength = (self.collectionView.frame.size.width
                          - (self.collectionView.contentInset.left + self.collectionView.contentInset.right)) / _numOfGridInRestrictedDimension;
    _gridUnit = CGSizeMake(sideLength, sideLength);
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self setInitialDefaults];
    
    if (!self.delegate) return;
    
    BOOL isVert = [self isVertical];
    
    CGRect scrollFrame = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y,
                                    self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    
    int unrestrictedRow = 0;
    if (isVert)
        unrestrictedRow = (CGRectGetMaxY(scrollFrame) / _gridUnit.height) + 1;
    else
        unrestrictedRow = (CGRectGetMaxX(scrollFrame) / _gridUnit.width) + 1;
    
    [self fillInBlocksToUnrestrictedRow:unrestrictedRow];
    printf("----------------prepareLayout\n");
}

- (void)invalidateLayout {
    [super invalidateLayout];
    self.previousLayoutAttributes = nil;
    self.previousLayoutRect = CGRectZero;
    self.lastIndexPathPlaced = nil;
}

- (CGSize)collectionViewContentSize {
    CGRect contentRect = UIEdgeInsetsInsetRect(self.collectionView.frame, self.collectionView.contentInset);
    if ([self isVertical]) {
        CGFloat contentHeight = self.furthestRow * self.gridUnit.height;
        if (contentHeight < self.collectionView.frame.size.height) {
            contentHeight = self.collectionView.frame.size.height;
        }
        return CGSizeMake(CGRectGetWidth(contentRect), contentHeight);
    } else {
        // 待实现 水平方向滚动的逻辑
        return CGSizeMake(self.furthestRow * self.gridUnit.width, CGRectGetHeight(contentRect));
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    // 如果即将显示的内容区域(其大小略等于屏幕大小)在collection view整个内容区域中的位置与稍前已经显示的区域相同，
    // 就直接返回已缓存的位置属性集合
    if(CGRectEqualToRect(rect, self.previousLayoutRect)) {
        return self.previousLayoutAttributes;
    }
    
    self.previousLayoutRect = rect;
    
    BOOL isVert = [self isVertical];
    
    int unrestrictedDimensionStart = isVert? rect.origin.y / self.gridUnit.height : rect.origin.x / self.gridUnit.width;
    int unrestrictedDimensionLength = (isVert? rect.size.height / self.gridUnit.height : rect.size.width / self.gridUnit.width) + 1;
    int unrestrictedDimensionEnd = unrestrictedDimensionStart + unrestrictedDimensionLength;
    
    [self fillInBlocksToUnrestrictedRow:unrestrictedDimensionEnd];
    
    // find the indexPaths between those rows
    NSMutableSet* attributes = [NSMutableSet set];
    [self traverseTilesBetweenUnrestrictedDimension:unrestrictedDimensionStart and:unrestrictedDimensionEnd iterator:^(CGPoint point) {
            NSIndexPath* indexPath = [self indexPathForPosition:point];
            if(indexPath) {
                [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
            } else {
            }
        
            return YES;
        }
    ];
    
    printf(">>>>>>>> attributes count:%d \n", (int) attributes.count);
    
    return (self.previousLayoutAttributes = [attributes allObjects]);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets = [[self delegate] collectionView:[self collectionView] layout:self insetsForItemAtIndexPath:indexPath];
    
    BSGridRect *gridRect;
    if ([_gridRectByIndexPath objectForKey:indexPath]) {
        gridRect = [_gridRectByIndexPath objectForKey:indexPath];
    } else {
        BSGridBlock *gridBlock = [self.delegate collectionView:self.collectionView layout:self itemAtIndexPath:indexPath];
        gridRect = [self.locator locateOneBlockInAppendMode:gridBlock];
    }
    
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attrs.frame = UIEdgeInsetsInsetRect(gridRect.absFrame, insets);
    
    return attrs;
}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForAddedItemAtIndexPath:(NSIndexPath *)indexPath {
//    UIEdgeInsets insets = UIEdgeInsetsZero;
//    insets = [[self delegate] collectionView:[self collectionView] layout:self insetsForItemAtIndexPath:indexPath];
//    
//    BSGridRect *gridRect;
//    BSGridBlock *gridBlock = [self.delegate collectionView:self.collectionView layout:self itemAtIndexPath:indexPath];
//    gridRect = [self.locator shouldAddOneBlock:gridBlock];
//    
//    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
//    attrs.frame = UIEdgeInsetsInsetRect(gridRect.absFrame, insets);
//    
//    return attrs;
//}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.deleteIndexPaths = [NSMutableArray array];
    self.insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems)
    {
        if (update.updateAction == UICollectionUpdateActionDelete)
        {
            [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        }
        else if (update.updateAction == UICollectionUpdateActionInsert)
        {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
    
    self.deleteIndexPaths = nil;
    self.insertIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([self.insertIndexPaths containsObject:itemIndexPath])
    {
        if (!attributes)
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if ([self.deleteIndexPaths containsObject:itemIndexPath])
    {
        if (!attributes)
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
        // Configure attributes ...
    }
    
    return attributes;
}

- (void)addBlockatIndexPath:(NSIndexPath *)indexPath{
    
    BSGridBlock *gridBlock = [self.delegate collectionView:self.collectionView layout:self itemAtIndexPath:indexPath];
    BSGridRect *gridRect = [_locator locateOneBlockInAppendMode:gridBlock];
    
    [self markGridRectAsUsed:gridRect ByItemAtIndexPath:indexPath];
//    _gridRectByIndexPath[indexPath] = gridRect;
    [self.gridRectByIndexPath setObject:gridRect forKey:indexPath];
    
    self.lastIndexPathPlaced = indexPath;
    [self setFurthestRowIfGivenRowEndGreater:gridRect.rowEnd];

}


#pragma mark private methods

- (BOOL) traverseTilesBetweenUnrestrictedDimension:(int)begin and:(int)end iterator:(BOOL(^)(CGPoint))block {
    BOOL isVert = (self.direction == UICollectionViewScrollDirectionVertical);
    
    // the double ;; is deliberate, the unrestricted dimension should iterate indefinitely
    for(int unrestrictedDimension = begin; unrestrictedDimension < end; unrestrictedDimension++) {
        for(int restrictedDimension = 0; restrictedDimension < self.numOfGridInRestrictedDimension; restrictedDimension++) {
            CGPoint point = CGPointMake(
                                        (isVert? restrictedDimension : unrestrictedDimension),
                                        (isVert? unrestrictedDimension : restrictedDimension)
                                    );
            
            if(!block(point)) { return NO; }
        }
    }
    
    return YES;
}

- (NSIndexPath*)indexPathForPosition:(CGPoint)point {
    BOOL isVert = (self.direction == UICollectionViewScrollDirectionVertical);
    
    // to avoid creating unbounded nsmutabledictionaries we should
    // have the innerdict be the unrestricted dimension
    
    NSNumber* unrestrictedPoint = @(isVert? point.y : point.x);
    NSNumber* restrictedPoint = @(isVert? point.x : point.y);
    
    return self.indexPathByPosition[restrictedPoint][unrestrictedPoint];
}

- (void)setPosition:(CGPoint)point forIndexPath:(NSIndexPath*)indexPath {
    BOOL isVert = (self.direction == UICollectionViewScrollDirectionVertical);
    
    // to avoid creating unbounded nsmutabledictionaries we should
    // have the innerdict be the unrestricted dimension
    
    NSNumber* unrestrictedPoint = @(isVert? point.y : point.x);
    NSNumber* restrictedPoint = @(isVert? point.x : point.y);
    
    NSMutableDictionary* innerDict = self.indexPathByPosition[restrictedPoint];
    if (!innerDict)
        self.indexPathByPosition[restrictedPoint] = [NSMutableDictionary dictionary];
    
    self.indexPathByPosition[restrictedPoint][unrestrictedPoint] = indexPath;
    
    printf("indexPath(%ld, %ld, %ld) -> pos(%d, %d) \n",
           (long)indexPath.section, indexPath.row, indexPath.item,
           [restrictedPoint intValue], [unrestrictedPoint intValue]);
}

#pragma mark private methods

- (BOOL) isVertical {
    return (self.direction == UICollectionViewScrollDirectionVertical);
}

- (void) fillInBlocksToUnrestrictedRow:(int)endRow {
    
    BOOL vert = [self isVertical];
    
    // we'll have our data structure as if we're planning
    // a vertical layout, then when we assign positions to
    // the items we'll invert the axis
    
    NSInteger numSections = [self.collectionView numberOfSections];
    for (NSInteger section=self.lastIndexPathPlaced.section; section<numSections; section++) {
        NSInteger numRows = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger row = (!self.lastIndexPathPlaced ? 0 : self.lastIndexPathPlaced.row + 1); row < numRows; row++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            BSGridRect* gridRect = [self.gridRectByIndexPath objectForKey:indexPath];
//            _gridRectByIndexPath[indexPath];
            
            if (gridRect) {
                printf("indexPath(%ld, %ld, %ld) -> gridRect{pos:(%d, %d), size:(%d, %d)} \n",
                       (long)indexPath.section, indexPath.row, indexPath.item,
                       (int) [gridRect colStart], (int) [gridRect rowStart],
                       (int) [gridRect colSpan], (int) [gridRect rowSpan]);

                continue;
            } else {
                [self addBlockatIndexPath:indexPath];
                
                
                // only jump out if we've already filled up every space up till the resticted row
                // 水平方向的逻辑对不对先不用考虑
                if((vert? self.furthestRow : [gridRect colStart]) >= endRow) {
                    return;
                }
            }
        }
        
        // for debug
        [_locator printWholeLayout];
    }
}

- (void) setFurthestRowIfGivenRowEndGreater:(NSInteger)aRowEnd {
    if (aRowEnd > self.furthestRow) {
        self.furthestRow = aRowEnd;
    }
}

- (void) markGridRectAsUsed:(BSGridRect *)gridRect ByItemAtIndexPath:(NSIndexPath *) indexPath {
    for(NSInteger col = gridRect.colStart; col < gridRect.colEnd; col++) {
        for (NSInteger row =  gridRect.rowStart; row < gridRect.rowEnd; row++) {
            [self setPosition:CGPointMake(col, row) forIndexPath:indexPath];
        }
    }
}

@end
