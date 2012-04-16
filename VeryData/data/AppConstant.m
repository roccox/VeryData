//
//  AppConstant.m
//  VeryData
//
//  Created by Rock on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppConstant.h"

static AppConstant * single = nil;

@implementation AppConstant

@synthesize last_fetch;

-(void)print
{
    NSLog(@"Constant: last_fetch-%@ \n",self.last_fetch);    
}

-(BOOL)save
{
    BOOL result = NO;
    //check exist
    FMDatabase * db = [DataBase shareDB];
	int count = 0;
	
    [db open];
    count = [db intForQuery:@"SELECT COUNT(*) FROM Constant where id = 0"];
    
    
    if(count == 0)  //new
    {
        result = [db executeUpdate: @"INSERT INTO Constant (last_fetch,id) VALUES (?,0)",
                  self.last_fetch
                  ];    
    }
    else            //update
    {
        result = [db executeUpdate: @"UPDATE Constant SET last_fetch = ?  where id = 0",
                  self.last_fetch
                  ]; 
    }
    
    NSLog(@"last_fetch 2 - %@",self.last_fetch);
    [db close];
    
	return result;
}

+(AppConstant *)shareObject
{
    if (single == nil) {
        single = [[AppConstant alloc] init];
    
        //get data
        BOOL result = NO;
        FMDatabase * db = [DataBase shareDB];
        [db open];
        int count = 0;
	
        [db open];
        count = [db intForQuery:@"SELECT COUNT(*) FROM Constant where id = 0"];
    
        if(count == 0)  //new
        {
            [db close];
            single.last_fetch = [[NSDate alloc]initWithTimeIntervalSinceNow:(8*60*60-80*24*60*60)];    //back to 3 month GT + 8
            [single save];
        }
        else            //update
        {
            single.last_fetch = [db dateForQuery:@"Select last_fetch from Constant where id = 0"]; 
            [db close];
        }
    }
    return single;
}
@end
