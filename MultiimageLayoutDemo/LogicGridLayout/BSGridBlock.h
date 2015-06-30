//
//  BSPanelSize.h
//  RDHCollectionViewGridLayoutDemo
//
//  Created by chenlong on 6/10/15.
//  Copyright (c) 2015 Rich H. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSGridBlock : NSObject

@property (nonatomic, assign) NSInteger rowSpan;
@property (nonatomic, assign) NSInteger colSpan;

@property (nonatomic,strong) NSString *content;

- (instancetype)initWithRowSpan:(NSInteger)rowSpan ColSpan:(NSInteger)colSpan Content:(NSString *)content;

@end
