//
//  DateHelper.h
//  VeryData
//
//  Created by Rock on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateHelper : NSObject

+ (NSDate *)getBeginOfDay:(NSDate *) date;
+ (NSDate *) getFirstTimeOfWeek:(NSDate *) date;
+ (NSDate *) getFirstTimeOfMonth: (NSDate *) date;
+ (int) getDayCountOfMonth: (NSDate *) date;
@end
