//
//  TopItemModel.m
//  VeryData
//
//  Created by Rock on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopItemModel.h"

@implementation TopItemModel

@synthesize num_iid,title,pic_url,price,volume,import_price;


-(void)print
{
    NSLog(@"Item: id-%qi,title-%@,pic_url-%@ \n",self.num_iid,self.title,self.pic_url);
    NSLog(@"Item: price-%f,title-%d,import_price-%f \n",self.price,self.volume,self.import_price);
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
        result = [db executeUpdate: @"INSERT INTO Items (iid, title, pic_url, price, volume, import_price) VALUES (?,?,?,?,?,?)",
                        [NSNumber numberWithLongLong: self.num_iid], 
                        self.title, 
                        self.pic_url,
                        [NSNumber numberWithDouble: self.price],
                        [NSNumber numberWithInt: self.volume],
                        [NSNumber numberWithDouble: self.import_price]
                  ];    
    }
    else            //update
    {
        result = [db executeUpdate: @"UPDATE Items SET title = ?, pic_url = ?, price = ?, volume = ?, import_price = ? WHERE iid = ?",
                  self.title, 
                  self.pic_url,
                  [NSNumber numberWithDouble: self.price],
                  [NSNumber numberWithInt: self.volume],
                  [NSNumber numberWithDouble: self.import_price],
                  [NSNumber numberWithLongLong: self.num_iid]
                  ]; 
    }
    
    [db close];
    
	return result;
}

@end
