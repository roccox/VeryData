//
//  TopTradeModel.m
//  VeryData
//
//  Created by Rock on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopTradeModel.h"

@implementation TopTradeModel

@synthesize tid,status,createdTime,modifiedTime;
@synthesize buyer_nick,receiver_city,receiver_name;
@synthesize discount_fee,adjust_fee,post_fee,total_fee,payment,paymentTime;
@synthesize service_fee, orders;


-(void)print
{
    NSLog(@"Trade: tid-%qi,status-%@,created-%@,modified-%@,buyer-%@,rec_city-%@,rec_name-%@ \n",self.tid,self.status,[self.createdTime description],[self.modifiedTime description],self.buyer_nick,self.receiver_city,self.receiver_name);
    NSLog(@"Trade: discount-%f,adjust-%f,post-%f,total-%f,payment-%f,paytime-%@ \n",self.discount_fee,self.adjust_fee,self.post_fee,self.total_fee,self.payment,[self.paymentTime description]);
    
    for(TopOrderModel * order in orders)
    {
        [order print];
    }
    
}

-(BOOL)save
{
    BOOL result = NO;
    //check exist
    FMDatabase * db = [DataBase shareDB];
	int count = 0;
	
    [db open];
    count = [db intForQuery:@"SELECT COUNT(*) FROM Trades where tid = ?",[NSNumber numberWithLongLong:self.tid]];
    
    
    if(count == 0)  //new
    {
        result = [db executeUpdate: @"INSERT INTO Trades (tid, status, created, modified, buyer,              receiver_city,receiver_name,discount_fee,adjust_fee,post_fee,total_fee,payment,payment_time,service_fee) VALUES (?,?,?,?,?,  ?,?,?,?,?,  ?,?,?,?)",
                  [NSNumber numberWithLongLong: self.tid], 
                  self.status,
                  self.createdTime,
                  self.modifiedTime,
                  self.buyer_nick,
                  
                  self.receiver_city,
                  self.receiver_name,
                  [NSNumber numberWithDouble: self.discount_fee],
                  [NSNumber numberWithDouble: self.adjust_fee],
                  [NSNumber numberWithDouble: self.post_fee],
                  

                  [NSNumber numberWithDouble: self.total_fee],
                  [NSNumber numberWithDouble: self.payment],
                  self.paymentTime,
                  [NSNumber numberWithDouble: self.service_fee]
                  ];    
    }
    else            //update
    {        
        result = [db executeUpdate: @"UPDATE Trades SET status=?, created=?, modified=?, buyer=?,              receiver_city=?,receiver_name=?,discount_fee=?,adjust_fee=?,post_fee=?,total_fee=?,payment=?,payment_time=?,service_fee=?  WHERE tid = ?",
                  self.status,
                  self.createdTime,
                  self.modifiedTime,
                  self.buyer_nick,
                  
                  self.receiver_city,
                  self.receiver_name,
                  [NSNumber numberWithDouble: self.discount_fee],
                  [NSNumber numberWithDouble: self.adjust_fee],
                  [NSNumber numberWithDouble: self.post_fee],
                  
                  
                  [NSNumber numberWithDouble: self.total_fee],
                  [NSNumber numberWithDouble: self.payment],
                  self.paymentTime,
                  [NSNumber numberWithDouble: self.service_fee],
                  [NSNumber numberWithLongLong: self.tid]
                  ];  
    }
    
    [db close];
    
    for (TopOrderModel * order in self.orders) {
        [order save];
    }
    
	return result;
}

@end
