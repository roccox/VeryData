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

@interface ClothViewController : DetailViewController <UISplitViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,UIPopoverControllerDelegate>{
    
    NSString * _tag;

}

@property (nonatomic,strong) UIPopoverController * popController;

@property (nonatomic,strong) IBOutlet UITableView * tableView;

@property (nonatomic,strong) NSMutableArray * dataList;

@property (nonatomic,strong) TopItemModel * item;

-(void)showEditPopover:(int) val;

@end
