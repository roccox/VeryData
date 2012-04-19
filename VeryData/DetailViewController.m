//
//  DetailViewController.m
//  VeryData
//
//  Created by Rock on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation DetailViewController

@synthesize masterPopoverController,waitingView,isBusy;

#pragma mark - Managing the detail item
-(void)settingPeriodFrom: (NSDate *)start to:(NSDate *) end withTag:(NSString *)tag
{

}

-(void)finishedEditPopover:(int)val withNote: (NSString *) note
{
    
}
-(NSString *) formatDouble:(double) val
{
    NSString * str = [[NSString alloc]initWithFormat:@"%6.2f",val];
    return str;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) showWaiting
{
    self.isBusy = YES;
    if(self.waitingView == nil)
    {
        CGRect frame = [self.view frame];
        self.waitingView = [[UIView alloc]initWithFrame:frame];

        UIActivityIndicatorView * cursor = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(260,300,150,150)];
        cursor.backgroundColor = [UIColor blackColor];
        [cursor setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        cursor.layer.cornerRadius = 10;
        cursor.layer.masksToBounds = YES;
        [cursor startAnimating];
        [self.waitingView addSubview:cursor];
    }
    if([self.waitingView superview] == nil)
        [self.view addSubview:waitingView];
}
-(void) hideWaiting
{
    self.isBusy = NO;
    if([self.waitingView superview] != nil)
        [self.waitingView removeFromSuperview];
}
#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isBusy = NO;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
