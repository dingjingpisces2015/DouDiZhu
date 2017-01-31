//
//  HistoryList.m
//  DouDiZhu
//
//  Created by dingjing on 17/1/30.
//  Copyright © 2017年 dingjing. All rights reserved.
//

#import "HistoryList.h"
#import "PointRecordManager.h"
#import "ViewController.h"
#import "HistoryDetailViewController.h"

@interface HistoryList () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *fileList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *startNewGame;

@end

@implementation HistoryList

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.fileList = [PointRecordManager shareInstance].filesArray;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    _fileList = [PointRecordManager shareInstance].filesArray;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64 - 30)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _startNewGame = [[UIButton alloc] initWithFrame:CGRectMake(0, _tableView.frame.size.height + _tableView.frame.origin.y,  100, 30)];
    [_startNewGame setTitle:@"开启新游戏" forState:UIControlStateNormal];
    [_startNewGame setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_startNewGame addTarget:self action:@selector(navigatorToNewGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startNewGame];
    [self.view addSubview:_tableView];
    // Do any additional setup after loading the view.
}

- (void)navigatorToNewGame
{
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    if (!tableViewCell) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"historyCell"];
    }
    tableViewCell.textLabel.text = self.fileList[indexPath.row];
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = self.fileList[indexPath.row];
    NSArray *data = [[PointRecordManager shareInstance] readFileContent:fileName];
    if (![data isKindOfClass:[NSArray class]]) {
        return;
    }
    HistoryDetailViewController *viewController = [HistoryDetailViewController new];
    viewController.roundRecord = data;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
