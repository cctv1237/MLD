//
//  BSGridCalculator.m
//  LogicGridLayout
//
//  Created by LF on 15/6/25.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "BSGridLayoutLocator.h"
#import "BSGridFreeSpace.h"
#import "BSGridPosition.h"
#import "BSGridBlock.h"
#import "BSGridRect.h"

#define INITIAL_CONTENT @"."

@interface BSGridLayoutLocator ()

@property (nonatomic, assign) NSInteger colCount;
@property (nonatomic, assign) CGSize gridUnit;

@property (nonatomic,strong) NSMutableArray *freeSpaces;
@property (nonatomic,strong) BSGridFreeSpaceComparator *comparator;

// 目前下面这些属性非网格布局算法所必需，主要用于问题诊断
@property (nonatomic,strong) NSMutableArray *gridMatrix;
@property (nonatomic, strong) NSMutableArray *gridBlocks;
@property (nonatomic, strong) NSMutableArray *gridRects;

@end

@implementation BSGridLayoutLocator

#pragma mark constructor methods

- (instancetype)initWithColCount:(NSInteger)colCount GridUnit:(CGSize)gridUnit {
    
    if (self = [super init]) {
        self.colCount = colCount;
        self.gridUnit = gridUnit;
        [self initFreePlaces];
        self.comparator = [[BSGridFreeSpaceComparator alloc] init];
        
        self.gridRects = [[NSMutableArray alloc] init];
        self.gridBlocks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark public methods

// 以追加至矩阵末尾的方式确定给定的grid block列表中每一个元素的位置
- (NSMutableArray *) locateGridBlocksInAppendMode:(NSMutableArray *)gridBlocks {
    [self.gridBlocks addObjectsFromArray:gridBlocks];
    
    BSGridRect *gridRect;
    NSMutableArray *resultGridRects = [[NSMutableArray alloc] init];
    
    for (BSGridBlock *gridBlock in self.gridBlocks) {
        gridRect = [self locateBlock:gridBlock];
        [self.gridRects addObject:gridRect];
        [self recalcFreePlaces:gridRect];
        [resultGridRects addObject:gridRect];
    }
    
    return resultGridRects;
}

- (BSGridRect *)locateOneBlockInAppendMode:(BSGridBlock *)gridBlock {
    BSGridRect *gridRect = [self locateBlock:gridBlock];
    [self recalcFreePlaces:gridRect];
    
    [self.gridRects addObject:gridRect];
    [self.gridBlocks addObject:gridBlock];
    
    return gridRect;
}

//- (BSGridRect *)shouldAddOneBlock:(BSGridBlock *)gridBlock {
//    [self.gridBlocks addObject:gridBlock];
//    self.gridRects = [self locateGridBlocksFromScratch:self.gridBlocks];
//    return [self.gridRects lastObject];
//}

// 该方法会清空整个布局管理器，而不管之前状态如何；然后确定给定的grid block列表中每一个元素的位置
- (NSMutableArray *)locateGridBlocksFromScratch:(NSMutableArray *)gridBlocks {
    [self clear];
    return [self locateGridBlocksInAppendMode:gridBlocks];
}

// 将整个布局打印至控制台
- (void) printWholeLayout {
    // 为了最小化性能和内存开销，在需要使用的时候再初始化gridMatrix，因为它并非布局算法所必需
    self.gridMatrix = [[NSMutableArray alloc] init];
    
    [self fillInAllGridRectsWithSequenceNumber];
    for (int i = 0; i < self.gridMatrix.count; i++) {
        for (int j = 0; j < self.colCount; j++) {
            printf(" %s ",[[[self.gridMatrix objectAtIndex:i] objectAtIndex:j] UTF8String]);
        }
        printf("\n");
    }
}

#pragma mark private methods

// ---- init and clear methods

// 该方法不管当前freeSpaces状态如何，直接将其初始化为未添加任何grid block的状态
- (void) initFreePlaces {
    self.freeSpaces = [[NSMutableArray alloc] init];
    [self.freeSpaces addObject:[self createFreePlaceWithRowStart:0 colStart:0 colCount:self.colCount]];
}

- (BSGridFreeSpace *)createFreePlaceWithRowStart:(NSInteger)rowStart colStart:(NSInteger)colStart colCount:(NSInteger)colCount {
    return [[BSGridFreeSpace alloc] initWithRowStart:rowStart ColStart:colStart ColSpan:colCount];
}

// 该方法不管当前自身状态如何，直接将自身初始化为未添加任何grid block的状态。
// 如果想清理整个布局定位器，请务必调用此方法，以确保所有相关属性被重置为合适的值
- (void) clear {
    [self initFreePlaces];
    
    self.gridMatrix = nil;
    [self.gridRects removeAllObjects];
    [self.gridBlocks removeAllObjects];
}

// ---- calculate the location of the given block

- (BSGridRect *)locateBlock:(BSGridBlock *)gridBlock {
    
    NSMutableArray *freePlacesToDelete = [[NSMutableArray alloc] init];
    
    BSGridPosition *gridPosition = nil;
    if (self.freeSpaces != nil && self.freeSpaces.count > 0) {
        for (BSGridFreeSpace *free in self.freeSpaces) {
            if (gridBlock.colSpan <= free.colSpan) {
                gridPosition = [[BSGridPosition alloc] initWithRowStart:free.rowStart
                                                            ColumnStart:free.colStart];
                break;
            }
            else {
                [freePlacesToDelete addObject:free];
            }
        }
        
        for (BSGridFreeSpace *freePlace in freePlacesToDelete) {
            [self.freeSpaces removeObject:freePlace];
        }
    }
    
    CGRect absFrame = [self translateToAbsFrame:gridPosition AndGridBlock:gridBlock];
    return [[BSGridRect alloc] initWithGridPosition:gridPosition GridBlock:gridBlock AbsFrame:absFrame];
}

- (void)recalcFreePlaces:(BSGridRect *)gridRect {
    NSMutableArray *freePlacesToAdd = [[NSMutableArray alloc] init];
    NSMutableArray *freePlacesToDelete = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.freeSpaces.count; i++) {
        BSGridFreeSpace *gridFreeSpace = [self.freeSpaces objectAtIndex:i];
        
        if ([gridFreeSpace contain:gridRect]) {
            
            [freePlacesToDelete addObject:gridFreeSpace];
            [freePlacesToAdd addObjectsFromArray:[gridFreeSpace producedFreeSpacesWhenContain:gridRect]];
            
        } else if ([gridFreeSpace intersectWithVertically:gridRect]) {
            
            [freePlacesToDelete addObject:gridFreeSpace];
            [freePlacesToAdd addObjectsFromArray:[gridFreeSpace producedFreeSpacesWhenIntersectWithVertically:gridRect]];
            
        } else if ([gridFreeSpace intersectWithFromLeftHorizontally:gridRect]) {
            
            [freePlacesToDelete addObject:gridFreeSpace];
            [freePlacesToAdd addObjectsFromArray:[gridFreeSpace producedFreeSpacesWhenIntersectWithFromLeftHorizontally:gridRect]];
            
        } else if ([gridFreeSpace intersectWithFromRightHorizontally:gridRect]) {
            
            [freePlacesToDelete addObject:gridFreeSpace];
            [freePlacesToAdd addObjectsFromArray:[gridFreeSpace producedFreeSpacesWhenIntersectWithFromRightHorizontally:gridRect]];
            
        }
    }
    
    for (BSGridFreeSpace *freePlace in freePlacesToDelete) {
        [self.freeSpaces removeObject:freePlace];
    }
    
    freePlacesToAdd = [self.comparator sortFreeSpaceAfterCompare:freePlacesToAdd];
    for (BSGridFreeSpace *freePlace in freePlacesToAdd) {
        if (freePlace.colSpan == 0 || [self isFreeSpaceToAddContained:freePlace]) {
            continue;
        }
        [self.freeSpaces addObject:freePlace];
    }
    
    self.freeSpaces = [self.comparator sortFreeSpaceAfterCompare:self.freeSpaces];
}

- (BOOL) isFreeSpaceToAddContained:(BSGridFreeSpace *)gridFreeSpaceToAdd {
    for (BSGridFreeSpace *gridFreeSpace in self.freeSpaces) {
        if ([gridFreeSpace containOrSameAs:gridFreeSpaceToAdd]) {
            return YES;
        }
    }
    return NO;
}

// ---- translate the location and size in grid layout to the absolute location and size

- (CGRect)translateToAbsFrame:(BSGridPosition *)gridPosition AndGridBlock:(BSGridBlock *)gridBlock{
    CGPoint origin = [self translateToAbsPosition:gridPosition];
    CGSize size = [self translateToAbsSize:gridBlock];
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}

- (CGSize)translateToAbsSize:(BSGridBlock *)gridBlock {
    CGFloat absWidth = gridBlock.colSpan * _gridUnit.width;
    CGFloat absHeight = gridBlock.rowSpan * _gridUnit.height;
    return CGSizeMake(absWidth, absHeight);
}

- (CGPoint)translateToAbsPosition:(BSGridPosition *)gridPosition {
    CGFloat xOfAbsPosition= gridPosition.colStart * _gridUnit.width;
    CGFloat yOfAbsPosition= gridPosition.rowStart * _gridUnit.height;
    return CGPointMake(xOfAbsPosition, yOfAbsPosition);
}

// ---- 下面这些方法仅用于将整个布局打印出来，以便诊断问题，非布局算法所必需

// 将每一个GridRect对应的顺序号填充至其在网格矩阵中的对应区域
- (void) fillInAllGridRectsWithSequenceNumber {
    for (int i = 0; i < self.gridRects.count; i++) {
        [self fillInGridRect:self.gridRects[i] WithContent:[NSString stringWithFormat:@"%d", i]];
    }
}

// 将给定GridRect对应的顺序号填充至其在网格矩阵中的对应区域
- (void) fillInGridRect:(BSGridRect *)gridRect WithContent:(NSString *)content {
    NSInteger rowEnd = [gridRect rowEnd];
    NSInteger colEnd = [gridRect colEnd];
    [self extendMatrixToRowEnd:rowEnd];
    
    for (NSInteger i = [gridRect rowStart]; i < rowEnd; i++) {
        for (NSInteger j = [gridRect colStart]; j < colEnd; j++) {
            [self fillInGridCell:i :j WithContent:content];
        }
    }
}

// 将给定的内容填充至指定的网格单元格
- (void) fillInGridCell:(NSInteger)x :(NSInteger)y WithContent:(NSString *)content {
    [[self.gridMatrix objectAtIndex:x] replaceObjectAtIndex:y withObject:content];
}

// 将矩阵扩展至指定的行数
- (void) extendMatrixToRowEnd:(NSInteger)rowEnd {
    if (rowEnd > self.gridMatrix.count) {
        [self appendNewRows:(rowEnd - self.gridMatrix.count)];
    }
}

// 给矩阵添加指定的行数
- (void) appendNewRows:(NSInteger)count {
    for (int i = 0; i < count; i++) {
        if (self.gridMatrix.count == 997) {
            NSLog(@"");
        }
        [self.gridMatrix addObject: [self createRowOfMatrix:INITIAL_CONTENT]];
    }
}

- (NSMutableArray *)createRowOfMatrix:(NSString *)content {
    NSMutableArray *gridArray = [[NSMutableArray alloc] initWithCapacity:self.colCount];
    for (int numOfCol = 0; numOfCol < self.colCount; numOfCol++) {
        [gridArray addObject:content];
    }
    return gridArray;
}

@end