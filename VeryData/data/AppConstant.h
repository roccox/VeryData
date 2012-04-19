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
@property(nonatomic,strong) NSString * session;
@property(nonatomic,strong) NSDate * session_time;

-(void)print;
-(BOOL)save;
-(BOOL)saveFetchTime;
+(AppConstant *)shareObject;
@end
