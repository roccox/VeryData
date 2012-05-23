//
//  SplashViewController.m
//  VeryData
//
//  Created by Rock on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDelegate.h"
@interface SplashViewController ()

@end

@implementation SplashViewController
@synthesize passField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)startMonitor
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(passInput) name:UITextFieldTextDidChangeNotification  object:self.passField];
}

-(void)passInput
{
    if([self.passField.text isEqualToString:@"hoo"])
    {
        [self endMonitor];
        self.passField.text = @"";
        AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.splashController = self;
        delegate.window.rootViewController = delegate.splitViewController;
    }
}

-(void)endMonitor
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UITextFieldTextDidChangeNotification object:self.passField];
}

-(void)viewWillAppear:(BOOL)animated
{   
    [self startMonitor];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


@end
