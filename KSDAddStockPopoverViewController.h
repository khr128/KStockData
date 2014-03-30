//
//  KSDAddStockPopoverViewController.h
//  KStockData
//
//  Created by khr on 3/13/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSDMasterViewController;

@interface KSDAddStockPopoverViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *symbolTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *overBoughtSold;
@property (weak, nonatomic) UIPopoverController *presentingPopoverController;
@property (weak, nonatomic) KSDMasterViewController *masterViewController;
@end
