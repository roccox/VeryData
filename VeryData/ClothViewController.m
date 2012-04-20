//
//  DetailViewController.m
//  VeryData
//
//  Created by Rock on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ClothViewController.h"
#import "ItemCell.h"

@interface ClothViewController ()
- (void)configureView;
@end

@implementation ClothViewController
@synthesize dataList,tableView,item,popController;
@synthesize searchField, itemList;

@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

-(void)settingPeriodFrom: (NSDate *)start to:(NSDate *) end withTag:(NSString *)tag
{
    if (_tag != tag) {
        _tag = tag;

        //get data
        TopData * topData = [TopData getTopData];
        if(self.itemList == nil)
            self.itemList = [[NSMutableArray alloc]init];
        else {
            [self.itemList removeAllObjects];
        }

        self.itemList = [topData getItems];
        
        if(self.dataList == nil)
            self.dataList = [[NSMutableArray alloc]init];
        else {
            [self.dataList removeAllObjects];
        }
        
        for (TopItemModel * _item in self.itemList) {
            [self.dataList addObject:_item];
            }

        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
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

-(IBAction)showAllItems:(id)sender
{
    [self.dataList removeAllObjects];
    for (TopItemModel * _item in self.itemList) {
        [self.dataList addObject: _item];
    }
    [self configureView];
}

-(IBAction)showZeroItems:(id)sender
{
    [self.dataList removeAllObjects];
    for (TopItemModel * _item in self.itemList) {
        if(_item.import_price < 0.01 && _item.import_price > -0.01)
            [self.dataList addObject: _item];
    }
    [self configureView];
}

-(IBAction)showSearchedItems:(id)sender
{
    [self.dataList removeAllObjects];
    for (TopItemModel * _item in self.itemList) {
        NSRange range = [_item.title rangeOfString:self.searchField.text];
        if(range.length > 0)
            [self.dataList addObject: _item];
    }
    [self.searchField resignFirstResponder];
    [self configureView];
}

-(IBAction)refreshData:(id)sender
{
    TopData * topData = [TopData getTopData];
    topData.delegate = self;
    self.searchField.text = @"更新中...";
    [self showWaiting];
    [topData refreshItems];
}

#pragma - taobao
-(void) notifyItemRefresh:(BOOL)isFinished withTag:(NSString*) tag
{
    if(isFinished)
    {
        //get data again
        //get data
        TopData * topData = [TopData getTopData];
        if(self.itemList == nil)
            self.itemList = [[NSMutableArray alloc]init];
        else {
            [self.itemList removeAllObjects];
        }
        
        self.itemList = [topData getItems];
        
        if(self.dataList == nil)
            self.dataList = [[NSMutableArray alloc]init];
        else {
            [self.dataList removeAllObjects];
        }
        
        for (TopItemModel * _item in self.itemList) {
            [self.dataList addObject:_item];
        }
        
        self.searchField.text = @"";
        [self hideWaiting];
        //relaod
        [self configureView];
    }
    else
        self.searchField.text = tag;
}

-(void) notifyTradeRefresh:(BOOL)isFinished withTag:(NSString*) tag
{
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * itemID = @"itemCellID";
    TopItemModel *  _item = [self.dataList objectAtIndex:indexPath.row];
    
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
        cell.price.text = [[NSString alloc]initWithFormat:@"价格:%@",[NSNumber numberWithDouble: _item.price]];
        cell.import_price.text = [[NSString alloc]initWithFormat:@"进价:%@",[NSNumber numberWithDouble: _item.import_price]];
        cell.volume.text = [[NSString alloc]initWithFormat:@"最近卖出:%@",[NSNumber numberWithInt: _item.volume]];
        
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100.f;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.item = [dataList objectAtIndex:indexPath.row];

    [self showEditPopover:self.item.import_price withNote:self.item.note];
}

-(void)showEditPopover:(int) val withNote:(NSString * )note
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

-(void)finishedEditPopover:(int)val withNote: (NSString *) note
{
    self.item.import_price = val;
    self.item.note = note;
    [self.item saveImportPrice];
    [self.tableView reloadData];
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
