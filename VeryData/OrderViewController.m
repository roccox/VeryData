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

@synthesize nextBtn,infoLabel;

@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

-(void)settingPeriodFrom: (NSDate *)start to:(NSDate *) end withTag:(NSString *)tag
{
    if (_tag != tag) {
        _tag = tag;
        self.startTime = start;
        self.endTime = end;

        //get data
        TopData * topData = [TopData getTopData];
        tradeList = [topData getTradesFrom:startTime to:endTime];
        if(self.dataList == nil)
            self.dataList = [[NSMutableArray alloc]init];
        else {
            [self.dataList removeAllObjects];
        }
        
        for (TopTradeModel * _trade in tradeList) {
            [self.dataList addObject:_trade];
            for(TopOrderModel * order in _trade.orders){
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
    if ([self.endTime timeIntervalSince1970] > [[[NSDate alloc]initWithTimeIntervalSinceNow:(8*60*60)] timeIntervalSince1970]) {
        self.nextBtn.enabled = NO;
    }
    else {
        self.nextBtn.enabled = YES;
    }

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
        for(TopTradeModel * _trade in tradeList)
        {
            sale += [_trade getSales];
            profit += [_trade getProfit];
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
            for(TopTradeModel * _trade in tradeList)
            {
                NSLog(@"pay-%@",_trade.paymentTime);
                if(([_trade.paymentTime timeIntervalSince1970] < [dateS timeIntervalSince1970]) ||
                   ([_trade.paymentTime timeIntervalSince1970] > [dateE timeIntervalSince1970]))
                    continue;
                
                sale += [_trade getSales];
                profit += [_trade getProfit];
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
    topData.delegate = self;
    [topData refreshTrades];
}

#pragma - taobao
-(void) notifyItemRefresh:(BOOL)isFinished withTag:(NSString*) tag
{
    
}

-(void) notifyTradeRefresh:(BOOL)isFinished withTag:(NSString*) tag
{
    if(isFinished)
    {
        NSString * str = _tag;
        self.infoLabel.text = @"";
        _tag = @"";
        [self settingPeriodFrom:self.startTime to:self.endTime withTag:str];
    }
    else {
        self.infoLabel.text = tag;
    }
    
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * tradeID = @"tradeCellID";
    static NSString * orderID = @"orderCellID";
    id obj = [self.dataList objectAtIndex:indexPath.row];
    TopTradeModel * _trade;
    TopOrderModel * order;
    
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
        _trade = (TopTradeModel *)obj;
        cell.createdTime.text = [[NSString alloc]initWithFormat:@"购买:%@",[[_trade.createdTime description] substringToIndex:19]];
        cell.paymentTime.text = [[NSString alloc]initWithFormat:@"付款:%@",[[_trade.paymentTime description] substringToIndex:19]];
        if([_trade.status isEqualToString:@"WAIT_BUYER_PAY"])
            cell.status.text = @"等待买家付款";
        else if([_trade.status isEqualToString:@"WAIT_SELLER_SEND_GOODS"])
            cell.status.text = @"等待卖家发货";
        else if([_trade.status isEqualToString:@"WAIT_BUYER_CONFIRM_GOODS"])
            cell.status.text = @"等待买家确认收货";
        else if([_trade.status isEqualToString:@"TRADE_FINISHED"])
            cell.status.text = @"交易成功";
        else if([_trade.status isEqualToString:@"TRADE_CLOSED"])
            cell.status.text = @"交易关闭";
        else if([_trade.status isEqualToString:@"TRADE_CLOSED_BY_TAOBAO"])
            cell.status.text = @"交易被淘宝关闭";
        else
            cell.status.text = _trade.status;
        
        
        cell.buyer.text = [[NSString alloc]initWithFormat:@"买家:%@",_trade.buyer_nick];
        cell.rec.text = [[NSString alloc]initWithFormat:@"姓名:%@/%@",_trade.receiver_name,_trade.receiver_city];
        cell.note.text = [[NSString alloc]initWithFormat:@"备注:%@",_trade.note];
        cell.post_fee.text = [[NSString alloc]initWithFormat:@"邮费:%@",[NSNumber numberWithDouble: _trade.post_fee]];
        cell.payment.text = [[NSString alloc]initWithFormat:@"总价:%@",[NSNumber numberWithDouble: _trade.payment]];
        cell.service_fee.text = [[NSString alloc]initWithFormat:@"特别:%@",[NSNumber numberWithDouble: _trade.service_fee]];
        
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

        [cell.image setImageWithURL:[NSURL URLWithString:order.pic_url] placeholderImage:[UIImage imageNamed:@"hold.png"]];

        cell.title.text = [[NSString alloc]initWithFormat:@"%@",order.title];
        cell.sku.text = [[NSString alloc]initWithFormat:@"%@",order.sku_name];
        cell.price.text = [[NSString alloc]initWithFormat:@"单价:%@",[NSNumber numberWithDouble: order.price]];
        cell.num.text = [[NSString alloc]initWithFormat:@" * %@",[NSNumber numberWithInt: order.num]];
        cell.payment.text = [[NSString alloc]initWithFormat:@"总价:%@",[NSNumber numberWithDouble: order.payment]];
        cell.discount_fee.text = [[NSString alloc]initWithFormat:@"优惠:%@",[NSNumber numberWithDouble: order.discount_fee]];
        cell.adjust_fee.text = [[NSString alloc]initWithFormat:@"调整:%@",[NSNumber numberWithDouble: order.adjust_fee]];

        if([order.refund isEqualToString:@"WAIT_SELLER_AGREE"])
            cell.status.text = @"买家已经申请退款";
        else if([order.refund isEqualToString:@"WAIT_BUYER_RETURN_GOODS"])
            cell.status.text = @"卖家已经同意退款";
        else if([order.refund isEqualToString:@"WAIT_SELLER_CONFIRM_GOODS"])
            cell.status.text = @"买家已经退货";
        else if([order.refund isEqualToString:@"SELLER_REFUSE_BUYER"])
            cell.status.text = @"卖家拒绝退款";
        else if([order.refund isEqualToString:@"CLOSED"])
            cell.status.text = @"退款关闭";
        else if([order.refund isEqualToString:@"SUCCESS"])
            cell.status.text = @"退款成功";
        else
            cell.status.text = @"";
        
        return cell;
    }
	
//	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
//	[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100.f;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id obj = [self.dataList objectAtIndex:indexPath.row];
    if([obj isKindOfClass: [TopTradeModel class] ]) //if trade
    {        
        self.trade = [dataList objectAtIndex:indexPath.row];
    
        [self showEditPopover:self.trade.service_fee withNote:self.trade.note];
    }
}

-(void)showEditPopover:(int) val withNote:(NSString *) note
{
    EditController * popoverContent = [[EditController alloc]init];
    popoverContent.val = val;
    popoverContent.note = note;
    
    UIPopoverController * popoverController=[[UIPopoverController alloc]initWithContentViewController:popoverContent]; 
    popoverController.delegate = self;
    
    
    popoverContent.popController = popoverController;
    popoverContent.superController =self;
    
    //popover显示的大小 
    popoverController.popoverContentSize=CGSizeMake(320, 300); 
    
    //显示popover，告诉它是为一个矩形框设置popover 
    [popoverController presentPopoverFromRect:CGRectMake(0, 0, 704, 0) inView:self.view 
                     permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES]; 
}

-(void)finishedEditPopover:(int)val withNote:(NSString *)note
{
    self.trade.service_fee = val;
    self.trade.note = note;
    [self.trade saveServiceFee];
    [self configureView];
}

-(IBAction)goNext:(id)sender
{
    if([_tag isEqualToString:@"ORDER_DAY"])
    {
        self.startTime = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:self.startTime];
        self.endTime = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:self.endTime];
    }
    else if([_tag isEqualToString:@"ORDER_WEEK"])
    {
        self.startTime = [[NSDate alloc]initWithTimeInterval:(7*24*60*60) sinceDate:self.startTime];
        self.endTime = [[NSDate alloc]initWithTimeInterval:(7*24*60*60) sinceDate:self.endTime];
    }
    
    //get data
    TopData * topData = [TopData getTopData];
    tradeList = [topData getTradesFrom:startTime to:endTime];
    if(self.dataList == nil)
        self.dataList = [[NSMutableArray alloc]init];
    else {
        [self.dataList removeAllObjects];
    }
    
    for (TopTradeModel * _trade in tradeList) {
        [self.dataList addObject:_trade];
        for(TopOrderModel * order in _trade.orders){
            [self.dataList addObject:order];
        }
    }
    
    [self configureView];
}

-(IBAction)goPrevious:(id)sender
{
    if(!self.nextBtn.enabled)
        self.nextBtn.enabled = YES;
    
    if([_tag isEqualToString:@"ORDER_DAY"])
    {
        self.startTime = [[NSDate alloc]initWithTimeInterval:-(24*60*60) sinceDate:self.startTime];
        self.endTime = [[NSDate alloc]initWithTimeInterval:-(24*60*60) sinceDate:self.endTime];
    }
    else if([_tag isEqualToString:@"ORDER_WEEK"])
    {
        self.startTime = [[NSDate alloc]initWithTimeInterval:-(7*24*60*60) sinceDate:self.startTime];
        self.endTime = [[NSDate alloc]initWithTimeInterval:-(7*24*60*60) sinceDate:self.endTime];
    }
    
    //get data
    TopData * topData = [TopData getTopData];
    tradeList = [topData getTradesFrom:startTime to:endTime];
    if(self.dataList == nil)
        self.dataList = [[NSMutableArray alloc]init];
    else {
        [self.dataList removeAllObjects];
    }
    
    for (TopTradeModel * _trade in tradeList) {
        [self.dataList addObject:_trade];
        for(TopOrderModel * order in _trade.orders){
            [self.dataList addObject:order];
        }
    }
    
    [self configureView];
}

-(IBAction)goSomeDay:(id)sender
{
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.startTime = [DateHelper getBeginOfDay:[[NSDate alloc]initWithTimeIntervalSinceNow:(8*60*60)]];
    self.endTime = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:self.startTime];
    
    [self settingPeriodFrom:self.startTime to:self.endTime withTag:@"ORDER_DAY"];
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
