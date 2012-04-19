//
//  AppDelegate.m
//  VeryData
//
//  Created by Rock on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "OrderViewController.h"
#import "ClothViewController.h"
#import "SplashViewController.h"

#import "TopData.h"

@implementation AppDelegate

@synthesize orderController,clothController,statController,splitViewController;

@synthesize dateSelController,sessionController,topSession;

@synthesize window = _window;

#pragma test delegate for taobao
-(void) notifyItemRefresh:(BOOL)isFinished withTag:(NSString*) tag
{
    NSLog(@"%@",tag);
}
-(void) notifyTradeRefresh:(BOOL)isFinished withTag:(NSString*) tag
{
    NSLog(@"%@",tag);

}

-(void)setTopSession:(NSString *)session
{
    topSession = session;
    [[TopData getTopData] putSession:topSession];
}
- (void) setNewDetailControllerWithTag: (NSString *) tag
{
    UISplitViewController * splitCtrl = (UISplitViewController *)self.window.rootViewController;
    
    UINavigationController * curController = [splitCtrl.viewControllers lastObject];
    DetailViewController * curDetailCtroller = curController.topViewController;
    
    UINavigationController* detailRootController = orderController;
    
    NSDate * from = [[NSDate alloc]initWithTimeIntervalSinceNow:(8*60*60)];
    NSDate * to = [[NSDate alloc]initWithTimeIntervalSinceNow:(8*60*60)];

    NSLog(@"%@",from);
    NSLog(@"%@",to);

    NSLog(@"-------------------");
    
    if(curDetailCtroller.isBusy)
        return;
    
    if([tag hasPrefix:@"ORDER"])        //单日或单周
    {
        detailRootController = orderController;
        if( [tag isEqualToString:@"ORDER_DAY"])
        {
            from = [DateHelper getBeginOfDay:from];
            to  = [[NSDate alloc]initWithTimeInterval:(24*60*60) sinceDate:from];
        }
        else if( [tag isEqualToString:@"ORDER_WEEK"])
        {
            from = [DateHelper getFirstTimeOfWeek:from];
            to = [[NSDate alloc]initWithTimeInterval:(7*24*60*60) sinceDate:from];
        }
    }
    else if([tag hasPrefix:@"STAT"])   //月度或年度
    {
        detailRootController = statController;
        if( [tag isEqualToString:@"STAT_MONTH"])
        {
            from = [DateHelper getFirstTimeOfMonth:from];
            int dayCount = [DateHelper getDayCountOfMonth:from];
            to = [[NSDate alloc]initWithTimeInterval:(dayCount*24*60*60) sinceDate:from];
            
        }
        else if( [tag isEqualToString:@"STAT_YEAR"])
        {
            
        }
    }
    else if([tag hasPrefix:@"CLOTH"])   //商品
    {
        detailRootController = clothController;
    }
    DetailViewController* detailController = detailRootController.topViewController;

    NSLog(@"%@",from);
    NSLog(@"%@",to);

    if(detailController != curDetailCtroller)
    {
        // swap button in detail controller
        UINavigationItem * navItem = [curDetailCtroller.navigationItem leftBarButtonItem];
        UIPopoverController * masterPopCtrl = curDetailCtroller.masterPopoverController;
        
        [curDetailCtroller.navigationItem setLeftBarButtonItem:nil animated:NO];
        curDetailCtroller = detailController;
        [curDetailCtroller.navigationItem setLeftBarButtonItem:navItem animated:NO];
        
        // update controllers in splitview
        UINavigationController* leftController = [splitCtrl.viewControllers objectAtIndex:0];
        splitCtrl.viewControllers = [NSArray arrayWithObjects:leftController,detailRootController, nil];
        
        // replace the passthrough views with current detail navigationbar
        curDetailCtroller.masterPopoverController = masterPopCtrl;
        
        if([masterPopCtrl isPopoverVisible]){
            masterPopCtrl.passthroughViews = [NSArray arrayWithObject:detailRootController.navigationBar];
        }
        
        splitCtrl.delegate = (id)curDetailCtroller;
    } 
    //test only
    
    [curDetailCtroller settingPeriodFrom:from to:to withTag:tag];
    
}

-(void)showDateSel
{
    self.dateSelController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.dateSelController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
 
    UISplitViewController * splitCtrl = (UISplitViewController *)self.window.rootViewController;
    
    [splitCtrl presentModalViewController:self.dateSelController animated:YES];

}

-(void)refreshSession
{
    [self showSessionCtrl];   
}

-(void)showSessionCtrl
{
    self.sessionController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.sessionController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    UISplitViewController * splitCtrl = (UISplitViewController *)self.window.rootViewController;
    
    [splitCtrl presentModalViewController:self.sessionController animated:YES];
}

-(void)hideSessionCtrl
{
    UISplitViewController * splitCtrl = (UISplitViewController *)self.window.rootViewController;
    
    [splitCtrl dismissModalViewControllerAnimated:YES];
}


-(void)hideDateSel
{
    UISplitViewController * splitCtrl = (UISplitViewController *)self.window.rootViewController;
    
    [splitCtrl dismissModalViewControllerAnimated:YES];
}

-(void)selectedDate
{
    
    UISplitViewController * splitCtrl = (UISplitViewController *)self.window.rootViewController;
    
    [splitCtrl dismissModalViewControllerAnimated:YES];    
    
    [self setNewDetailControllerWithTag:@"ORDER_PERIOD_OK"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    SplashViewController * rootController = (SplashViewController *) self.window.rootViewController;
    
    splitViewController = [rootController.storyboard instantiateViewControllerWithIdentifier:@"splitCtrl"];
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)navigationController.topViewController;

    //Rock
    orderController = navigationController;
    clothController = [splitViewController.storyboard instantiateViewControllerWithIdentifier:@"clothCtrl"];
    
    dateSelController = [splitViewController.storyboard instantiateViewControllerWithIdentifier:@"dateSelCtrl"];
    
    sessionController = [splitViewController.storyboard instantiateViewControllerWithIdentifier:@"sessionCtrl"];

    statController = [splitViewController.storyboard instantiateViewControllerWithIdentifier:@"statCtrl"];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
