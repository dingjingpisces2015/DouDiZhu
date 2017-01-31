//
//  PointRecordManager.h
//  DouDiZhu
//
//  Created by dingjing on 17/1/29.
//  Copyright © 2017年 dingjing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completionBlock)(NSArray *data);

@interface PointRecordManager : NSObject
+(instancetype)shareInstance;
- (NSArray *)readFileContent:(NSString *)fileName;
- (NSArray *)filesArray;
-(void)createFileAndWriteData:(NSArray *)inputData;
- (void)readFile:(NSString *)filePath completion:(completionBlock)block;

@end
