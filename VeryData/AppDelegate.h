//
//  AppDelegate.h
//  VeryData
//
//  Created by Rock on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewController.h"
#import "DateSelController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController * curController;
@property (strong, nonatomic) UINavigationController * orderController;
@property (strong, nonatomic) UINavigationController * clothController;

@property(strong,nonatomic) DateSelController * dateSelController;

- (void) setNewDetailControllerWithTag: (NSString *) tag;

-(void) showDateSel;
-(void)hideDateSel;
-(void)selectedDate;
@end
