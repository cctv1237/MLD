//
//  BSGridPosition.m
//  RDHCollectionViewGridLayoutDemo
//
//  Created by chenlong on 6/10/15.
//  Copyright (c) 2015 Rich H. All rights reserved.
//

#import "BSGridPosition.h"

@interface BSGridPosition ()

@end

@implementation BSGridPosition

- (instancetype)initWithRowStart:(NSInteger)rowStart ColumnStart:(NSInteger)colStart {
    
    if (self = [super init]) {
        self.rowStart = rowStart;
        self.colStart = colStart;
    }
    return self;
}

@end
