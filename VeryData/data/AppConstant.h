//
//  AppConstant.h
//  VeryData
//
//  Created by Rock on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataBase.h"

@interface AppConstant : NSObject

@property(nonatomic,strong) NSDate * last_fetch;
-(void)print;
-(BOOL)save;
+(AppConstant *)shareObject;
@end
