//
//  KSDChartsViewController.h
//  KStockData
//
//  Created by khr on 3/20/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSDChartData;
@class KSDPriceChartsView, KSDRsiChartView;

@interface KSDChartsViewController : UIViewController <UICollisionBehaviorDelegate>
@property (strong, nonatomic) KSDChartData *data;

- (CGPoint)dockingSnapPoint;
@end
