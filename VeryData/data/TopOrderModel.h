//
//  TopOrderModel.h
//  VeryData
//
//  Created by Rock on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopOrderModel : NSObject

@property (nonatomic) long oid;
@property (nonatomic) int num;
@property (nonatomic) long num_iid;
@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) NSString * sku_name;
@property (nonatomic,strong) NSString * pic_url;
@property (nonatomic) double price;

@property (nonatomic,strong) NSString * status;

@property (nonatomic) double discount_fee;
@property (nonatomic) double adjust_fee;
@property (nonatomic) double total_fee;
@property (nonatomic) double payment;

@property (nonatomic) double post_fee;

-(void)print;

@end
