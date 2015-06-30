//
//  BSGridRect.h
//  RDHCollectionViewGridLayoutDemo
//
//  Created by chenlong on 6/10/15.
//  Copyright (c) 2015 Rich H. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BSGridPosition,BSGridBlock;

@interface BSGridRect : NSObject

@property (nonatomic, strong) BSGridPosition *gridPosition;
@property (nonatomic, strong) BSGridBlock *gridBlock;

@property (nonatomic, assign, readonly) NSInteger rowStart;
@property (nonatomic, assign, readonly) NSInteger rowEnd;
@property (nonatomic, assign, readonly) NSInteger colStart;
@property (nonatomic, assign, readonly) NSInteger colEnd;
@property (nonatomic, assign, readonly) NSInteger rowSpan;
@property (nonatomic, assign, readonly) NSInteger colSpan;

- (instancetype) initWithGridPosition:(BSGridPosition *)gridPosition GridBlock:(BSGridBlock *)gridBlock;

@end
