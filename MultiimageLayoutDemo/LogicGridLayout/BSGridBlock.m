//
//  BSPanelSize.m
//  RDHCollectionViewGridLayoutDemo
//
//  Created by chenlong on 6/10/15.
//  Copyright (c) 2015 Rich H. All rights reserved.
//

#import "BSGridBlock.h"

@interface BSGridBlock ()

@end

@implementation BSGridBlock

- (instancetype)initWithRowSpan:(NSInteger)rowSpan ColSpan:(NSInteger)colSpan Content:(NSString *)content {
    
    if (self = [super init]) {
        self.rowSpan = rowSpan;
        self.colSpan = colSpan;
        self.content = content;
    }
    return self;
}

@end
