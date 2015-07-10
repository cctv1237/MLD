//
//  BSGridFreeSpace.m
//  RDHCollectionViewGridLayoutDemo
//
//  Created by LF on 15/6/11.
//  Copyright (c) 2015年 Rich H. All rights reserved.
//

#import "BSGridFreeSpace.h"
#import "BSGridPosition.h"
#import "BSGridBlock.h"
#import "BSGridRect.h"

@implementation BSGridFreeSpace

- (instancetype)initWithGridPosition:(BSGridPosition *)gridPosition ColSpan:(NSInteger)colSpan {
    
    if (self = [super init]) {
        self.gridPosition = gridPosition;
        self.colSpan = colSpan;
    }
    return self;
}

- (instancetype)initWithRowStart:(NSInteger)rowStart ColStart:(NSInteger)colStart ColSpan:(NSInteger)colSpan {
    
    if (self = [super init]) {
        self.gridPosition = [[BSGridPosition alloc] initWithRowStart:rowStart ColumnStart:colStart];
        self.colSpan = colSpan;
    }
    return self;
}

- (NSInteger)rowStart {
    return self.gridPosition.rowStart;
}

- (NSInteger)colStart {
    return self.gridPosition.colStart;
}

- (NSInteger)colEnd {
    return (self.gridPosition.colStart + self.colSpan);
}

- (BOOL)containOrSameAs:(BSGridFreeSpace *)another {
    
    if (another.colStart >= self.colStart
        && another.colEnd <= self.colEnd
        && another.gridPosition.rowStart >= self.rowStart) {
        return YES;
    }
    return NO;
}

- (BOOL)contain:(BSGridRect *)gridRect {
    
    return (self.rowStart == gridRect.rowStart);
}

- (NSMutableArray *)producedFreeSpacesWhenContain:(BSGridRect *)gridRect {
    
    NSMutableArray *producedGridFreeSpaces = [[NSMutableArray alloc] initWithCapacity:2];
    
    [producedGridFreeSpaces addObject:[[BSGridFreeSpace alloc] initWithRowStart:gridRect.rowEnd
                                                                       ColStart:self.colStart
                                                                        ColSpan:self.colSpan]];
    [producedGridFreeSpaces addObject:[[BSGridFreeSpace alloc] initWithRowStart:self.rowStart
                                                                       ColStart:gridRect.colEnd
                                                                        ColSpan:self.colSpan - gridRect.colSpan]];
    return producedGridFreeSpaces;
}

- (BOOL)intersectWithVertically:(BSGridRect *)gridRect {
    
    return (self.rowStart > gridRect.rowStart && self.rowStart < gridRect.rowEnd)
    && (
        (gridRect.colStart >= self.colStart && gridRect.colStart < self.colEnd)
        || (gridRect.colEnd > self.colStart && gridRect.colEnd <= self.colEnd)
        );
}

- (NSMutableArray *)producedFreeSpacesWhenIntersectWithVertically:(BSGridRect *)gridRect {
    
    NSMutableArray *producedGridFreeSpaces = [[NSMutableArray alloc] initWithCapacity:3];
    
    [producedGridFreeSpaces addObject:[[BSGridFreeSpace alloc] initWithRowStart:self.rowStart
                                                                       ColStart:self.colStart
                                                                        ColSpan:gridRect.colStart - self.colStart]];
    [producedGridFreeSpaces addObject:[[BSGridFreeSpace alloc] initWithRowStart:self.rowStart
                                                                       ColStart:gridRect.colEnd
                                                                        ColSpan:self.colEnd - gridRect.colEnd]];
    [producedGridFreeSpaces addObject:[[BSGridFreeSpace alloc] initWithRowStart:gridRect.rowEnd
                                                                       ColStart:self.colStart
                                                                        ColSpan:self.colSpan]];
    return producedGridFreeSpaces;
}

- (BOOL)intersectWithFromLeftHorizontally:(BSGridRect *)gridRect {
    return (self.colStart >= gridRect.colStart && self.colStart < gridRect.colEnd) && (gridRect.rowEnd > self.rowStart);
}

- (NSMutableArray *)producedFreeSpacesWhenIntersectWithFromLeftHorizontally:(BSGridRect *)gridRect {
    
     NSMutableArray *producedGridFreeSpaces = [[NSMutableArray alloc] initWithCapacity:1];
    
    if (gridRect.colEnd < self.colEnd) {
        [producedGridFreeSpaces addObject:[[BSGridFreeSpace alloc] initWithRowStart:gridRect.rowStart
                                                                           ColStart:gridRect.colEnd
                                                                            ColSpan:self.colEnd - gridRect.colEnd]];
    }
    return producedGridFreeSpaces;
}

- (BOOL)intersectWithFromRightHorizontally:(BSGridRect *)gridRect {
    return (self.colEnd > gridRect.colStart && self.colEnd <= gridRect.colEnd) && (gridRect.rowEnd > self.rowStart);
}

- (NSMutableArray *)producedFreeSpacesWhenIntersectWithFromRightHorizontally:(BSGridRect *)gridRect {
    
    NSMutableArray *producedGridFreeSpaces = [[NSMutableArray alloc] initWithCapacity:1];
    if (gridRect.colStart > self.colStart) {
        [producedGridFreeSpaces addObject:[[BSGridFreeSpace alloc] initWithRowStart:gridRect.rowStart
                                                                           ColStart:self.colStart
                                                                            ColSpan:gridRect.colStart - self.colStart]];
    }
    return producedGridFreeSpaces;
}

@end


@implementation BSGridFreeSpaceComparator

- (NSInteger)compare:(BSGridFreeSpace *)o1 And:(BSGridFreeSpace *)o2 {
    
    if (o1.rowStart == o2.rowStart) {
        return (o1.colStart - o2.colStart);
    } else {
        return (o1.rowStart - o2.rowStart);
    }
}

- (NSMutableArray *)sortFreeSpaceAfterCompare:(NSMutableArray *)freeSpaces {
    
    NSArray *sortArray = [freeSpaces sortedArrayUsingComparator:^NSComparisonResult(BSGridFreeSpace *o1, BSGridFreeSpace *o2) {
        NSInteger rowDiff = o1.rowStart - o2.rowStart;
        NSInteger colDiff = o1.colStart - o2.colStart;
        
        if (rowDiff > 0) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (rowDiff < 0) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        if (rowDiff == 0) {
            
            if (colDiff > 0) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if (colDiff < 0) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            else {
                return (NSComparisonResult)NSOrderedSame;
            }
        }
        else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
    
    [freeSpaces removeAllObjects];
    [freeSpaces addObjectsFromArray:sortArray];
    return freeSpaces;
}

@end
