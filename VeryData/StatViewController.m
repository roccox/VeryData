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
- (void)calculate;
-(void)calFinished;
@end

@implementation StatViewController


@synthesize infoView,tradeList;
@synthesize startTime,endTime,trade,nextBtn,infoLabel;


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
    self.infoLabel.text = @"正在计算数据,请不要动......";
    self.infoView.scrollView.contentSize = CGSizeMake(703, 1280);
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
    if ([self.endTime timeIntervalSince1970] > [[[NSDate alloc]initWithTimeIntervalSinceNow:(8*60*60)] timeIntervalSince1970]) {
        self.nextBtn.enabled = NO;
    }
    else {
        self.nextBtn.enabled = YES;
    }
    

    [self showWaiting];
    
    self.infoLabel.text = @"正在计算数据,请不要动......";
    NSThread * thread = [[NSThread alloc]initWithTarget:self selector:@selector(calculate) object:nil];
    [thread start];
}

-(void)calFinished
{
    self.infoLabel.text = @"计算结束......";
    [self.infoView loadHTMLString:report baseURL:[[NSURL alloc]initWithString: @"http://localhost/"]];
    [self hideWaiting];

}
-(void)calculate
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
                          </TR>",[[from description] substringToIndex:10],[self formatDouble:sale],[self formatDouble:profit],[self formatDouble:rate]];
        report = [report stringByAppendingString:str];
        
        //add date
        from = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:from];
        to = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:to];
        
        totalSale += sale;
        totalProfit += profit;
        
        if([to timeIntervalSince1970]> [self.endTime timeIntervalSince1970])
            break;
    }
    //Add Total
    if(totalSale == 0)
        totalRate = 0;
    else {
        totalRate = totalProfit/totalSale;
    }
    NSString * str = [[NSString alloc]initWithFormat:@"<TR> \
                      <TD align=center color=#ff0000><font color=#ff0000>%@</font></TD><TD align=right color=#ff0000><font color=#ff0000>%@</font></TD><TD align=right color=#ff0000><font color=#ff0000>%@</font></TD><TD align=right color=#ff0000><font color=#ff0000>%@</font></TD> \
                      </TR>",@"总计",[self formatDouble:totalSale] ,[self formatDouble:totalProfit],[self formatDouble:totalRate]];
    report = [report stringByAppendingFormat:str];
    report = [report stringByAppendingString:@"</Table> \
              </BODY>\
              </HTML>"];
    

    [self performSelectorOnMainThread:@selector(calFinished) withObject:nil waitUntilDone:NO];
}

-(IBAction)goNext:(id)sender
{
    int count = 0;
    if([_tag isEqualToString:@"STAT_MONTH"])
    {
        NSDate * refDate = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:self.endTime];
        self.startTime = [DateHelper getFirstTimeOfMonth:refDate];
        count = [DateHelper getDayCountOfMonth:self.startTime];
        self.endTime = [[NSDate alloc]initWithTimeInterval:(count*24*60*60) sinceDate:self.startTime];
    }
    else if([_tag isEqualToString:@"STAT_YEAR"])    //TODO
    {
        /*
        self.startTime = [[NSDate alloc]initWithTimeInterval:(7*24*60*60) sinceDate:self.startTime];
        self.endTime = [[NSDate alloc]initWithTimeInterval:(7*24*60*60) sinceDate:self.endTime];
         */
    }
        
    [self configureView];
}

-(IBAction)goPrevious:(id)sender
{
    int count = 0;
    if([_tag isEqualToString:@"STAT_MONTH"])
    {
        NSDate * refDate = [[NSDate alloc]initWithTimeInterval:-(24*60*60) sinceDate:self.startTime];
        self.startTime = [DateHelper getFirstTimeOfMonth:refDate];
        count = [DateHelper getDayCountOfMonth:self.startTime];
        self.endTime = [[NSDate alloc]initWithTimeInterval:(count*24*60*60) sinceDate:self.startTime];
    }
    else if([_tag isEqualToString:@"STAT_YEAR"])    //TODO
    {
        /*
         self.startTime = [[NSDate alloc]initWithTimeInterval:(7*24*60*60) sinceDate:self.startTime];
         self.endTime = [[NSDate alloc]initWithTimeInterval:(7*24*60*60) sinceDate:self.endTime];
         */
    }
    
    [self configureView];
}

-(IBAction)goSomeDay:(id)sender
{
    
}

-(IBAction)reCal:(id)sender
{
    [self configureView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
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


