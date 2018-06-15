//
//  main.m
//  TEST
//
//  Created by kintan on 17/8/29.
//  Copyright © 2017年 oceano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSError *error;
        NSFileManager *manager = [NSFileManager defaultManager];
        
        /**
         *  读出文件夹（文件名）
         */
        NSString *sourcePath = @"/Users/kintan/Desktop/未命名文件夹 3/A80DDBAD-1F55-4EBB-94FB-8D9ECBD11071/Documents/";
        NSString *dataBasePath = @"MJAPP_V2.sqlite";
//        NSString *targetPath = @"/Users/kintan/Desktop/ccreat/我的音乐/"; // 复制出来的目标文件夹
        NSArray *files = [manager contentsOfDirectoryAtPath:sourcePath error:&error];
        
        if (error) {
            NSLog(@"error：%@ ",error);
        }
        NSLog(@"文件夹内所有文件：%@ ",files);
        
        
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[sourcePath stringByAppendingPathComponent:dataBasePath]];
        [queue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:@"select * from Z_METADATA where 1 = 1;"];
            while (rs.next) {
                NSData *albumname = [rs objectForColumnName:@"Z_PLIST"];
                NSLog(@"%@",albumname);
                
                
                NSError *err;
                NSArray *list = [NSJSONSerialization JSONObjectWithData:albumname
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
                
                NSLog(@"%@",list);
            }
        }];
    }
    return 0;
}
