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
@synthesize  buyer_nick,receiver_city,receiver_name;
@synthesize discount_fee,adjust_fee,post_fee,total_fee,payment,paymentTime;
@synthesize  orders;


-(void)print
{
    NSLog(@"Trade: tid-%ld,status-%@,created-%@,modified-%@,buyer-%@,rec_city-%@,rec_name-%@ \n",self.tid,self.status,[self.createdTime description],[self.modifiedTime description],self.buyer_nick,self.receiver_city,self.receiver_name);
    NSLog(@"Trade: discount-%f,adjust-%f,post-%f,total-%f,payment-%f,paytime-%@ \n",self.discount_fee,self.adjust_fee,self.post_fee,self.total_fee,self.payment,[self.paymentTime description]);
    
    for(TopOrderModel * order in orders)
    {
        [order print];
    }
    
}

@end
