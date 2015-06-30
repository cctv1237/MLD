//
//  BSGridRect.m
//  RDHCollectionViewGridLayoutDemo
//
//  Created by chenlong on 6/10/15.
//  Copyright (c) 2015 Rich H. All rights reserved.
//

#import "BSGridRect.h"
#import "BSGridPosition.h"
#import "BSGridBlock.h"

@interface BSGridRect ()

@end

@implementation BSGridRect

- (instancetype) initWithGridPosition:(BSGridPosition *)gridPosition GridBlock:(BSGridBlock *)gridBlock {
    
    if ([super init]) {
        self.gridPosition = gridPosition;
        self.gridBlock = gridBlock;
    }
    return self;
}

- (NSInteger)rowStart {
    return self.gridPosition.rowStart;
}

- (NSInteger)rowEnd {
    return (self.gridPosition.rowStart + self.gridBlock.rowSpan);
}

- (NSInteger)colStart {
    return self.gridPosition.colStart;
}

- (NSInteger)colEnd {
    return (self.gridPosition.colStart + self.gridBlock.colSpan);
}

- (NSInteger)rowSpan {
    return self.gridBlock.rowSpan;
}

- (NSInteger)colSpan {
    return self.gridBlock.colSpan;
}

@end
