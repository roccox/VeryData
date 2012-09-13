//
//  webViewController.h
//  VeryData
//
//  Created by Rock on 12-9-13.
//
//

#import <UIKit/UIKit.h>

#import "TopData.h"
#import "DateHelper.h"
#import "DetailViewController.h"

@interface WebController  : DetailViewController <UISplitViewControllerDelegate,TaobaoDataDelegate>{
    
    NSString * _tag;
    BOOL    isFirstLoad;
    NSString * report;
}

-(IBAction)reCal;

@property (nonatomic,strong) IBOutlet UIWebView * webView;

@property (nonatomic,strong) NSMutableArray * tradeList;

@property (nonatomic,strong) TopTradeModel * trade;

@end