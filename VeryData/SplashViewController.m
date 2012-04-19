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

-(IBAction)going:(id)sender
{
    NSLog(@"%@",self.passField.text);
    if([self.passField.text isEqualToString:@"hoo"])
    {
        AppDelegate * delegate = [UIApplication sharedApplication].delegate;
        delegate.window.rootViewController = delegate.splitViewController;
    }
    else
        self.passField.text = @"";
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
	return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


@end
