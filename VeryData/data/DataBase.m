//
//  DataHelper.m
//  VeryData
//
//  Created by Rock on 12-4-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DataBase.h"

static FMDatabase * db;

@implementation DataBase

+(FMDatabase *)shareDB
{
    if (db) {
		return db;
	}
    
    NSLog(@"%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
	NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *realPath = [documentPath stringByAppendingPathComponent:@"verydata.sqlite"];
	
	NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"verydata" ofType:@"sqlite"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:realPath]) {
		NSError *error;
		if (![fileManager copyItemAtPath:sourcePath toPath:realPath error:&error]) {
			NSLog(@"%@",[error localizedDescription]);
		}
	}
	
	NSLog(@"复制sqlite到路径：%@成功。",realPath);
	
	//把db地址修改为可修改的realPath。
	db = [[FMDatabase alloc] initWithPath:realPath];
		
	return db;
}

@end
