//
//  TopItemModel.h
//  VeryData
//
//  Created by Rock on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBase.h"


@interface TopItemModel : NSObject

@property (nonatomic) long long num_iid;
@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) NSString * pic_url;
@property (nonatomic) double price;
@property (nonatomic) int volume;
@property (nonatomic) int num;
@property (nonatomic) double import_price;
@property (nonatomic,strong) NSString * note;

-(void)print;
-(BOOL)save;
-(BOOL)saveWithoutVolume;
-(BOOL)saveImportPrice;

@end
