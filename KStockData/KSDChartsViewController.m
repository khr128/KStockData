//
//  KSDChartsViewController.m
//  KStockData
//
//  Created by khr on 3/20/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDChartsViewController.h"
#import "KSDPriceChartsView.h"
#import "KSDRsiChartView.h"
#import "Externals.h"
#import "KSDDetailViewController.h"
#import "KSDIndicatorChartViewController.h"

@interface KSDChartsViewController ()

@end

@implementation KSDChartsViewController {
  NSMutableArray *_indicatorViews;
}

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
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserverForName:KSD_STOCK_SYMBOL_SELECTED
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note){
                KSDDetailViewController *detailsViewController = note.object;
                for (KSDPlotView *indicatorView in _indicatorViews) {
                  indicatorView.data = detailsViewController.chartData;
                };
              }];
 
  _indicatorViews = [@[] mutableCopy];
  
  UIView *superView = self.view;
  
  KSDPriceChartsView *priceView = [[KSDPriceChartsView alloc] init];
  priceView.data = self.data;
  [priceView setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [self addChildViewControllerWithView:priceView];
  
  CGFloat navBarOffset = self.navigationController.navigationBar.bounds.size.height
  + self.navigationController.navigationBar.frame.origin.y;
  
  NSLayoutConstraint *c1 = [NSLayoutConstraint
                                      constraintWithItem:priceView
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:superView
                                      attribute:NSLayoutAttributeTop
                                      multiplier:1.0 constant:navBarOffset];
  
  NSLayoutConstraint *c2 = [NSLayoutConstraint
                  constraintWithItem:priceView
                  attribute:NSLayoutAttributeCenterX
                  relatedBy:NSLayoutRelationEqual
                  toItem:superView
                  attribute:NSLayoutAttributeCenterX
                  multiplier:1.0 constant:0.0];
  
  NSLayoutConstraint *c3 = [NSLayoutConstraint
                  constraintWithItem:priceView
                  attribute:NSLayoutAttributeWidth
                  relatedBy:NSLayoutRelationEqual
                  toItem:superView
                  attribute:NSLayoutAttributeWidth
                  multiplier:1.0 constant:0.0];
  
  NSLayoutConstraint *c4 = [NSLayoutConstraint
                  constraintWithItem:priceView
                  attribute:NSLayoutAttributeHeight
                  relatedBy:NSLayoutRelationEqual
                  toItem:superView
                  attribute:NSLayoutAttributeHeight
                  multiplier:0.5 constant:0];
  
  [superView addConstraints:@[c1, c2, c3, c4]];
  
  CGFloat offset = 50;
  KSDRsiChartView *rsiView = [[KSDRsiChartView alloc] init];
  rsiView.data = self.data;
  [rsiView setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [self addChildViewControllerWithView:rsiView];
  
  c1 = [NSLayoutConstraint
                            constraintWithItem:rsiView
                            attribute:NSLayoutAttributeTop
                            relatedBy:NSLayoutRelationEqual
                            toItem:superView
                            attribute:NSLayoutAttributeBottom
                            multiplier:1.0 constant:-offset];
  
  c2 = [NSLayoutConstraint
                            constraintWithItem:rsiView
                            attribute:NSLayoutAttributeCenterX
                            relatedBy:NSLayoutRelationEqual
                            toItem:superView
                            attribute:NSLayoutAttributeCenterX
                            multiplier:1.0 constant:0.0];
  
  c3 = [NSLayoutConstraint
                            constraintWithItem:rsiView
                            attribute:NSLayoutAttributeWidth
                            relatedBy:NSLayoutRelationEqual
                            toItem:superView
                            attribute:NSLayoutAttributeWidth
                            multiplier:1.0 constant:0.0];
  
  c4 = [NSLayoutConstraint
                            constraintWithItem:rsiView
                            attribute:NSLayoutAttributeHeight
                            relatedBy:NSLayoutRelationEqual
                            toItem:superView
                            attribute:NSLayoutAttributeHeight
                            multiplier:0.5 constant:0];
  
  [superView addConstraints:@[c1, c2, c3, c4]];

}

- (void)addChildViewControllerWithView:(UIView *)view {
  UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  KSDIndicatorChartViewController *indicatorViewController =
  [myStoryboard instantiateViewControllerWithIdentifier:@"IndicatorChartVC"];
  
  indicatorViewController.view = view;
  [_indicatorViews addObject:view];
  
  //add as a child
  [self addChildViewController:indicatorViewController];
  [self.view addSubview:view];
  [indicatorViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
