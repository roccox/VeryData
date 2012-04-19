//
//  TopOrderModel.h
//  VeryData
//
//  Created by Rock on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBase.h"

@interface TopOrderModel : NSObject

@property (nonatomic) long long oid;
@property (nonatomic) int num;
@property (nonatomic) long long num_iid;
@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) NSString * sku_name;
@property (nonatomic,strong) NSString * pic_url;
@property (nonatomic) double price;

@property (nonatomic) double import_price;

@property (nonatomic,strong) NSString * status;

@property (nonatomic) double discount_fee;
@property (nonatomic) double adjust_fee;
@property (nonatomic) double total_fee;
@property (nonatomic) double payment;
@property (nonatomic,strong) NSString * refund;

@property (nonatomic)int refund_num;
@property (nonatomic) long long tid;
-(void)print;

-(BOOL)save;
-(BOOL)saveRefundNum;

@end
