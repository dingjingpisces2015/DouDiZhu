//
//  ViewController.m
//  DouDiZhu
//
//  Created by dingjing on 17/1/27.
//  Copyright © 2017年 dingjing. All rights reserved.
//

#import "ViewController.h"
#import "PointRecordManager.h"
#import "LabelCell.h"
#import "DouDiZhuView.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *roundRecord;
@property (nonatomic, strong) UIButton *playAgain;
@property (nonatomic, strong) UIStepper *stepper;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *viewHistoryButton;
@property (nonatomic, strong) DouDiZhuView *mainView;

@end

static const NSInteger columNum = 5;
@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    _mainView = [[DouDiZhuView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-30-64)];
    __weak typeof(self) _weak_self = self;
    _mainView.playerWinBlock = ^(NSInteger index) {
        [_weak_self playerWin:index];
    };
    _mainView.selectPlayerBlock = ^(NSInteger index) {
        [_weak_self selectPlayer:index];
    };
    _roundRecord = [NSMutableArray array];
    [_roundRecord addObjectsFromArray:@[@"Round 1",@"农民", @"农民", @"农民", @"1"]];
    [_roundRecord addObjectsFromArray:@[@"结算",@"0", @"0", @"0", @" "]];
    _mainView.roundRecord = self.roundRecord;
    
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
    
    _saveButton = [UIButton new];
    [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [_saveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self resetCurrentPlayer];
    [self.view addSubview:_saveButton];
    [self.view addSubview:_stepper];
    [self.view addSubview:_playAgain];
    [self.view addSubview:self.mainView];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)save
{
    [[PointRecordManager shareInstance] createFileAndWriteData:self.mainView.roundRecord.copy];
}

- (void)playAgainAction
{
    if (!self.mainView.canPlayMore) {
        return;
    }
    NSString *round = [NSString stringWithFormat:@"Round %ld", self.roundRecord.count/columNum];
    self.mainView.hasSelectFarmer = NO;
    self.mainView.canPlayMore = NO;
    self.mainView.lastValue = 1;
    self.stepper.value = 1.0;
    [self resetCurrentPlayer];
    [self.roundRecord insertObject:round atIndex:self.roundRecord.count - columNum];
    [self.roundRecord insertObject:@"农民" atIndex:self.roundRecord.count - columNum];
    [self.roundRecord insertObject:@"农民" atIndex:self.roundRecord.count - columNum];
    [self.roundRecord insertObject:@"农民" atIndex:self.roundRecord.count - columNum];
    [self.roundRecord insertObject:@"1" atIndex:self.roundRecord.count - columNum];
    
    [self.mainView reloadData];
}

- (void)viewDidLayoutSubviews
{
    self.stepper.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - self.stepper.frame.size.width, self.mainView.frame.origin.y+self.mainView.frame.size.height, self.stepper.frame.size.width, self.stepper.frame.size.height);
    
    [self.playAgain sizeToFit];
    self.playAgain.frame = CGRectMake(0, self.mainView.frame.origin.y+self.mainView.frame.size.height, self.playAgain.frame.size.width, self.playAgain.frame.size.height);
    
    [self.saveButton sizeToFit];
    self.saveButton.frame = CGRectMake(self.playAgain.frame.size.width + 30, self.mainView.frame.origin.y+self.mainView.frame.size.height, self.saveButton.frame.size.width, self.saveButton.frame.size.height);
    
    [super viewDidLayoutSubviews];
}

- (void)stepperChange
{
    if (self.stepper.value < 1.1 && self.stepper.value > 0.9) {
        self.stepper.stepValue = 1;
        self.mainView.lastValue = 1;
        return;
    }
    if (self.stepper.value > self.mainView.lastValue) {
        self.stepper.value = self.mainView.lastValue * 2;
        self.mainView.lastValue = self.stepper.value;
        return;
    }
    self.stepper.value = (int)self.mainView.lastValue / 2;
    self.mainView.lastValue = self.stepper.value;
}

- (void)showChange
{
    self.mainView.bindCell.content = [NSString stringWithFormat:@"%d", (int)_stepper.value];
}

- (void)selectPlayer:(NSInteger)player
{
    if (self.mainView.canPlayMore == YES) {
        return;
    }
    ((LabelCell *)self.mainView.currentPlayer[player]).content = @"地主";
    self.mainView.hostIndex = player;
    self.mainView.hasSelectFarmer = YES;
    self.mainView.canPlayMore = NO;
    [self asynData];
}

- (void)asynData
{
    NSMutableArray *array = [NSMutableArray array];
    [self.mainView.currentPlayer enumerateObjectsUsingBlock:^(LabelCell *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:obj.content];
    }];
    [self.roundRecord replaceObjectsInRange:NSMakeRange(self.roundRecord.count - 4 - columNum, 3) withObjectsFromArray:array];
    self.roundRecord[self.roundRecord.count-columNum-1] = [NSString stringWithFormat:@"%d", (int)self.stepper.value];
}

- (void)playerWin:(NSInteger)player
{
    if (self.mainView.hostIndex == player) {
        LabelCell *cell = self.mainView.currentPlayer[player];
        cell.content = [NSString stringWithFormat:@"%ld", [self.mainView.bindCell.content integerValue] * 2];
        NSMutableSet *set = [self.mainView.set mutableCopy];
        [set minusSet:[[NSSet alloc] initWithObjects:@(player), nil]];
        [set enumerateObjectsUsingBlock:^(NSNumber *obj, BOOL * _Nonnull stop) {
            LabelCell *cell = self.mainView.currentPlayer[obj.integerValue];
            cell.content = [NSString stringWithFormat:@"%ld", -[self.mainView.bindCell.content integerValue]];
        }];
    } else {
        LabelCell *cell = self.mainView.currentPlayer[self.mainView.hostIndex];
        cell.content = [NSString stringWithFormat:@"%ld", - [self.mainView.bindCell.content integerValue] * 2];
        NSMutableSet *set = [self.mainView.set mutableCopy];
        [set minusSet:[[NSSet alloc] initWithObjects:@(self.mainView.hostIndex), nil]];
        [set enumerateObjectsUsingBlock:^(NSNumber *obj, BOOL * _Nonnull stop) {
            LabelCell *cell = self.mainView.currentPlayer[obj.integerValue];
            cell.content = [NSString stringWithFormat:@"%ld", [self.mainView.bindCell.content integerValue]];
        }];
    }
    self.mainView.canPlayMore = YES;
    [self asynData];
    [self reCalculateSum];
}

- (void)resetCurrentPlayer
{
    self.mainView.currentPlayer = [@[[LabelCell new], [LabelCell new], [LabelCell new]] mutableCopy];
}

- (void)reCalculateSum
{
    self.mainView.hasSelectFarmer = NO;
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
    [self.mainView reloadData];
    [[NSUserDefaults standardUserDefaults] setObject:self.roundRecord forKey:@"playRecord"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
