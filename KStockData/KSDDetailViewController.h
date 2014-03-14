//
//  KSDDetailViewController.h
//  KStockData
//
//  Created by khr on 3/12/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSDDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fiftyTwoWeekHighLabel;
@property (weak, nonatomic) IBOutlet UILabel *exDividendDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fiftyTwoWeekLowLabel;
@property (weak, nonatomic) IBOutlet UILabel *dividendPayDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dividendYieldLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousCloseLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysLowLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysHighLabel;

@end
