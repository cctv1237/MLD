//
//  BSGridFreeSpace.h
//  RDHCollectionViewGridLayoutDemo
//
//  Created by LF on 15/6/11.
//  Copyright (c) 2015年 Rich H. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BSGridPosition,BSGridRect,BSGridBlock;

@interface BSGridFreeSpace : NSObject

@property (nonatomic,strong) BSGridPosition *gridPosition;
@property (nonatomic,assign) NSInteger colSpan;

- (instancetype)initWithRowStart:(NSInteger)rowStart ColStart:(NSInteger)colStart ColSpan:(NSInteger)colSpan;

- (NSInteger)rowStart;
- (NSInteger)colStart;
- (NSInteger)colEnd;


- (BOOL)containOrSameAs:(BSGridFreeSpace *)another;
- (BOOL)contain:(BSGridRect *)gridRect;
- (NSMutableArray *)producedFreeSpacesWhenContain:(BSGridRect *)gridRect;
- (BOOL)intersectWithVertically:(BSGridRect *)gridRect;
- (NSMutableArray *)producedFreeSpacesWhenIntersectWithVertically:(BSGridRect *)gridRect;
- (BOOL)intersectWithFromLeftHorizontally:(BSGridRect *)gridRect;
- (NSMutableArray *)producedFreeSpacesWhenIntersectWithFromLeftHorizontally:(BSGridRect *)gridRect;
- (BOOL)intersectWithFromRightHorizontally:(BSGridRect *)gridRect;
- (NSMutableArray *)producedFreeSpacesWhenIntersectWithFromRightHorizontally:(BSGridRect *)gridRect;

@end

@interface BSGridFreeSpaceComparator : BSGridFreeSpace

- (NSInteger)compare:(BSGridFreeSpace *)o1 And:(BSGridFreeSpace *)o2;
- (NSMutableArray *)sortFreeSpaceAfterCompare:(NSMutableArray *)freeSpaces;

@end