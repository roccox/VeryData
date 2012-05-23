//
//  DetailViewController.h
//  VeryData
//
//  Created by Rock on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewController.h"
#import "TopData.h"
#import "EditController.h"
#import "DateHelper.h"

#import "SDWebImageManagerDelegate.h"
#import "SDWebImageDownloaderDelegate.h"
#import "UIImageView+WebCache.h"

#import "Kal.h"
#import "KalDate.h"
#import "AppDelegate.h"

@interface OrderViewController : DetailViewController <UISplitViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,UIPopoverControllerDelegate,TaobaoDataDelegate>{

    NSString * _tag;
    BOOL    isFirstLoad;
    NSString * report;
}

@property (nonatomic,strong) IBOutlet UITableView * tableView;
@property (nonatomic,strong) IBOutlet UIWebView * infoView;
@property (nonatomic,strong) IBOutlet UILabel * infoLabel;

@property (nonatomic,strong) UIPopoverController * calPopController;

@property (nonatomic,strong) NSDate * startTime;
@property (nonatomic,strong) NSDate * endTime;

@property (nonatomic,strong) NSMutableArray * dataList;
@property (nonatomic,strong) NSMutableArray * tradeList;

@property (nonatomic,strong) id obj;

@property (nonatomic,strong) IBOutlet UIBarButtonItem * nextBtn;
@property (nonatomic,strong) IBOutlet UIBarButtonItem * searchBtn;

-(void)showEditPopover:(int) val withNote:(NSString *) note;

-(IBAction)updateData:(id)sender;
-(IBAction)goNext:(id)sender;
-(IBAction)goPrevious:(id)sender;
-(IBAction)goSomeDay:(id)sender;

-(IBAction)allTrades:(id)sender;
-(IBAction)notPayTrades:(id)sender;
-(IBAction)payTrades:(id)sender;
-(IBAction)sentTrades:(id)sender;
-(IBAction)closedTrades:(id)sender;

-(void)getData;
-(void)calculate;
-(void)finishedCal;

-(void)showCal;
-(void)hideCal;

- (void)didSelectDate:(KalDate *)date;
@end
