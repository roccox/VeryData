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
@synthesize service_fee, orders, note;


-(void)print
{
    NSLog(@"Trade: tid-%qi,status-%@,created-%@,modified-%@,buyer-%@,rec_city-%@,rec_name-%@ \n",self.tid,self.status,[self.createdTime description],[self.modifiedTime description],self.buyer_nick,self.receiver_city,self.receiver_name);
    NSLog(@"Trade: discount-%f,adjust-%f,post-%f,total-%f,payment-%f,paytime-%@,note-%@ \n",self.discount_fee,self.adjust_fee,self.post_fee,self.total_fee,self.payment,[self.paymentTime description],self.note);
    
    for(TopOrderModel * order in orders)
    {
        [order print];
    }
    
}
-(double) getSales
{
    double sale = 0;
    if([self.status isEqualToString:@"WAIT_SELLER_SEND_GOODS"] ||
       [self.status isEqualToString:@"WAIT_BUYER_CONFIRM_GOODS"] ||
       [self.status isEqualToString:@"TRADE_BUYER_SIGNED"] ||
       [self.status isEqualToString:@"TRADE_FINISHED"]
       )
    {
        for (TopOrderModel * order in self.orders) {
            if([order.status isEqualToString:@"WAIT_SELLER_SEND_GOODS"] ||
               [order.status isEqualToString:@"WAIT_BUYER_CONFIRM_GOODS"] ||
               [order.status isEqualToString:@"TRADE_BUYER_SIGNED"] ||
               [order.status isEqualToString:@"TRADE_FINISHED"]){
                sale += order.total_fee - order.refund_num * order.total_fee/order.num;
            }
        }
        sale -= self.service_fee;
    }
    return  sale;
}
-(double) getProfit
{
    double profit = 0;
    if([self.status isEqualToString:@"WAIT_SELLER_SEND_GOODS"] ||
       [self.status isEqualToString:@"WAIT_BUYER_CONFIRM_GOODS"] ||
       [self.status isEqualToString:@"TRADE_BUYER_SIGNED"] ||
       [self.status isEqualToString:@"TRADE_FINISHED"]){
        for (TopOrderModel * order in self.orders) {
            if([order.status isEqualToString:@"WAIT_SELLER_SEND_GOODS"] ||
               [order.status isEqualToString:@"WAIT_BUYER_CONFIRM_GOODS"] ||
               [order.status isEqualToString:@"TRADE_BUYER_SIGNED"] ||
               [order.status isEqualToString:@"TRADE_FINISHED"]){
                profit += (order.total_fee - order.refund_num * order.total_fee/order.num) - order.import_price*(order.num-order.refund_num);
            }
        }
        profit -= self.service_fee;
    }
    
    return profit;   
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
        result = [db executeUpdate: @"INSERT INTO Trades (tid, status, created, modified, buyer,              receiver_city,receiver_name,discount_fee,adjust_fee,post_fee,total_fee,payment,payment_time) VALUES (?,?,?,?,?,  ?,?,?,?,?,  ?,?,?)",
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
                  self.paymentTime
                  ];    
    }
    else            //update
    {        
        result = [db executeUpdate: @"UPDATE Trades SET status=?, created=?, modified=?, buyer=?,              receiver_city=?,receiver_name=?,discount_fee=?,adjust_fee=?,post_fee=?,total_fee=?,payment=?,payment_time=? WHERE tid = ?",
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
                  [NSNumber numberWithLongLong: self.tid]
                  ];  
    }
    
    [db close];
    
    if(!result)
        NSLog(@"Trade Save Error!");

    for (TopOrderModel * order in self.orders) {
        [order save];
    }
    
	return result;
}

-(BOOL)saveServiceFee
{
    BOOL result = NO;
    //check exist
    FMDatabase * db = [DataBase shareDB];
	int count = 0;
	
    [db open];
    count = [db intForQuery:@"SELECT COUNT(*) FROM Trades where tid = ?",[NSNumber numberWithLongLong:self.tid]];
    
    
    if(count == 0)  //new
    {
        NSLog(@"Save Service Fee error - no record");
    }
    else            //update
    {        
        result = [db executeUpdate: @"UPDATE Trades SET service_fee=?,note=? WHERE tid = ?",
                  [NSNumber numberWithDouble: self.service_fee],
                  self.note,
                  [NSNumber numberWithLongLong: self.tid]
                  ];  
    }
    
    [db close];
    
    if(!result)
        NSLog(@"Trade Service Fee Save Error!");
    
	return result;
}
@end
