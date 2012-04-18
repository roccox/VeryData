//
//  TopItemModel.m
//  VeryData
//
//  Created by Rock on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopItemModel.h"

@implementation TopItemModel

@synthesize num_iid,title,pic_url,price,volume,import_price,note;


-(void)print
{
    NSLog(@"Item: id-%qi,title-%@,pic_url-%@ \n",self.num_iid,self.title,self.pic_url);
    NSLog(@"Item: price-%f,volume-%d,import_price-%f,note-%@ \n",self.price,self.volume,self.import_price,self.note);
}

-(BOOL)save
{
    BOOL result = NO;
    //check exist
    FMDatabase * db = [DataBase shareDB];
	int count = 0;
	
    [db open];
    count = [db intForQuery:@"SELECT COUNT(*) FROM Items where iid = ?",[NSNumber numberWithLongLong:self.num_iid]];


    if(count == 0)  //new
    {
        result = [db executeUpdate: @"INSERT INTO Items (iid, title, pic_url, price, volume) VALUES (?,?,?,?,?)",
                        [NSNumber numberWithLongLong: self.num_iid], 
                        self.title, 
                        self.pic_url,
                        [NSNumber numberWithDouble: self.price],
                        [NSNumber numberWithInt: self.volume]
                  ];    
    }
    else            //update
    {
        result = [db executeUpdate: @"UPDATE Items SET title = ?, pic_url = ?, price = ?, volume = ? WHERE iid = ?",
                  self.title, 
                  self.pic_url,
                  [NSNumber numberWithDouble: self.price],
                  [NSNumber numberWithInt: self.volume],
                  [NSNumber numberWithLongLong: self.num_iid]
                  ]; 
    }
    
    [db close];
    
    if(!result)
        NSLog(@"Item Save Error!");
    
	return result;
}

-(BOOL)saveImportPrice
{
    {
        BOOL result = NO;
        //check exist
        FMDatabase * db = [DataBase shareDB];
        int count = 0;
        
        [db open];
        count = [db intForQuery:@"SELECT COUNT(*) FROM Items where iid = ?",[NSNumber numberWithLongLong:self.num_iid]];
        
        
        if(count == 0)  //new
        {
            NSLog(@"Item Import_price Save Error - no record!");
        }
        else            //update
        {
            result = [db executeUpdate: @"UPDATE Items SET import_price = ?, note=? WHERE iid = ?",
                      [NSNumber numberWithDouble: self.import_price],
                      self.note,
                      [NSNumber numberWithLongLong: self.num_iid]
                      ]; 
        }
        
        [db close];
        
        if(!result)
            NSLog(@"Item Import_price Save Error!");
        
        return result;
    }    
}

@end
