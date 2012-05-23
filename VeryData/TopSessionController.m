//
//  TopSessionController.m
//  VeryData
//
//  Created by Rock on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopSessionController.h"
#import "AppDelegate.h"
#import "Constants.h"

@implementation TopSessionController

@synthesize webView;

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

#pragma mark - View lifecycle
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSURL *newURL=[self.webView.request URL];
    NSString *urlString=[newURL absoluteString];
    NSRange range=[urlString rangeOfString:@"top_session"];
    if(range.location<1000)
    {
        self.webView.alpha=0.0f;
        NSString *url=[urlString substringFromIndex:range.location];
        url=[url substringFromIndex:12];
        
        NSRange subRange=[url rangeOfString:@"&"];
        NSString *sessionKey=[url substringToIndex:subRange.location];
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.topSession = sessionKey;

        [appDelegate hideSessionCtrl];
    }
}

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
    //load url
    self.webView.alpha=1.0f;
    
    NSURL *url=[NSURL URLWithString:LOGINURL];
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url];
    self.webView.scalesPageToFit=YES;
    self.webView.delegate=self;
    [self.webView loadRequest:theRequest];    
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
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

@end
