//
//  StatViewController.h
//  VeryData
//
//  Created by Rock on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

// Rock:月度分析和统计

#import "DetailViewController.h"

#import "TopData.h"
#import "DateHelper.h"


@interface StatViewController : DetailViewController <UISplitViewControllerDelegate>{
    
    NSString * _tag;
    BOOL    isFirstLoad;
    NSString * report;
}

@property (nonatomic,strong) IBOutlet UIWebView * infoView;
@property (nonatomic,strong) IBOutlet UIBarButtonItem * nextBtn;
@property (nonatomic,strong) IBOutlet UILabel * infoLabel;
@property (nonatomic,strong) NSDate * startTime;
@property (nonatomic,strong) NSDate * endTime;

@property (nonatomic,strong) NSMutableArray * tradeList;

@property (nonatomic,strong) TopTradeModel * trade;


-(IBAction)goNext:(id)sender;
-(IBAction)goPrevious:(id)sender;
-(IBAction)goSomeDay:(id)sender;

-(IBAction)reCal:(id)sender;
@end
