//
//  SplashViewController.h
//  VeryData
//
//  Created by Rock on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController<UITextFieldDelegate>{
    
}

@property (strong,nonatomic) IBOutlet UITextField * passField;

-(void)startMonitor;
-(void)endMonitor;

-(void)passInput;
@end
