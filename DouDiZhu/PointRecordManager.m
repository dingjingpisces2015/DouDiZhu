//
//  PointRecordManager.m
//  DouDiZhu
//
//  Created by dingjing on 17/1/29.
//  Copyright © 2017年 dingjing. All rights reserved.
//

#import "PointRecordManager.h"
@interface PointRecordManager()

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation PointRecordManager

+(instancetype)shareInstance
{
    static PointRecordManager *manager;
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [PointRecordManager new];
            manager.formatter = [[NSDateFormatter alloc] init];
            manager.formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        });
    }
    return manager;
}

- (NSArray *)readFileContent:(NSString *)fileName
{
    NSString *documentsPath =[self dirDoc];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSArray *result = [NSArray arrayWithContentsOfFile:filePath];
    return result;
}

-(NSString *)dirDoc
{
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"app_home_doc: %@",documentsDirectory);
    return documentsDirectory;
}

-(void)createFileAndWriteData:(NSArray *)inputData
{
    NSString *documentsPath =[self dirDoc];
    
    NSString *testPath = [documentsPath stringByAppendingPathComponent:[self.formatter stringFromDate:[NSDate new]]];
    [inputData writeToFile:testPath atomically:YES];
}

- (NSArray *)filesArray
{
    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self dirDoc] error:nil];
    return paths;
}

@end
