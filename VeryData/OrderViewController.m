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
@synthesize startTime,endTime,obj;

@synthesize nextBtn,infoLabel,searchBtn;

@synthesize calPopController;

@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

-(void)settingPeriodFrom: (NSDate *)start to:(NSDate *) end withTag:(NSString *)tag
{
    if (_tag != tag) {
        _tag = tag;
        self.startTime = start;
        self.endTime = end;

        //get data
        [self getData];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
    //put data to view
}

-(void)getData
{
    [self showWaiting];
    
    NSThread * thread = [[NSThread alloc]initWithTarget:self selector:@selector(calculate) object:nil];
    [thread start];
}

-(void)calculate
{
    //get data
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
    
    //calculate report
    double sale = 0;
    double profit = 0;
    double rate = 0;
    
    //generate report
    report = @"<HTML> \
    <BODY> \
    <Table border = 1  bgcolor=#fffff0> \
    <TR > \
    <TD width=124 align=center>日期</TD><TD width=124 align=right>销售额</TD><TD width=124 align=right>利润额</TD><TD width=124 align=right>利润率</TD> \
    </TR>";
    
    if([_tag isEqualToString:@"ORDER_DAY"])
    {
        for(TopTradeModel * _trade in tradeList)
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
                          </TR>",[[self.startTime description] substringToIndex:10],[self formatDouble:sale],[self formatDouble:profit],[self formatDouble:rate]];
        /*
         NSString * str = [[NSString alloc]initWithFormat:@"<TR> \
         <TD align=center>%@</TD><TD align=right>%@</TD><TD align=right>%@</TD><TD align=right>%@</TD> \
         </TR>",[[self.startTime description] substringToIndex:10],[NSNumber numberWithDouble:sale] ,[NSNumber numberWithDouble:profit],[NSNumber numberWithDouble:rate]];
         */
        report = [report stringByAppendingString:str];
    }
    else if([_tag isEqualToString:@"ORDER_WEEK"])
    {
        double totalSale = 0;
        double totalProfit = 0;
        double totalRate = 0;
        
        NSDate * dateS = [[NSDate alloc]initWithTimeInterval:0 sinceDate:startTime];
        NSDate * dateE = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:dateS];
        for(int i=0;i<7;i++)
        {
            profit = 0;
            sale = 0;
            rate = 0;
            for(TopTradeModel * _trade in tradeList)
            {
                if(([_trade.createdTime timeIntervalSince1970] < [dateS timeIntervalSince1970]) ||
                   ([_trade.createdTime timeIntervalSince1970] > [dateE timeIntervalSince1970]))
                    continue;
                
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
                              </TR>",[[dateS description] substringToIndex:10],[self formatDouble:sale],[self formatDouble:profit],[self formatDouble:rate]];
            report = [report stringByAppendingString:str];
            
            //add date
            dateS = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:dateS];
            dateE = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:dateE];
            
            totalSale += sale;
            totalProfit += profit;
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
        
    }
    report = [report stringByAppendingString:@"</Table> \
              </BODY>\
              </HTML>"];    
    //back to main thread
    [self performSelectorOnMainThread:@selector(finishedCal) withObject:nil waitUntilDone:NO];
}

-(void)finishedCal
{
    [self hideWaiting];
    [self configureView];
}

- (void)configureView
{
    if([_tag isEqualToString:@"ORDER_DAY"])
    {
        if(!isFirstLoad)
        {
            CGRect frame = CGRectMake(0,44, 703,72);
            self.infoView.frame = frame;
        
            frame = CGRectMake(0,116,703,615);
            self.tableView.frame = frame;
        }
        else {
            isFirstLoad = NO;
        }
    }
    else if([_tag isEqualToString:@"ORDER_WEEK"])
    {
        CGRect frame = CGRectMake(0,44, 703,252);
        self.infoView.frame = frame;

        frame = CGRectMake(0,296,703,435);
        self.tableView.frame = frame;
    }
    
    
    if ([self.endTime timeIntervalSince1970] > [[[NSDate alloc]initWithTimeIntervalSinceNow:(8*60*60)] timeIntervalSince1970]) {
        self.nextBtn.enabled = NO;
    }
    else {
        self.nextBtn.enabled = YES;
    }


    [self.infoView loadHTMLString:report baseURL:[[NSURL alloc]initWithString: @"http://localhost/"]];
    // Update the user interface for the detail item.
//    [self.tableView reloadData];
    [self allTrades:self];

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
    self.infoLabel.text = @"更新中......";
    [self showWaiting];
    [topData refreshTrades];
}

#pragma - taobao
-(void) notifyItemRefresh:(BOOL)isFinished withTag:(NSString*) tag
{
    
}
-(void) notifyItemValidRefresh:(BOOL)isFinished withTag:(NSString *)tag
{
    NSLog(@"%@",tag);
    if(isFinished)
    {
        NSString * str = _tag;
        self.infoLabel.text = @"";
        _tag = @"";
        [self hideWaiting];
        [self settingPeriodFrom:self.startTime to:self.endTime withTag:str];
    }
}

-(void) notifyTradeRefresh:(BOOL)isFinished withTag:(NSString*) tag
{
    if(isFinished)
    {
        TopData * topData = [TopData getTopData];
        [topData valifiedItems];
    }
    else {
        self.infoLabel.text = tag;
    }
    
}

-(IBAction)allTrades:(id)sender
{
    int tradeCount = 0;
    int itemCount = 0;
    [self.dataList removeAllObjects];
    
    for (TopTradeModel * _trade in tradeList) {
        [self.dataList addObject:_trade];
        tradeCount++;

        for(TopOrderModel * order in _trade.orders){
            [self.dataList addObject:order];
            itemCount += order.num;
        }
    }

    [self.tableView reloadData];
    self.infoLabel.text = [[NSString alloc]initWithFormat:@"全:%d单%d件",tradeCount,itemCount];
}

-(IBAction)notPayTrades:(id)sender
{
    int tradeCount = 0;
    int itemCount = 0;
    double notPaySale = 0;
    [self.dataList removeAllObjects];
    
    for (TopTradeModel * _trade in tradeList) {
        if([_trade.status isEqualToString:@"WAIT_BUYER_PAY"])
        {
            [self.dataList addObject:_trade];
            tradeCount++;
            for(TopOrderModel * order in _trade.orders){
                [self.dataList addObject:order];
                itemCount += order.num;
                notPaySale += order.total_fee;
            }
        }
    }
    
    [self.tableView reloadData];    
    self.infoLabel.text = [[NSString alloc]initWithFormat:@"未:%d单%d件%4.2f元",tradeCount,itemCount,notPaySale];
}

-(IBAction)payTrades:(id)sender
{
    int tradeCount = 0;
    int itemCount = 0;
    [self.dataList removeAllObjects];
    
    for (TopTradeModel * _trade in tradeList) {
        if([_trade.status isEqualToString:@"WAIT_SELLER_SEND_GOODS"])
        {
            [self.dataList addObject:_trade];
            tradeCount++;
            
            for(TopOrderModel * order in _trade.orders){
                [self.dataList addObject:order];
                itemCount += order.num;
            }
        }
    }
    
    [self.tableView reloadData];    
    self.infoLabel.text = [[NSString alloc]initWithFormat:@"卖:%d单%d件",tradeCount,itemCount];
}

-(IBAction)sentTrades:(id)sender
{
    int tradeCount = 0;
    int itemCount = 0;
    [self.dataList removeAllObjects];
    
    for (TopTradeModel * _trade in tradeList) {
        if([_trade.status isEqualToString:@"WAIT_BUYER_CONFIRM_GOODS"])
        {
            [self.dataList addObject:_trade];
            tradeCount++;
            
            for(TopOrderModel * order in _trade.orders){
                [self.dataList addObject:order];
                itemCount += order.num;
            }
        }
    }
    
    [self.tableView reloadData];    
    self.infoLabel.text = [[NSString alloc]initWithFormat:@"发:%d单%d件",tradeCount,itemCount];
}
-(IBAction)closedTrades:(id)sender
{
    int tradeCount = 0;
    int itemCount = 0;
    [self.dataList removeAllObjects];
    
    for (TopTradeModel * _trade in tradeList) {
        if([_trade.status isEqualToString:@"TRADE_CLOSED_BY_TAOBAO"] ||
           [_trade.status isEqualToString:@"TRADE_CLOSED"])
        {
            [self.dataList addObject:_trade];
            tradeCount++;
            
            for(TopOrderModel * order in _trade.orders){
                [self.dataList addObject:order];
                itemCount += order.num;
            }
        }
    }
    
    [self.tableView reloadData];    
    self.infoLabel.text = [[NSString alloc]initWithFormat:@"关:%d单%d件",tradeCount,itemCount];
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
        if([_trade.paymentTime timeIntervalSince1970] <= [_trade.createdTime timeIntervalSince1970])
            cell.paymentTime.text = @"未付款";
        else
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
        cell.post_fee.text = [[NSString alloc]initWithFormat:@"邮费:%@",[self formatDouble: _trade.post_fee]];
        cell.payment.text = [[NSString alloc]initWithFormat:@"总价:%@",[self formatDouble: _trade.payment]];
        cell.service_fee.text = [[NSString alloc]initWithFormat:@"特别:%@",[self formatDouble: _trade.service_fee]];
        
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
        cell.price.text = [[NSString alloc]initWithFormat:@"单价:%@",[self formatDouble: order.price]];
        cell.num.text = [[NSString alloc]initWithFormat:@" * %@ - %@",[NSNumber numberWithInt: order.num],[NSNumber numberWithInt: order.refund_num]];
        cell.payment.text = [[NSString alloc]initWithFormat:@"总价:%@",[self formatDouble: order.total_fee]];
        cell.discount_fee.text = [[NSString alloc]initWithFormat:@"优惠:%@",[self formatDouble: order.discount_fee]];
        cell.adjust_fee.text = [[NSString alloc]initWithFormat:@"调整:%@",[self formatDouble: order.adjust_fee]];

        if([order.status isEqualToString:@"WAIT_BUYER_PAY"])
            cell.status.text = @"等待买家付款";
        else if([order.status isEqualToString:@"WAIT_SELLER_SEND_GOODS"])
            cell.status.text = @"等待卖家发货";
        else if([order.status isEqualToString:@"WAIT_BUYER_CONFIRM_GOODS"])
            cell.status.text = @"等待买家确认收货";
        else if([order.status isEqualToString:@"TRADE_FINISHED"])
            cell.status.text = @"交易成功";
        else if([order.status isEqualToString:@"TRADE_CLOSED"])
            cell.status.text = @"交易关闭";
        else if([order.status isEqualToString:@"TRADE_CLOSED_BY_TAOBAO"])
            cell.status.text = @"交易被淘宝关闭";
        else
            cell.status.text = order.status;
        
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
    TopTradeModel * trade;
    TopOrderModel * order;
    self.obj = [self.dataList objectAtIndex:indexPath.row];
    if([self.obj isKindOfClass: [TopTradeModel class] ]) //if trade
    {        
        trade = [dataList objectAtIndex:indexPath.row];
    
        [self showEditPopover:trade.service_fee withNote:trade.note];
    }
    else if ([self.obj isKindOfClass: [TopOrderModel class] ]) {
        order = [dataList objectAtIndex:indexPath.row];
        [self showEditPopover:order.refund_num withNote:@"REFUND-退货"];
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
    popoverController.popoverContentSize=CGSizeMake(280, 340); 
    
    //显示popover，告诉它是为一个矩形框设置popover 
    [popoverController presentPopoverFromRect:CGRectMake(0, 0, 704, 0) inView:self.view 
                     permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES]; 
}

-(void)finishedEditPopover:(int)val withNote:(NSString *)note
{
    TopTradeModel * trade;
    TopOrderModel * order;
    if([self.obj isKindOfClass: [TopTradeModel class] ]) //if trade
    {        
        trade = (TopTradeModel *)obj;
        
        trade.service_fee = val;
        trade.note = note;
        [trade saveServiceFee];
    }
    else if ([self.obj isKindOfClass: [TopOrderModel class] ]) {
        order = (TopOrderModel *) obj;
        if(val > order.num)
            return;
        
        order.refund_num = val;
        [order saveRefundNum];
    }
    
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

    [self getData];
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
    
    [self getData];
}

-(IBAction)goSomeDay:(id)sender
{
    [self showCal];
}

-(void)showCal
{
    NSDate * date = [[NSDate alloc]initWithTimeInterval:-(8*60*60) sinceDate:self.startTime];
    KalViewController * calendarController = [[KalViewController alloc]initWithSelectedDate:date];
    
    calPopController=[[UIPopoverController alloc]initWithContentViewController:calendarController]; 
    calPopController.delegate = self;
    
    calendarController.popController = calPopController;
    
    //popover显示的大小 
    calPopController.popoverContentSize=CGSizeMake(320, 260); 
    
    //显示popover，告诉它是为一个矩形框设置popover 
    
    [calPopController presentPopoverFromBarButtonItem:searchBtn permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//    [calPopController presentPopoverFromRect:searchBtn. inView:self.view 
//                     permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES]; 
}

-(void)hideCal
{
    [self.calPopController dismissPopoverAnimated:YES];
}

- (void)didSelectDate:(KalDate *)date
{
    [self hideCal];
    //
    NSDate * from;
    NSDate * to;
    from = [date NSDate];
    from = [[NSDate alloc]initWithTimeInterval:(8*60*60) sinceDate:from];
    if([_tag isEqualToString:@"ORDER_DAY"])
    {
        to = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:from];
    }
    else if([_tag isEqualToString:@"ORDER_WEEK"])
    {
        from = [DateHelper getFirstTimeOfWeek:from];
        to = [[NSDate alloc]initWithTimeInterval:(7*24*60*60) sinceDate:self.endTime];
    }
    
    if([from timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970])
    {
        self.startTime = from;
        self.endTime = to;
        [self getData];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstLoad = YES;
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
