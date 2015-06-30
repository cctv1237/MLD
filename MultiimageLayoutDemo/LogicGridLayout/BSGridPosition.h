//
//  BSGridPosition.h
//  RDHCollectionViewGridLayoutDemo
//
//  Created by chenlong on 6/10/15.
//  Copyright (c) 2015 Rich H. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSGridPosition : NSObject

@property (nonatomic, assign) NSInteger rowStart;
@property (nonatomic, assign) NSInteger colStart;

- (instancetype)initWithRowStart:(NSInteger)rowStart ColumnStart:(NSInteger)colStart;

@end
