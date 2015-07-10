//
//  ViewController.m
//  FlowLayout
//
//  Created by LF on 15/6/5.
//  Copyright (c) 2015年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "ViewController.h"
#import "BSGridLayoutCell.h"
#import "BSGridLayout.h"
#import "BSGridBlock.h"
#import "BSGridLayoutLocator.h"

@interface ViewController () <BSGridLayoutDelegate>

@property (nonatomic,assign) NSInteger itemCount;
@property (nonatomic,strong) NSMutableArray *gridBlocks;
@property (nonatomic, strong) BSGridLayout *gridLayout;

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCollectionViewLayout:[self newGridLayout]];
    if (self) {
        self.gridBlocks = [NSMutableArray array];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.contentInset = UIEdgeInsetsMake(15, 15, 15, 15);
        [self.collectionView registerClass:[BSGridLayoutCell class] forCellWithReuseIdentifier:@"cell"];
        _itemCount = 5;
    }
    return self;

}

- (BSGridLayout *)newGridLayout
{
    _gridLayout = [[BSGridLayout alloc] init];
    _gridLayout.delegate = self;
    return _gridLayout;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.collectionView reloadData];
    
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor redColor];
    button.frame = CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 50, 50, 50);
    [button addTarget:self action:@selector(change) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)change {
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.itemCount inSection:0]]];
        self.itemCount ++;
    } completion:^(BOOL done) {
        NSLog(@"%d",(int)self.itemCount);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BSGridLayoutCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UILabel* label = (id)[cell viewWithTag:5];
    if(!label) label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    label.tag = 5;
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
    label.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:label];
    
    return cell;
}

#pragma mark - LayoutDelegate

- (BSGridBlock *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout itemAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSInteger rowSpan = arc4random()%3 + 2;
//    NSInteger colSpan = arc4random()%3 + 2;
    
    NSInteger rowSpan = 6;
    NSInteger colSpan = 6;
    
    if (rowSpan <= 1) {
        rowSpan = 2;
    }
    if (colSpan <= 1) {
        colSpan = 2;
    }
    
    printf(">>>>> indexPath(%ld, %ld, %ld) item(%d, %d) \n",
           (long)indexPath.section, indexPath.row, indexPath.item,
           (int) colSpan, (int) rowSpan);
    
    return [[BSGridBlock alloc] initWithRowSpan:rowSpan
                                        ColSpan:colSpan
                                        Content:[NSString stringWithFormat:@"%d",(int)indexPath.item + 1]];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

@end
