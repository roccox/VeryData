//
//  SentViewController.m
//  VeryData
//
//  Created by peng Jin on 12-5-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SentViewController.h"
#import "ItemCell.h"

@interface SentViewController ()
- (void)configureView;
- (void)calculate;
-(void)calFinished;
@end

@implementation SentViewController

@synthesize popController,tableView,dataList,itemList,infoLabel,startTime,endTime;

@synthesize masterPopoverController = _masterPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)settingPeriodFrom: (NSDate *)start to:(NSDate *) end withTag:(NSString *)tag
{
    if (1) {
//        _tag = tag;
        

        self.startTime = start;
        self.endTime = end;
        [self showWaiting];
        
        self.infoLabel.text = @"正在计算数据,请不要动......";
        NSThread * thread = [[NSThread alloc]initWithTarget:self selector:@selector(calculate) object:nil];
        [thread start];
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

-(void)calFinished
{
    [self hideWaiting];    
    self.infoLabel.text = @"计算结束......";
    [self configureView];
}

-(void)calculate
{
    //get data
    TopData * topData = [TopData getTopData];
    if(self.dataList == nil)
        self.dataList = [[NSMutableArray alloc]init];
    else {
        [self.dataList removeAllObjects];
    }
    if(self.itemList == nil)
        self.itemList = [[NSMutableArray alloc]init];
    else {
        [self.itemList removeAllObjects];
    }

    //get trade and orders
//    NSMutableArray * tradeList = [topData getTradesFrom:self.startTime to:self.endTime];
    NSMutableArray * tradeList = [topData getUnSentTrades];
    
    for (TopTradeModel * _trade in tradeList) {
        if([_trade.status isEqualToString:@"WAIT_SELLER_SEND_GOODS"])
            for(TopOrderModel * order in _trade.orders){
                [self.dataList addObject:order];
            }
    }
    //convert to items
    TopOrderModel * order;
    TopItemModel * item;
    BOOL found = NO;
    for(int i=0;i<[dataList count];i++)
    {
        found = NO;
        order = (TopOrderModel *) [dataList objectAtIndex:i];
        for (TopItemModel * _item in itemList) {
            if(order.num_iid == _item.num_iid && [order.sku_name isEqualToString:_item.note])
            {
                _item.volume += order.num;
                [dataList removeObjectAtIndex:i];
                i--;
                found = YES;
            }
        }
        
        //not found
        if(!found)
        {
            item = [[TopItemModel alloc]init];
            item.num_iid = order.num_iid;
            item.title = order.title;
            item.volume = order.num;
            item.price = order.price;
            item.import_price = order.import_price;
            item.pic_url = order.pic_url;
            item.note = order.sku_name;
            [itemList addObject:item];
        }
    }
    
    //re-order items
    TopItemModel * item2;
    for(int i=0;i<[itemList count];i++)
    {
        item = (TopItemModel *) [itemList objectAtIndex:i];
        for (int j=i+2;j<[itemList count];j++){
            item2 = (TopItemModel *) [itemList objectAtIndex:j];
            if(item.num_iid == item2.num_iid)
            {
                [itemList exchangeObjectAtIndex:i+1 withObjectAtIndex:j];
                break;  //break 
            }
        }
    }

    [self performSelectorOnMainThread:@selector(calFinished) withObject:nil waitUntilDone:NO];
}
- (void)configureView
{
    // Update the user interface for the detail item.
    
    //cal item count;
    int itemCount = 0;
    for (TopItemModel * _item in itemList) {
        itemCount += _item.volume;
    }
    self.infoLabel.text = [[NSString alloc]initWithFormat:@"%d",itemCount];  
    [self.tableView reloadData];
}


#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.itemList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * itemID = @"itemCellID";
    TopItemModel *  _item = [self.itemList objectAtIndex:indexPath.row];
    
    {
        ItemCell * cell = (ItemCell *)[self.tableView dequeueReusableCellWithIdentifier:itemID];
        
        if(!cell)
        {
            NSArray *objs=[[NSBundle mainBundle] loadNibNamed:@"ItemCell" owner:self options:nil];
            for(id obj in objs)
            {
                if([obj isKindOfClass:[ItemCell class]])
                {
                    cell=(ItemCell *)obj;
                }
            }
        }
        
        //start to 
        [cell.image setImageWithURL:[NSURL URLWithString:_item.pic_url] placeholderImage:[UIImage imageNamed:@"hold.png"]];
        cell.title.text = [[NSString alloc]initWithFormat:@"%@",_item.title];
        cell.sku.text = _item.note;
        cell.price.text = [[NSString alloc]initWithFormat:@"价格:%@",[NSNumber numberWithDouble: _item.price]];
        cell.import_price.text = [[NSString alloc]initWithFormat:@"进价:%@",[NSNumber numberWithDouble: _item.import_price]];
        cell.volume.text = [[NSString alloc]initWithFormat:@"数量:%@",[NSNumber numberWithInt: _item.volume]];
        
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100.f;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    [self configureView];
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
    self.title = @"My Second";
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
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
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
