//
//  DateSelController.h
//  VeryData
//
//  Created by Rock on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateSelController : UIViewController

@property(nonatomic,strong) IBOutlet UIDatePicker * startDate;
@property(nonatomic,strong) IBOutlet UIDatePicker * endDate;


-(IBAction)hideDateSel:(id)sender;
-(IBAction)selectedDate:(id)sender;
@end
