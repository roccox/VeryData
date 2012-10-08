//
//  DetailViewController.h
//  VeryData
//
//  Created by Rock on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

// Rock: 父类

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIView * waitingView;
@property (nonatomic) BOOL isBusy;

-(void)settingPeriodFrom: (NSDate *)start to:(NSDate *) end withTag:(NSString *)tag;

-(void)finishedEditPopover:(int)val withNote: (NSString *) note;
-(NSString *) formatDouble:(double) val;

-(void) showWaiting;
-(void) hideWaiting;
@end
