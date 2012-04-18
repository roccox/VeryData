//
//  TradeCell.h
//  VeryData
//
//  Created by Rock on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TradeCell : UITableViewCell


@property (nonatomic,strong) IBOutlet UILabel * createdTime;
@property (nonatomic,strong) IBOutlet UILabel * paymentTime;
@property (nonatomic,strong) IBOutlet UILabel * status;
@property (nonatomic,strong) IBOutlet UILabel * buyer;
@property (nonatomic,strong) IBOutlet UILabel * rec;
@property (nonatomic,strong) IBOutlet UILabel * note;
@property (nonatomic,strong) IBOutlet UILabel * post_fee;
@property (nonatomic,strong) IBOutlet UILabel * payment;
@property (nonatomic,strong) IBOutlet UILabel * service_fee;
@end
