//
//  ChangeMusicName.m
//  TEST
//
//  Created by kintan on 2017/11/20.
//  Copyright © 2017年 oceano. All rights reserved.
//

#import "ChangeMusicName.h"
#import "FMDB.h"

@implementation ChangeMusicName

- (void)changeMusicName
{
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    /**
     *  读出文件夹（文件名）
     */
    NSString *sourcePath = @"/Users/kintan/Desktop/ccreat/4ADBA683-E4CA-4C3D-A5B3-34DCA4D17129/Documents/UserData/Download/done/";
    NSString *dataBasePath = @"/Users/kintan/Desktop/ccreat/4ADBA683-E4CA-4C3D-A5B3-34DCA4D17129/Documents/UserData/Download/sqlite-back-v2.sqlite3";
    NSString *targetPath = @"/Users/kintan/Desktop/ccreat/我的音乐/"; // 复制出来的目标文件夹
    NSArray *files = [manager contentsOfDirectoryAtPath:sourcePath error:&error];
    
    if (error) {
        NSLog(@"error：%@ ",error);
    }
    NSLog(@"文件夹内所有文件：%@ ",files);
    
    /**
     *  筛选mp3的文件
     */
    NSMutableArray *musices = [NSMutableArray array];
    for (NSString *mp3Name in files) {
        if ([[mp3Name pathExtension] isEqualToString:@"mp3"]) {
            [musices addObject:mp3Name];
        }
    }
    NSLog(@"文件夹文件：%@ ",musices);
    
    
    /**
     *  得到文件的songId
     */
    NSMutableArray *musicIds = [NSMutableArray array];
    for (NSString *mp3Name in musices) {
        NSArray *compons = [mp3Name componentsSeparatedByString:@"-"];
        NSLog(@"文件名分段：%@ ",compons);
        [musicIds addObject:compons[1]];
    }
    
    /**
     *  读取数据库
     */
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:dataBasePath];
    
    NSMutableArray *names = [NSMutableArray array];
    NSMutableArray *albumnames = [NSMutableArray array];
    
    for (NSString *musicId in musicIds) {
        [queue inDatabase:^(FMDatabase *db) {
            FMResultSet *rs = [db executeQuery:@"select * from track where songid = ?;", musicId];
            while (rs.next) {
                NSString *name = [rs stringForColumn:@"name"];
                NSString *albumname = [rs stringForColumn:@"albumname"];
                [names addObject:name];
                [albumnames addObject:albumname];
            }
        }];
    }
    
    NSLog(@"文件名对应的歌曲名：%@ ",names);
    NSLog(@"文件名对应的歌曲名：%@ ",albumnames);
    
    // 文件重命名
    for (int i = 0; i < musices.count; i++) {
        NSString *fileName = musices[i];
        NSString *musicName = names[i];
        NSString *albumName = albumnames[i];
        
        NSString *target;
        NSString *source = [sourcePath stringByAppendingString:fileName];
        if ([musicName isEqualToString:albumName]) {
            target = [targetPath stringByAppendingString:[musicName stringByAppendingString:@".mp3"]];
        } else {
            target = [targetPath stringByAppendingString:[NSString stringWithFormat:@"%@-%@.mp3",musicName,albumName]];
        }
        
        NSError *error;
        BOOL sucess = [manager copyItemAtPath:source toPath:target error:nil];
        if (sucess) {
            NSLog(@"复制成功");
        } else {
            if (error) {
                NSLog(@"失败原因：%@",error);
            }
        }
    }
}

@end
