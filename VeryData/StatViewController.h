//
//  StatViewController.h
//  VeryData
//
//  Created by Rock on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"


#import "DetailViewController.h"
#import "TopData.h"
#import "EditController.h"
#import "DateHelper.h"

#import "SDWebImageManagerDelegate.h"
#import "SDWebImageDownloaderDelegate.h"
#import "UIImageView+WebCache.h"

@interface StatViewController : DetailViewController <UISplitViewControllerDelegate>{
    
    NSString * _tag;
    BOOL    isFirstLoad;
}

@property (nonatomic,strong) IBOutlet UIWebView * infoView;
@property (nonatomic,strong) IBOutlet UIBarButtonItem * nextBtn;
@property (nonatomic,strong) NSDate * startTime;
@property (nonatomic,strong) NSDate * endTime;

@property (nonatomic,strong) NSMutableArray * tradeList;

@property (nonatomic,strong) TopTradeModel * trade;


-(IBAction)goNext:(id)sender;
-(IBAction)goPrevious:(id)sender;
-(IBAction)goSomeDay:(id)sender;
@end
