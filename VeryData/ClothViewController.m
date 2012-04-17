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

@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

-(void)settingPeriodFrom: (NSDate *)start to:(NSDate *) end withTag:(NSString *)tag
{
    if (_tag != tag) {
        _tag = tag;

        //get data
        TopData * topData = [TopData getTopData];
        NSMutableArray * items = [topData getItems];
        if(self.dataList == nil)
            self.dataList = [[NSMutableArray alloc]init];
        else {
            [self.dataList removeAllObjects];
        }
        
        for (TopItemModel * item in items) {
            [self.dataList addObject:item];
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


#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * itemID = @"itemCellID";
    TopItemModel *  item = [self.dataList objectAtIndex:indexPath.row];
    
    NSString * str;
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
        //        cell.image = ;
        cell.title.text = [[NSString alloc]initWithFormat:@"%@",item.title];
        cell.price.text = [[NSString alloc]initWithFormat:@"价格:%@",[NSNumber numberWithDouble: item.price]];
        cell.import_price.text = [[NSString alloc]initWithFormat:@"进价:%@",[NSNumber numberWithDouble: item.import_price]];
        cell.volume.text = [[NSString alloc]initWithFormat:@"最近卖出:%@",[NSNumber numberWithInt: item.volume]];
        
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
    popoverController.popoverContentSize=CGSizeMake(320, 300); 

    //显示popover，告诉它是为一个矩形框设置popover 
    [popoverController presentPopoverFromRect:CGRectMake(0, 0, 704, 0) inView:self.view 
                     permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES]; 
}

-(void)finishedEditPopover:(int)val withNote: (NSString *) note
{
    self.item.import_price = val;
    self.item.note = note;
    [self.item save];
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
    barButtonItem.title = @"设置2";//NSLocalizedString(@"Master", @"Master");
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
