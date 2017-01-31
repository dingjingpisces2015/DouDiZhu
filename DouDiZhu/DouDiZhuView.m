//
//  DouDiZhuView.m
//  DouDiZhu
//
//  Created by dingjing on 17/1/28.
//  Copyright © 2017年 dingjing. All rights reserved.
//

#import "DouDiZhuView.h"

static const NSInteger columNum = 5;
static const CGFloat cellHeight = 45;
static const CGFloat kMargin = 30.f;
static const CGFloat kTopMarging = 20.f;
@interface DouDiZhuView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation DouDiZhuView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleArray = [NSMutableArray array];
        NSArray *titleName = @[@"参赛选手", @"老丁", @"老王", @"小丁", @"倍数"];
        for (NSInteger index = 0; index < 5; index ++) {
            UILabel *label = [UILabel new];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = titleName[index];
            [_titleArray addObject:label];
            [self addSubview:label];
        }
        _lastValue = 1;
        _set = [[NSSet alloc] initWithObjects:@0, @1, @2, nil];
//        [self resetCurrentPlayer];
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)layoutSubviews
{
    NSInteger index = 0;
    CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width / columNum;
    for (UILabel *label in self.titleArray) {
        label.frame = CGRectMake(labelWidth * index, kTopMarging, labelWidth, cellHeight);
        index++;
    }
    self.collectionView.frame = CGRectMake(0, kTopMarging + cellHeight + 10, self.frame.size.width, self.frame.size.height - kTopMarging - cellHeight - 10 - kMargin);
    [super layoutSubviews];
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kMargin + 10, self.frame.size.width, self.frame.size.height - 2*kMargin - 10) collectionViewLayout:self.layout];
        
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[LabelCell class] forCellWithReuseIdentifier:@"LabelCell"];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout
{
    if (!_layout) {
        _layout = [UICollectionViewFlowLayout new];
        _layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / columNum, cellHeight);
        _layout.minimumInteritemSpacing = 0;
    }
    return _layout;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.roundRecord.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LabelCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"LabelCell" forIndexPath:indexPath];
    cell.content = [self.roundRecord objectAtIndex:indexPath.row];
    if (indexPath.row % columNum == 4 && indexPath.row + columNum == self.roundRecord.count - 1) {
        self.bindCell = cell;
    }
    
    NSInteger remain = indexPath.row % columNum;
    NSInteger colum = floor(indexPath.row / columNum);
    NSInteger maxColum = floor(self.roundRecord.count / columNum);//就是这么奇葩的逻辑
    if (remain < 4 && remain > 0 && colum == maxColum - 2) {
        self.currentPlayer[remain - 1] = cell;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger remain = indexPath.row % columNum;
    NSInteger colum = floor(indexPath.row / columNum);
    NSInteger maxColum = floor(self.roundRecord.count / columNum);
    if (remain < 4 && remain > 0 && colum == maxColum - 2) {
        if (self.hasSelectFarmer) {
            if (self.playerWinBlock) {
                self.playerWinBlock(remain - 1);
            }
        } else {
            if (self.selectPlayerBlock) {
                self.selectPlayerBlock(remain - 1);
            }
        }
    }
}



@end
