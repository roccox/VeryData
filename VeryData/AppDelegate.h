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
#import "TopSessionController.h"
#import "TopData.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,TaobaoDataDelegate>
{
    NSString * topSession;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController * curController;
@property (strong, nonatomic) UINavigationController * orderController;
@property (strong, nonatomic) UINavigationController * clothController;

@property(strong,nonatomic) DateSelController * dateSelController;

@property(strong,nonatomic) TopSessionController * sessionController;

@property(strong,nonatomic) NSString * topSession;

- (void) setNewDetailControllerWithTag: (NSString *) tag;

-(void) showDateSel;
-(void)hideDateSel;
-(void)selectedDate;
-(void) showSessionCtrl;
-(void) hideSessionCtrl;

@end
