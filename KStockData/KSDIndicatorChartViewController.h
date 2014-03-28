//
//  KSDIndicatorChartViewController.h
//  KStockData
//
//  Created by khr on 3/27/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSDIndicatorChartViewController : UIViewController
@property (nonatomic, weak) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIGravityBehavior *gravity;
@property (nonatomic, assign) BOOL dynamic;
@property (nonatomic, assign) CGFloat offset;

- (void)defineViewGeometry;
@end
