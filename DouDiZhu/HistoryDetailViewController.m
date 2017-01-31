//
//  HistoryDetailViewController.m
//  DouDiZhu
//
//  Created by dingjing on 17/1/30.
//  Copyright © 2017年 dingjing. All rights reserved.
//

#import "HistoryDetailViewController.h"
#import "DouDiZhuView.h"

@interface HistoryDetailViewController ()

@property (nonatomic, strong) DouDiZhuView *mainView;

@end

@implementation HistoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    _mainView = [[DouDiZhuView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64)];
    _mainView.roundRecord = self.roundRecord.mutableCopy;
    [self.view addSubview:_mainView];
    // Do any additional setup after loading the view.
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
