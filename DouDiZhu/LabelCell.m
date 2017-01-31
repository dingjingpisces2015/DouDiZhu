//
//  LabelCell.m
//  DouDiZhu
//
//  Created by dingjing on 17/1/29.
//  Copyright © 2017年 dingjing. All rights reserved.
//

#import "LabelCell.h"

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
