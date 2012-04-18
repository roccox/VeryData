//
//  StatViewController.m
//  VeryData
//
//  Created by Rock on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StatViewController.h"
#import "TradeCell.h"
#import "OrderCell.h"

@interface StatViewController ()
- (void)configureView;
@end

@implementation StatViewController


@synthesize infoView,tradeList;
@synthesize startTime,endTime,trade,nextBtn;


@synthesize masterPopoverController = _masterPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.infoView.scrollView.contentSize = CGSizeMake(703, 1536);
    isFirstLoad = YES;
    if(report.length >10)
        [self.infoView loadHTMLString:report baseURL:[[NSURL alloc]initWithString: @"http://localhost/"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}




#pragma mark - Managing the detail item

-(void)settingPeriodFrom: (NSDate *)start to:(NSDate *) end withTag:(NSString *)tag
{
    if (_tag != tag) {
        _tag = tag;
        self.startTime = start;
        self.endTime = end;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    //Get Data
    TopData * topData = [TopData getTopData];
    //calculate report
    double sale = 0;
    double profit = 0;
    double rate = 0;
    double totalSale = 0;
    double totalProfit = 0;
    double totalRate = 0;
    
    //generate report
    report = @"<HTML> \
    <BODY> \
    <Table border = 1  bgcolor=#fffff0> \
    <TR > \
    <TD width=124 align=center>日期</TD><TD width=124 align=right>销售额</TD><TD width=124 align=right>利润额</TD><TD width=124 align=right>利润率</TD> \
    </TR>";
    NSDate * from = self.startTime;
    NSDate * to = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:from];
    for (; ; ) {

        self.tradeList = [topData getTradesFrom:from to:to];
        profit = 0;
        sale = 0;
        rate = 0;
        for(TopTradeModel * _trade in self.tradeList)
        {
            sale += [_trade getSales];
            profit += [_trade getProfit];
        }
        if(sale == 0)
            rate = 0;
        else {
            rate = profit/sale;
        }
        NSString * str = [[NSString alloc]initWithFormat:@"<TR> \
                              <TD align=center>%@</TD><TD align=right>%@</TD><TD align=right>%@</TD><TD align=right>%@</TD> \
                              </TR>",[[from description] substringToIndex:10],[NSNumber numberWithDouble:sale] ,[NSNumber numberWithDouble:profit],[NSNumber numberWithDouble:rate]];
        report = [report stringByAppendingString:str];
            
        //add date
        from = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:from];
        to = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:to];
        
        if([to timeIntervalSince1970]> [self.endTime timeIntervalSince1970])
            break;
    }
    report = [report stringByAppendingString:@"</Table> \
              </BODY>\
              </HTML>"];
    if(!isFirstLoad)
        [self.infoView loadHTMLString:report baseURL:[[NSURL alloc]initWithString: @"http://localhost/"]];
    else
        isFirstLoad = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


-(IBAction)goNext:(id)sender
{

}

-(IBAction)goPrevious:(id)sender
{

}

-(IBAction)goSomeDay:(id)sender
{
    
}

#pragma mark - View lifecycle


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"My First";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"设置";//NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


@end


