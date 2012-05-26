//
//  DateHelper.m
//  VeryData
//
//  Created by Rock on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper

+ (NSDate *)getBeginOfDay:(NSDate *) date
{
    NSString * desc = [[date description]substringToIndex:11];
    desc = [desc stringByAppendingString:@"00:00:00"];

    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * reDate = [formatter dateFromString:desc];
    reDate = [[NSDate alloc]initWithTimeInterval:(8*60*60) sinceDate:reDate];
    return reDate;
}

+ (NSDate *) getFirstTimeOfWeek:(NSDate *) date
{
    NSDate * transDate = [[NSDate alloc]initWithTimeInterval:-(8*60*60) sinceDate:date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *beginningOfWeek = nil;
    [gregorian rangeOfUnit:NSWeekCalendarUnit startDate:&beginningOfWeek
                            interval:NULL forDate: transDate];
    
    beginningOfWeek = [[NSDate alloc]initWithTimeInterval:(8*60*60) sinceDate:beginningOfWeek];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * desc = [[beginningOfWeek description]substringToIndex:19];
    NSDate * reDate = [formatter dateFromString:desc];
    
    reDate = [[NSDate alloc]initWithTimeInterval:(8*60*60) sinceDate:reDate];

    return reDate;
}

+ (NSDate *) getFirstTimeOfMonth: (NSDate *) date
{
    NSString * desc = [[date description]substringToIndex:8];
    desc = [desc stringByAppendingString:@"01 00:00:00"];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * reDate = [formatter dateFromString:desc];
    reDate = [[NSDate alloc]initWithTimeInterval:(8*60*60) sinceDate:reDate];
    return reDate;    
}

+ (int) getDayCountOfMonth: (NSDate *) date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit
                                  forDate:date];
    return range.length;
}

@end
