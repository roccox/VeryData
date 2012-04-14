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
@synthesize discount_fee,adjust_fee,total_fee,payment,post_fee;

-(void)print
{
    NSLog(@"Order: oid-%ld,num-%d,num_iid-%ld,title-%@,sku-%@ \n",self.oid,self.num,self.num_iid,self.title,self.sku_name);
    NSLog(@"Order: pic-%@,price-%f,status-%@,discount-%f,adjust-%f,total-%f,payment-%f,post-%f \n",self.pic_url,self.price,self.status,self.discount_fee,self.adjust_fee,self.total_fee,self.payment,self.post_fee);
  
}

@end
