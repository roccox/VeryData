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

@synthesize tableView,infoView,dataList;
@synthesize startTime,endTime;

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
        NSMutableArray * trades = [topData getTradesFrom:startTime to:endTime];
        if(self.dataList == nil)
            self.dataList = [[NSMutableArray alloc]init];
        else {
            [self.dataList removeAllObjects];
        }
        
        for (TopTradeModel * trade in trades) {
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
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
