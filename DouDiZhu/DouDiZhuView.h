//
//  DouDiZhuView.h
//  DouDiZhu
//
//  Created by dingjing on 17/1/28.
//  Copyright © 2017年 dingjing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelCell.h"

@interface DouDiZhuView : UIView

@property (nonatomic, strong) LabelCell *bindCell;
@property (nonatomic, strong) NSMutableArray *roundRecord;
@property (nonatomic, strong) NSMutableArray *currentPlayer;
@property (nonatomic, assign) BOOL hasSelectFarmer;
@property (nonatomic, assign) BOOL canPlayMore;
@property (nonatomic, assign) NSInteger hostIndex;
@property (nonatomic, strong) NSSet *set;
@property (nonatomic, assign) NSInteger lastValue;
@property (nonatomic, strong) NSMutableArray *titleArray;

@property (nonatomic, copy) void (^playerWinBlock)(NSInteger index);
@property (nonatomic, copy) void (^selectPlayerBlock)(NSInteger index);
- (void)reloadData;

@end
