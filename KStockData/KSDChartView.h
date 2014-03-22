//
//  KSDChartView.h
//  KStockData
//
//  Created by khr on 3/21/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSDChartData;

@interface KSDChartView : UIView
@property (strong, nonatomic) KSDChartData *data;
@end
