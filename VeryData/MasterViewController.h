//
//  MasterViewController.h
//  VeryData
//
//  Created by Rock on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) OrderViewController *detailViewController;


@end
