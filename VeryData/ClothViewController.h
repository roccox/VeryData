//
//  ClothViewController.h
//  VeryData
//
//  Created by Rock on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopData.h"
#import "EditController.h"

#import "DetailViewController.h"

#import "SDWebImageManagerDelegate.h"
#import "SDWebImageDownloaderDelegate.h"
#import "UIImageView+WebCache.h"

@interface ClothViewController : DetailViewController <UISplitViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,UIPopoverControllerDelegate,TaobaoDataDelegate>{
    
    NSString * _tag;

}

@property (nonatomic,strong) IBOutlet UITextField * searchField;

@property (nonatomic,strong) UIPopoverController * popController;

@property (nonatomic,strong) IBOutlet UITableView * tableView;

@property (nonatomic,strong) NSMutableArray * dataList;
@property (nonatomic,strong) NSMutableArray * itemList;

@property (nonatomic,strong) TopItemModel * item;

-(void)showEditPopover:(int) val withNote:(NSString * )note;

-(IBAction)showAllItems:(id)sender;
-(IBAction)showZeroItems:(id)sender;
-(IBAction)showSearchedItems:(id)sender;
-(IBAction)refreshData:(id)sender;

@end
