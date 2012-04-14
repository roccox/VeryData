//
//  TopItemModel.m
//  VeryData
//
//  Created by Rock on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopItemModel.h"

@implementation TopItemModel

@synthesize num_iid,title,pic_url,price,volume,import_price;


-(void)print
{
    NSLog(@"Item: id-%qi,title-%@,pic_url-%@ \n",self.num_iid,self.title,self.pic_url);
    NSLog(@"Item: price-%f,title-%d,import_price-%f \n",self.price,self.volume,self.import_price);
}

@end
