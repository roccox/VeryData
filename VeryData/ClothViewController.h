//
//  ClothViewController.h
//  VeryData
//
//  Created by Rock on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewController.h"

@interface ClothViewController : DetailViewController <UISplitViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSString * _tag;
}



@end
