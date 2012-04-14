//
//  TopTradeModel.h
//  VeryData
//
//  Created by Rock on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TopOrderModel.h"

@interface TopTradeModel : NSObject

@property (nonatomic) long long tid;
@property (nonatomic,strong) NSString * status;
@property (nonatomic,strong) NSDate * createdTime;
@property (nonatomic,strong) NSDate * modifiedTime;

@property (nonatomic,strong) NSString * buyer_nick;
@property (nonatomic,strong) NSString * receiver_city;
@property (nonatomic,strong) NSString * receiver_name;

@property (nonatomic) double discount_fee;
@property (nonatomic) double adjust_fee;
@property (nonatomic) double post_fee;
@property (nonatomic) double total_fee;
@property (nonatomic) double payment;
@property (nonatomic,strong) NSDate * paymentTime;

@property (nonatomic,strong) NSMutableArray * orders;

-(void)print;

@end
