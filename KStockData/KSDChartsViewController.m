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
  self.priceChartsView.data = self.data;
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserverForName:KSD_STOCK_SYMBOL_SELECTED
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note){
                KSDDetailViewController *detailsViewController = note.object;
                self.priceChartsView.data = detailsViewController.chartData;
                for (KSDPlotView *indicatorView in _indicatorViews) {
                  indicatorView.data = detailsViewController.chartData;
                };
              }];
 
  CGFloat offset = 50;
  [nc addObserverForName:UIDeviceOrientationDidChangeNotification
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note){
                 for (KSDPlotView *indicatorView in _indicatorViews) {
                  CGRect frameForView;
                  CGRect priceViewFrame = self.priceChartsView.frame;
                  CGRect viewBounds = self.view.bounds;
                  if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation) == YES) {
                    frameForView = CGRectMake(priceViewFrame.origin.x, viewBounds.size.width - offset,
                                              priceViewFrame.size.width, priceViewFrame.size.height);
                  } else {
                    frameForView = CGRectOffset(viewBounds, 0, viewBounds.size.height - offset);
                  }
                  indicatorView.frame = frameForView;
                };
              }];
  
  _indicatorViews = [@[] mutableCopy];
  [_indicatorViews addObject:[self addPlotViewAtOffset:offset withChartData:self.data]];
}

- (KSDPlotView *)addPlotViewAtOffset:(CGFloat)offset withChartData:(KSDChartData *)chartData {
  CGRect frameForView;
  CGRect priceViewFrame = self.priceChartsView.frame;
  CGRect viewBounds = self.view.bounds;
  if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation) == YES) {
    frameForView = CGRectMake(priceViewFrame.origin.x, viewBounds.size.width - offset,
                              priceViewFrame.size.width, priceViewFrame.size.height);
  } else {
    frameForView = CGRectOffset(viewBounds, 0, viewBounds.size.height - offset);
  }
  
  UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  KSDIndicatorChartViewController *indicatorViewController =
  [myStoryboard instantiateViewControllerWithIdentifier:@"IndicatorChartVC"];
  
  KSDPlotView *view = (KSDPlotView *)indicatorViewController.view;
  view.frame = frameForView;
  view.data = chartData;
  
  
  //add as a child
  [self addChildViewController:indicatorViewController];
  [self.view addSubview:view];
  [indicatorViewController didMoveToParentViewController:self];
 
  return view;
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
