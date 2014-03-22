//
//  KSDChartsViewController.h
//  KStockData
//
//  Created by khr on 3/20/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSDChartData;
@class KSDChartView;

@interface KSDChartsViewController : UIViewController
@property (weak, nonatomic) IBOutlet KSDChartView *chartView;
@property (strong, nonatomic) KSDChartData *data;
@end
