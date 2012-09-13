//
//  webViewController.m
//  VeryData
//
//  Created by Rock on 12-9-13.
//
//

#import "WebViewController.h"

@interface WebController ()
- (void)configureView;
- (void)calculate;
-(void)calFinished;
@end

@implementation WebController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize webView;

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
    self.navigationItem.title = @"正在计算数据,请不要动......";
    self.webView.scrollView.contentSize = CGSizeMake(703, 1280);
    isFirstLoad = YES;
    UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rightBtn setTintColor: [UIColor grayColor]];
    
    CGRect frame = CGRectMake(10, 10, 100, 25);
    [rightBtn setFrame:frame];
    
    [rightBtn addTarget:self action:@selector(reCal) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"Refresh" forState:UIControlStateNormal];
    
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = barItem;
    if(report.length >10)
        [self.webView loadHTMLString:report baseURL:[[NSURL alloc]initWithString: @"http://localhost/"]];
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
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    [self showWaiting];
    
    self.navigationItem.title = @"正在计算数据,请不要动......";
    NSThread * thread = [[NSThread alloc]initWithTarget:self selector:@selector(calculate) object:nil];
    [thread start];
}

-(void)calFinished
{
    self.navigationItem.title = @"计算结束......";
    [self.webView loadHTMLString:report baseURL:[[NSURL alloc]initWithString: @"http://localhost/"]];
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
    NSString * header = @"<HTML> \
    <BODY> \
    <Table border = 1  bgcolor=#fffff0> \
    <TR > \
    <TD width=124 align=center>日期</TD><TD width=124 align=right>待确认金额</TD></TR>";
    
    report = @"";
    
        self.tradeList = [topData getUnConfirmedTrades];
        double money = 0;
        double totalMoney = 0;
        int i = 0;

        NSDate * day;
        NSDate * tmpDate;
        for(TopTradeModel * _trade in self.tradeList)
        {
            _trade.paymentTime = [[NSDate alloc]initWithTimeInterval:(-8*60*60) sinceDate:_trade.paymentTime];

            tmpDate = [DateHelper getBeginOfDay:_trade.paymentTime];
            
            if(day == NULL)
                day = [DateHelper getBeginOfDay:_trade.paymentTime];

            
            NSString * str;
            if([tmpDate compare:day] != NSOrderedSame)
            {
                day = NULL;
                str = [[NSString alloc]initWithFormat:@"<TR> \
                                  <TD align=center><font color=#0000ff>%@</font></TD><TD align=right><font color=#0000ff>%@</font></TD> \
                                  </TR>",@"=======",[self formatDouble:money]];
                report = [report stringByAppendingString:str];
                
                money = 0;
            }

            money += _trade.payment;
            totalMoney += _trade.payment;
            str = [[NSString alloc]initWithFormat:@"<TR> \
                              <TD align=center>%@</TD><TD align=right>%@</TD> \
                              </TR>",[[_trade.paymentTime description] substringToIndex:10],[self formatDouble:_trade.payment]];
            report = [report stringByAppendingString:str];
            
        }
        
    
    NSString * str = [[NSString alloc]initWithFormat:@"<TR> \
                      <TD align=center color=#ff0000><font color=#ff0000>%@</font></TD><TD align=right color=#ff0000><font color=#ff0000>%@</font></TD> \
                      </TR>",@"总计",[self formatDouble:totalMoney]];
    
    header = [header stringByAppendingFormat:str];
    report = [header stringByAppendingFormat:report];
    report = [report stringByAppendingString:@"</Table> \
              </BODY>\
              </HTML>"];
    
    
    [self performSelectorOnMainThread:@selector(calFinished) withObject:nil waitUntilDone:NO];
}


-(IBAction)reCal
{
    [self configureView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
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






