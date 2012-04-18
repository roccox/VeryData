//
//  OrderCell.h
//  VeryData
//
//  Created by Rock on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderCell : UITableViewCell


@property (nonatomic,strong) IBOutlet UIImageView * image;
@property (nonatomic,strong) IBOutlet UILabel * title;
@property (nonatomic,strong) IBOutlet UILabel * sku;
@property (nonatomic,strong) IBOutlet UILabel * price;
@property (nonatomic,strong) IBOutlet UILabel * num;
@property (nonatomic,strong) IBOutlet UILabel * payment;
@property (nonatomic,strong) IBOutlet UILabel * discount_fee;
@property (nonatomic,strong) IBOutlet UILabel * adjust_fee;
@property (nonatomic,strong) IBOutlet UILabel * status;

@end
