//
//  EditController.m
//  VeryData
//
//  Created by Rock on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EditController.h"

@interface EditController ()

@end

@implementation EditController
@synthesize picker,val,valid,button,superController,popController,titleLabel;
@synthesize textView,note;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [picker selectRow:(val/100) inComponent:0 animated:YES];
    [picker selectRow:(val/10%10) inComponent:1 animated:YES];
    [picker selectRow:(val%10) inComponent:2 animated:YES];
    self.valid = NO;
    
    self.textView.text = self.note;
    if([self.note hasPrefix:@"REFUND"])
        self.titleLabel.text = @"请输入退货数量";
    else
        self.titleLabel.text = @"请输入瑕疵费";
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma - picker
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 10;
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[NSString alloc]initWithFormat:@"%d",row];
}

-(IBAction)buttonOK:(id)sender
{
    self.val = [picker selectedRowInComponent:0]*100 +
    [picker selectedRowInComponent:1]*10 + [picker selectedRowInComponent:2];
    
    self.valid = YES;
    
    //close
    
    [self.popController dismissPopoverAnimated:YES];
    [self.superController finishedEditPopover:self.val withNote:self.textView.text];
}

@end
