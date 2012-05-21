//
//  ItemCell.h
//  VeryData
//
//  Created by Rock on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UIImageView * image;
@property (nonatomic,strong) IBOutlet UILabel * title;
@property (nonatomic,strong) IBOutlet UILabel * price;
@property (nonatomic,strong) IBOutlet UILabel * sku;
@property (nonatomic,strong) IBOutlet UILabel * volume;
@property (nonatomic,strong) IBOutlet UILabel * import_price;

@end
