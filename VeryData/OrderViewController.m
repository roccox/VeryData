//
//  DetailViewController.m
//  VeryData
//
//  Created by Rock on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OrderViewController.h"
#import "TradeCell.h"
#import "OrderCell.h"

@interface OrderViewController ()
- (void)configureView;
@end

@implementation OrderViewController

@synthesize tableView,infoView,dataList,tradeList;
@synthesize startTime,endTime,trade;

@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

-(void)settingPeriodFrom: (NSDate *)start to:(NSDate *) end withTag:(NSString *)tag
{
    if (_tag != tag) {
        _tag = tag;
        startTime = start;
        endTime = end;
        
        //get data
        TopData * topData = [TopData getTopData];
        tradeList = [topData getTradesFrom:startTime to:endTime];
        if(self.dataList == nil)
            self.dataList = [[NSMutableArray alloc]init];
        else {
            [self.dataList removeAllObjects];
        }
        
        for (TopTradeModel * trade in tradeList) {
            [self.dataList addObject:trade];
            for(TopOrderModel * order in trade.orders){
                [self.dataList addObject:order];
            }
        }
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
    //put data to view
}

- (void)configureView
{
    // Update the user interface for the detail item.
    [self.tableView reloadData];
    //calculate report
    double sale = 0;
    double profit = 0;
    double rate = 0;
    
    //generate report
    NSString * report = @"<HTML> \
                            <BODY> \
                                <Table> \
                                <TR> \
                                <TD>日期</TD><TD>销售额</TD><TD>利润额</TD><TD>利润率</TD> \
                                </TR>";

    if([_tag isEqualToString:@"ORDER_DAY"])
    {
        for(TopTradeModel * trade in tradeList)
        {
            sale += [trade getSales];
            profit += [trade getProfit];
            if(sale == 0)
                rate = 0;
            else {
                rate = profit/sale;
            }
        }
        NSString * str = [[NSString alloc]initWithFormat:@"<TR> \
                             <TD>%@</TD><TD>%@</TD><TD>%@</TD><TD>%@</TD> \
                             </TR>",[[self.startTime description] substringToIndex:10],[NSNumber numberWithDouble:sale] ,[NSNumber numberWithDouble:profit],[NSNumber numberWithDouble:rate]];
        report = [report stringByAppendingString:str];
    }
    else if([_tag isEqualToString:@"ORDER_WEEK"])
    {
        NSDate * dateS = [[NSDate alloc]initWithTimeInterval:0 sinceDate:startTime];
        NSDate * dateE = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:dateS];
        for(int i=0;i<7;i++)
        {
            profit = 0;
            sale = 0;
            rate = 0;
            for(TopTradeModel * trade in tradeList)
            {
                NSLog(@"pay-%@",trade.paymentTime);
                if(([trade.paymentTime timeIntervalSince1970] < [dateS timeIntervalSince1970]) ||
                   ([trade.paymentTime timeIntervalSince1970] > [dateE timeIntervalSince1970]))
                    continue;
                
                sale += [trade getSales];
                profit += [trade getProfit];
                if(sale == 0)
                    rate = 0;
                else {
                    rate = profit/sale;
                }
            }
            NSString * str = [[NSString alloc]initWithFormat:@"<TR> \
                              <TD>%@</TD><TD>%@</TD><TD>%@</TD><TD>%@</TD> \
                              </TR>",[[dateS description] substringToIndex:10],[NSNumber numberWithDouble:sale] ,[NSNumber numberWithDouble:profit],[NSNumber numberWithDouble:rate]];
            report = [report stringByAppendingString:str];
        
            //add date
            dateS = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:dateS];
            dateE = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:dateE];

        }
    }
    report = [report stringByAppendingString:@"</Table> \
              </BODY>\
              </HTML>"];
    [self.infoView loadHTMLString:report baseURL:[[NSURL alloc]initWithString: @"http://localhost/"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction)updateData:(id)sender
{
    TopData * topData = [TopData getTopData];
    [topData refreshTrades];
}

#pragma - taobao
-(void) notifyItemRefresh:(BOOL)isFinished withTag:(NSString*) tag
{
    
}

-(void) notifyTradeRefresh:(BOOL)isFinished withTag:(NSString*) tag
{
    if(isFinished)
        [self configureView];
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * tradeID = @"tradeCellID";
    static NSString * orderID = @"orderCellID";
    id obj = [self.dataList objectAtIndex:indexPath.row];
    TopTradeModel * trade;
    TopOrderModel * order;
    
    NSString * str;
    if([obj isKindOfClass: [TopTradeModel class] ]) //if trade
    {
        TradeCell * cell = (TradeCell *)[self.tableView dequeueReusableCellWithIdentifier:tradeID];

        if(!cell)
        {
            NSArray *objs=[[NSBundle mainBundle] loadNibNamed:@"TradeCell" owner:self options:nil];
            for(id obj in objs)
            {
                if([obj isKindOfClass:[TradeCell class]])
                {
                    cell=(TradeCell *)obj;
                }
            }
        }

        //start to 
        trade = (TopTradeModel *)obj;
//        cell.image = ;
        cell.createdTime.text = [[NSString alloc]initWithFormat:@"购买时间:%@",trade.createdTime];
        cell.paymentTime.text = [[NSString alloc]initWithFormat:@"付款时间:%@",trade.paymentTime];
        cell.status.text = [[NSString alloc]initWithFormat:@"订单状态:%@",trade.status];
        cell.buyer.text = [[NSString alloc]initWithFormat:@"买家:%@",trade.buyer_nick];
        cell.rec_name.text = [[NSString alloc]initWithFormat:@"姓名:%@",trade.receiver_name];
        cell.rec_city.text = [[NSString alloc]initWithFormat:@"城市:%@",trade.receiver_city];
        cell.post_fee.text = [[NSString alloc]initWithFormat:@"邮费:%@",[NSNumber numberWithDouble: trade.post_fee]];
        cell.payment.text = [[NSString alloc]initWithFormat:@"总价:%@",[NSNumber numberWithDouble: trade.payment]];
        cell.service_fee.text = [[NSString alloc]initWithFormat:@"特别:%@",[NSNumber numberWithDouble: trade.service_fee]];
        
        return cell;
    }
    else    //orders
    {
        OrderCell * cell = (OrderCell *)[self.tableView dequeueReusableCellWithIdentifier:orderID];
        
        if(!cell)
        {
            NSArray *objs=[[NSBundle mainBundle] loadNibNamed:@"OrderCell" owner:self options:nil];
            for(id obj in objs)
            {
                if([obj isKindOfClass:[OrderCell class]])
                {
                    cell=(OrderCell *)obj;
                }
            }
        }
        
        //start to 
        order = (TopOrderModel *)obj;
        //        cell.image = ;
        cell.title.text = [[NSString alloc]initWithFormat:@"%@",order.title];
        cell.sku.text = [[NSString alloc]initWithFormat:@"%@",order.sku_name];
        cell.price.text = [[NSString alloc]initWithFormat:@"单价:%@",[NSNumber numberWithDouble: order.price]];
        cell.num.text = [[NSString alloc]initWithFormat:@" * %@",[NSNumber numberWithInt: order.num]];
        cell.payment.text = [[NSString alloc]initWithFormat:@"总价:%@",[NSNumber numberWithDouble: order.payment]];
        cell.discount_fee.text = [[NSString alloc]initWithFormat:@"优惠:%@",[NSNumber numberWithDouble: order.discount_fee]];
        cell.adjust_fee.text = [[NSString alloc]initWithFormat:@"调整:%@",[NSNumber numberWithDouble: order.adjust_fee]];
        
        return cell;
    }
	
//	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
//	[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 150.f;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id obj = [self.dataList objectAtIndex:indexPath.row];
    if([obj isKindOfClass: [TopTradeModel class] ]) //if trade
    {        
        self.trade = [dataList objectAtIndex:indexPath.row];
    
        [self showEditPopover:self.trade.service_fee];
    }
}

-(void)showEditPopover:(int) val
{
    EditController * popoverContent = [[EditController alloc]init];
    popoverContent.val = val;
    UIPopoverController * popoverController=[[UIPopoverController alloc]initWithContentViewController:popoverContent]; 
    popoverController.delegate = self;
    
    
    popoverContent.popController = popoverController;
    popoverContent.superController =self;
    
    //popover显示的大小 
    popoverController.popoverContentSize=CGSizeMake(320, 320); 
    
    //显示popover，告诉它是为一个矩形框设置popover 
    [popoverController presentPopoverFromRect:CGRectMake(0, 0, 704, 0) inView:self.view 
                     permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES]; 
}

-(void)finishedEditPopover:(int)val
{
    self.trade.service_fee = val;
    [self.trade save];
    [self configureView];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"设置1";//NSLocalizedString(@"Master", @"Master");
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
