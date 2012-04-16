//
//  TopOrderModel.m
//  VeryData
//
//  Created by Rock on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopOrderModel.h"

@implementation TopOrderModel

@synthesize oid,num,num_iid,title,sku_name,pic_url,price,status;
@synthesize discount_fee,adjust_fee,total_fee,payment,tid;

-(void)print
{
    NSLog(@"Order: oid-%qi,num-%d,num_iid-%qi,title-%@,sku-%@ \n",self.oid,self.num,self.num_iid,self.title,self.sku_name);
    NSLog(@"Order: pic-%@,price-%f,status-%@,discount-%f,adjust-%f,total-%f,payment-%f,tid-%qi \n",self.pic_url,self.price,self.status,self.discount_fee,self.adjust_fee,self.total_fee,self.payment,self.tid);
  
}

-(BOOL)save
{
    BOOL result = NO;
    //check exist
    FMDatabase * db = [DataBase shareDB];
	int count = 0;
	
    [db open];
    count = [db intForQuery:@"SELECT COUNT(*) FROM Orders where oid = ?",[NSNumber numberWithLongLong:self.oid]];
    
    
    if(count == 0)  //new
    {
        result = [db executeUpdate: @"INSERT INTO Orders (oid, num, iid, title, sku,              pic_url,price,status,discount_fee,adjust_fee,total_fee,payment,tid) VALUES (?,?,?,?,?,  ?,?,?,?,?,  ?,?,?)",
                  [NSNumber numberWithLongLong: self.oid], 
                  [NSNumber numberWithInt: self.num], 
                  [NSNumber numberWithLongLong: self.num_iid], 
                  self.title,
                  self.sku_name,
                  
                  self.pic_url,
                  [NSNumber numberWithDouble: self.price],
                  self.status,
                  [NSNumber numberWithDouble: self.discount_fee],
                  [NSNumber numberWithDouble: self.adjust_fee],

                  [NSNumber numberWithDouble: self.total_fee],
                  [NSNumber numberWithDouble: self.payment],
                  [NSNumber numberWithLongLong: self.tid]
                  ];    
    }
    else            //update
    {        
        result = [db executeUpdate: @"UPDATE Orders SET num=?, iid=?, title=?, sku=?,              pic_url=?,price=?,status=?,discount_fee=?,adjust_fee=?,total_fee=?,payment=?,tid=? WHERE oid=?",
                  [NSNumber numberWithInt: self.num], 
                  [NSNumber numberWithLongLong: self.num_iid], 
                  self.title,
                  self.sku_name,
                  
                  self.pic_url,
                  [NSNumber numberWithDouble: self.price],
                  self.status,
                  [NSNumber numberWithDouble: self.discount_fee],
                  [NSNumber numberWithDouble: self.adjust_fee],
                  
                  [NSNumber numberWithDouble: self.total_fee],
                  [NSNumber numberWithDouble: self.payment],
                  [NSNumber numberWithLongLong: self.tid],
                  
                  [NSNumber numberWithLongLong: self.oid] 
                  ];   
    }
    
    [db close];

    if(!result)
        NSLog(@"Order Save Error!");
    
	return result;
}

@end
