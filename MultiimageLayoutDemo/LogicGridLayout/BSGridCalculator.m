//
//  BSGridCalculator.m
//  LogicGridLayout
//
//  Created by LF on 15/6/25.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "BSGridCalculator.h"
#import "BSGridFreeSpace.h"
#import "BSGridPosition.h"
#import "BSGridBlock.h"
#import "BSGridRect.h"

#define MAX_COL_COUNT 6
#define MAX_ROW_COUNT 1000
#define INITIAL_CONTENT @"."

@interface BSGridCalculator ()

@property (nonatomic,strong) NSMutableArray *disMatrix;
@property (nonatomic,strong) NSMutableArray *gridFreeSpaces;
@property (nonatomic,strong) BSGridFreeSpaceComparator *comparator;

@end

@implementation BSGridCalculator

- (instancetype)init {
    if (self = [super init]) {
        
        self.disMatrix = [[NSMutableArray alloc] initWithCapacity:MAX_ROW_COUNT];
        for (int numOfRow = 0; numOfRow < MAX_ROW_COUNT; numOfRow++) {
            [self.disMatrix addObject: [self createRowOfMatrix:INITIAL_CONTENT]];
        }
        self.gridRects = [[NSMutableArray alloc] init];
        self.gridBlocks = [[NSMutableArray alloc] init];
        self.gridFreeSpaces = [[NSMutableArray alloc] init];
        self.comparator = [[BSGridFreeSpaceComparator alloc] init];
        
    }
    return self;

}

- (NSMutableArray *)createRowOfMatrix:(NSString *)content {
    
    NSMutableArray *gridArray = [[NSMutableArray alloc] initWithCapacity:MAX_COL_COUNT];
    for (int numOfCol = 0; numOfCol < MAX_COL_COUNT; numOfCol++) {
        [gridArray addObject:content];
    }
    return gridArray;
}


- (void)initFreePlace {
    if (self.gridFreeSpaces != nil) {
        [self appendFreePlace:0];
    }
}

- (void)appendFreePlace:(NSInteger)rowStart {
    [self.gridFreeSpaces addObject:[self createFreePlace:rowStart]];
}

- (BSGridFreeSpace *)createFreePlace:(NSInteger)rowStart {
    return [[BSGridFreeSpace alloc] initWithRowStart:rowStart ColStart:0 ColSpan:MAX_COL_COUNT];
}

- (void)printMatrix {
    for (int i = 0; i < self.disMatrix.count; i++) {
        for (int j = 0; j < MAX_COL_COUNT; j++) {
            printf(" %s ",[[[self.disMatrix objectAtIndex:i] objectAtIndex:j] UTF8String]);
        }
        printf("\n");
    }
}

- (void)doGridCalculate {
    [self.disMatrix removeAllObjects];
    [self appendNewLines:1];
    [self initFreePlace];
    [self doLocate];
    [self printMatrix];
}

- (void)doLocate {
    BSGridRect *gridRect = [[BSGridRect alloc] init];
    BSGridBlock *gridBlock = [[BSGridBlock alloc] init];
    for (gridBlock in self.gridBlocks) {
        gridRect = [self locateBlock:gridBlock];
        [self.gridRects addObject:gridRect];
        [self markFrame:gridRect];
        [self reCalcFreePlaces:gridRect];
    }
}

- (BSGridRect *)locateBlock:(BSGridBlock *)gridBlock {
    
    NSMutableArray *freePlacesToDelete = [[NSMutableArray alloc] init];
    
    BSGridPosition *gridPosition = nil;
    if (self.gridFreeSpaces != nil && self.gridFreeSpaces.count > 0) {
        for (BSGridFreeSpace *free in self.gridFreeSpaces) {
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
            [self.gridFreeSpaces removeObject:freePlace];
        }
    }
    
    return [[BSGridRect alloc] initWithGridPosition:gridPosition GridBlock:gridBlock];
}

- (void)reCalcFreePlaces:(BSGridRect *)gridRect {
    
    NSMutableArray *freePlacesToAdd = [[NSMutableArray alloc] init];
    NSMutableArray *freePlacesToDelete = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.gridFreeSpaces.count; i++) {
        BSGridFreeSpace *gridFreeSpace = [self.gridFreeSpaces objectAtIndex:i];
        
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
        [self.gridFreeSpaces removeObject:freePlace];
    }
    
    freePlacesToAdd = [self.comparator sortFreeSpaceAfterCompare:freePlacesToAdd];
    for (BSGridFreeSpace *freePlace in freePlacesToAdd) {
        if (freePlace.colSpan == 0 || [self isFreeSpaceToAddContained:freePlace]) {
            continue;
        }
        [self.gridFreeSpaces addObject:freePlace];
    }
    
    self.gridFreeSpaces = [self.comparator sortFreeSpaceAfterCompare:self.gridFreeSpaces];
}

- (BOOL)isFreeSpaceToAddContained:(BSGridFreeSpace *)gridFreeSpaceToAdd {
    for (BSGridFreeSpace *gridFreeSpace in self.gridFreeSpaces) {
        if ([gridFreeSpace containOrSameAs:gridFreeSpaceToAdd]) {
            return YES;
        }
    }
    return NO;
}

- (void)appendNewLine:(NSMutableArray *)disMatrix {
    // 在矩阵的最后添加一行
    NSMutableArray *line = [[NSMutableArray alloc] initWithCapacity:MAX_COL_COUNT];
    
    // 为最后一行填充内容
    for (int i = 0; i < MAX_COL_COUNT; i++) {
        [line addObject:INITIAL_CONTENT];
    }
    [disMatrix addObject:line];
}

- (void)appendNewLines:(NSInteger)count {
    for (int i = 0; i < count; i++) {
        [self appendNewLine:self.disMatrix];
    }
}

- (void)markCell:(NSInteger)x :(NSInteger)y :(NSString *)content {
    
    [[self.disMatrix objectAtIndex:x] replaceObjectAtIndex:y withObject:content];
    
}

- (void)reCalcMatrix:(NSInteger)rowEnd {
    if (rowEnd > self.disMatrix.count && rowEnd < MAX_ROW_COUNT) {
        [self appendNewLines:rowEnd - self.disMatrix.count];
    }
}

- (void)markFrame:(BSGridRect *)gridRect {
    BSGridPosition *gridPosition = gridRect.gridPosition;
    BSGridBlock *gridBlock = gridRect.gridBlock;
    NSInteger rowEnd = gridPosition.rowStart + gridBlock.rowSpan;
    NSInteger colEnd = gridPosition.colStart + gridBlock.colSpan;
    [self reCalcMatrix:rowEnd];
    
    for (NSInteger i = gridPosition.rowStart; i < rowEnd; i++) {
        for (NSInteger j = gridPosition.colStart; j < colEnd; j++) {
            [self markCell:i :j :gridBlock.content];
        }
    }
}


@end
