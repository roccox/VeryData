//
//  EditController.h
//  VeryData
//
//  Created by Rock on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"

@interface EditController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>{
    
}

@property(nonatomic) int val;
@property(nonatomic) BOOL valid;
@property(nonatomic,strong)IBOutlet UIPickerView * picker;
@property(nonatomic,strong)IBOutlet UIButton * button;
@property(nonatomic,strong)IBOutlet UITextField * textView;
@property(nonatomic,strong)IBOutlet UILabel * titleLabel;

@property(nonatomic,strong) NSString * note;

@property(nonatomic,strong) DetailViewController * superController;
@property(nonatomic,strong) UIPopoverController * popController;
-(IBAction)buttonOK:(id)sender;

@end
