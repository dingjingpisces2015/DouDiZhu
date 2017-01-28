//
//  ViewController.m
//  DouDiZhu
//
//  Created by dingjing on 17/1/27.
//  Copyright © 2017年 dingjing. All rights reserved.
//

#import "ViewController.h"

@interface LabelCell : UICollectionViewCell

@property (nonatomic, strong) NSString *content;

@end

@interface LabelCell()

@property (nonatomic, strong) UILabel *contentLabel;

@end
@implementation LabelCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _contentLabel = [[UILabel alloc] initWithFrame:frame];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_contentLabel];
    }
    return  self;
}

- (void)setContent:(NSString *)content
{
    _content = content;
    _contentLabel.text = content;
}

- (void)layoutSubviews
{
    self.contentLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [super layoutSubviews];
}

@end

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *roundRecord;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIButton *playAgain;
@property (nonatomic, strong) UIStepper *stepper;
@property (nonatomic, strong) LabelCell *bindCell;
@property (nonatomic, strong) NSMutableArray *currentPlayer;
@property (nonatomic, assign) BOOL hasSelectFarmer;
@property (nonatomic, assign) BOOL canPlayMore;
@property (nonatomic, assign) NSInteger hostIndex;
@property (nonatomic, strong) NSSet *set;
@property (nonatomic, assign) NSInteger lastValue;
@property (nonatomic, strong) NSMutableArray *titleArray;

@end

static const NSInteger columNum = 5;
static const CGFloat cellHeight = 45;
@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _titleArray = [NSMutableArray array];
    NSArray *titleName = @[@"参赛选手", @"老丁", @"老王", @"小丁", @"倍数"];
    for (NSInteger index = 0; index < 5; index ++) {
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = titleName[index];
        [_titleArray addObject:label];
        [self.view addSubview:label];
    }
    
    _roundRecord = [NSMutableArray array];
    [_roundRecord addObjectsFromArray:@[@"Round 1",@"农民", @"农民", @"农民", @"1"]];
    [_roundRecord addObjectsFromArray:@[@"结算",@"0", @"0", @"0", @" "]];
    
    _lastValue = 1;
    _stepper = [UIStepper new];
    _stepper.value = 1.f;
    _stepper.minimumValue = 1;
    _stepper.maximumValue = DBL_MAX;
    [_stepper addTarget:self action:@selector(stepperChange) forControlEvents:UIControlEventValueChanged];
    [_stepper addTarget:self action:@selector(showChange) forControlEvents:UIControlEventTouchUpInside];
    _playAgain = [UIButton new];
    [_playAgain setTitle:@"再来一局" forState:UIControlStateNormal];
    [_playAgain addTarget:self action:@selector(playAgainAction) forControlEvents:UIControlEventTouchUpInside];
    [_playAgain setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    _set = [[NSSet alloc] initWithObjects:@0, @1, @2, nil];
    [self resetCurrentPlayer];
    [self.view addSubview:_stepper];
    [self.view addSubview:_playAgain];
    [self.view addSubview:self.collectionView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)playAgainAction
{
    if (!self.canPlayMore) {
        return;
    }
    NSString *round = [NSString stringWithFormat:@"Round %ld", self.roundRecord.count/columNum];
    self.hasSelectFarmer = NO;
    self.canPlayMore = NO;
    self.lastValue = 1;
    [self resetCurrentPlayer];
    [self.roundRecord insertObject:round atIndex:self.roundRecord.count - columNum];
    [self.roundRecord insertObject:@"农民" atIndex:self.roundRecord.count - columNum];
    [self.roundRecord insertObject:@"农民" atIndex:self.roundRecord.count - columNum];
    [self.roundRecord insertObject:@"农民" atIndex:self.roundRecord.count - columNum];
    [self.roundRecord insertObject:@"1" atIndex:self.roundRecord.count - columNum];
    
    [self.collectionView reloadData];
}

- (void)viewDidLayoutSubviews
{
    self.stepper.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - self.stepper.frame.size.width, [UIScreen mainScreen].bounds.size.height - 30, self.stepper.frame.size.width, self.stepper.frame.size.height);
    
    NSInteger index = 0;
    CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width / columNum;
    for (UILabel *label in self.titleArray) {
        label.frame = CGRectMake(labelWidth * index, 30, labelWidth, cellHeight);
        index++;
    }
    [self.playAgain sizeToFit];
    self.playAgain.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 30, self.playAgain.frame.size.width, self.playAgain.frame.size.height);
    
    [super viewDidLayoutSubviews];
}

- (void)stepperChange
{
    if (self.stepper.value < 1.1 && self.stepper.value > 0.9) {
        self.stepper.stepValue = 1;
        self.lastValue = 1;
        return;
    }
    if (self.stepper.value > self.lastValue) {
        self.stepper.value = self.lastValue * 2;
        self.lastValue = self.stepper.value;
        return;
    }
    self.stepper.value = (int)self.lastValue / 2;
    self.lastValue = self.stepper.value;
}

- (void)showChange
{
    self.bindCell.content = [NSString stringWithFormat:@"%d", (int)_stepper.value];
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        CGRect collectionSize = CGRectMake(0, 30 + cellHeight + 10 , [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 60 - cellHeight - 10);
        _collectionView = [[UICollectionView alloc] initWithFrame:collectionSize collectionViewLayout:self.layout];
        
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
            [self playerWin:remain-1];
        } else {
            [self selectPlayer:remain-1];
        }
    }
}

- (void)selectPlayer:(NSInteger)player
{
    if (self.canPlayMore == YES) {
        return;
    }
    ((LabelCell *)self.currentPlayer[player]).content = @"地主";
    self.hostIndex = player;
    self.hasSelectFarmer = YES;
    self.canPlayMore = NO;
    [self asynData];
}

- (void)asynData
{
    NSMutableArray *array = [NSMutableArray array];
    [self.currentPlayer enumerateObjectsUsingBlock:^(LabelCell *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:obj.content];
    }];
    [self.roundRecord replaceObjectsInRange:NSMakeRange(self.roundRecord.count - 4 - columNum, 3) withObjectsFromArray:array];
}

- (void)playerWin:(NSInteger)player
{
    if (self.hostIndex == player) {
        LabelCell *cell = self.currentPlayer[player];
        cell.content = [NSString stringWithFormat:@"%ld", [self.bindCell.content integerValue] * 2];
        NSMutableSet *set = [self.set mutableCopy];
        [set minusSet:[[NSSet alloc] initWithObjects:@(player), nil]];
        [set enumerateObjectsUsingBlock:^(NSNumber *obj, BOOL * _Nonnull stop) {
            LabelCell *cell = self.currentPlayer[obj.integerValue];
            cell.content = [NSString stringWithFormat:@"%ld", -[self.bindCell.content integerValue]];
        }];
    } else {
        LabelCell *cell = self.currentPlayer[self.hostIndex];
        cell.content = [NSString stringWithFormat:@"%ld", - [self.bindCell.content integerValue] * 2];
        NSMutableSet *set = [self.set mutableCopy];
        [set minusSet:[[NSSet alloc] initWithObjects:@(self.hostIndex), nil]];
        [set enumerateObjectsUsingBlock:^(NSNumber *obj, BOOL * _Nonnull stop) {
            LabelCell *cell = self.currentPlayer[obj.integerValue];
            cell.content = [NSString stringWithFormat:@"%ld", [self.bindCell.content integerValue]];
        }];
    }
    self.canPlayMore = YES;
    [self asynData];
    [self reCalculateSum];
}

- (void)resetCurrentPlayer
{
    self.currentPlayer = [@[[LabelCell new], [LabelCell new], [LabelCell new]] mutableCopy];
}

- (void)reCalculateSum
{
    self.hasSelectFarmer = NO;
    [self resetCurrentPlayer];
    for (NSInteger col = 1; col < 4; col ++) {
        NSInteger num = 0;
        for (NSInteger row = 0; row < (int)self.roundRecord.count/columNum - 1; row++) {
            NSInteger index = row*columNum+col;
            num = num + [self.roundRecord[index] integerValue];
        }
        NSInteger index = self.roundRecord.count - columNum + col;
        self.roundRecord[index] = [NSString stringWithFormat:@"%ld", num];
    }
    [self.collectionView reloadData];
    [[NSUserDefaults standardUserDefaults] setObject:self.roundRecord forKey:@"playRecord"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
