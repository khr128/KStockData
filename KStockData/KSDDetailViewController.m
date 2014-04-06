//
//  KSDDetailViewController.m
//  KStockData
//
//  Created by khr on 3/12/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDDetailViewController.h"
#import <objc/message.h>
#import "NSString+NSString_KhrCSV.h"
#import "KSDStockDataRetriever.h"
#import "KSDChartData.h"
#import "KSDChartsViewController.h"
#import "KSDChartsAnimationController.h"

NSString *KSD_STOCK_SYMBOL_SELECTED = @"KSDStockSymbolSelected";

@interface KSDDetailViewController () <UIViewControllerTransitioningDelegate>
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation KSDDetailViewController {
  NSArray *_yahooCommandTags;
  NSDictionary *_labelDictionary;
  KSDChartsAnimationController *_chartsAnimationController;
  KSDStockDataRetriever *_stockDataRetriever;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    _chartsAnimationController = [KSDChartsAnimationController new];
  }
  return self;
}

- (void)awakeFromNib {
  _yahooCommandTags = @[@"n", @"k", @"q", @"j", @"r1", @"y", @"p", @"g", @"h", @"l1", @"o", @"b2", @"t1", @"r", @"v", @"t7", @"p6", @"p5", @"e", @"s7", @"r5", @"j1", @"x"];
  _labelDictionary = @{@"n"  :  @"nameLabel",
                       @"k"  :  @"fiftyTwoWeekHighLabel",
                       @"q"  :  @"exDividendDateLabel",
                       @"j"  :  @"fiftyTwoWeekLowLabel",
                       @"r1" :  @"dividendPayDateLabel",
                       @"y"  :  @"dividendYieldLabel",
                       @"p"  :  @"previousCloseLabel",
                       @"g"  :  @"daysLowLabel",
                       @"h"  :  @"daysHighLabel",
                       @"l1" :  @"lastTradeWithTimeLabel",
                       @"o"  :  @"openLabel",
                       @"b2" :  @"askLabel",
                       @"t1" :  @"lastTradeTimeLabel",
                       @"r"  :  @"peRatioLabel",
                       @"v"  :  @"volumeLabel",
                       @"t7" :  @"tickerTrendLabel",
                       @"p6" :  @"priceToBookLabel",
                       @"p5" :  @"priceToSalesLabel",
                       @"e"  :  @"earningsPerShareLabel",
                       @"s7" :  @"shortRatioLabel",
                       @"r5" :  @"pegRatioLabel",
                       @"j1" :  @"marketCapitalizationLabel",
                       @"x"  :  @"stockExchangeLabel"
                       };
  
  _stockDataRetriever = [KSDStockDataRetriever new];
 }

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
  _detailItem = newDetailItem;
  
  // Update the view.
  [self configureView];
  
  if (self.masterPopoverController != nil) {
    [self.masterPopoverController dismissPopoverAnimated:YES];
  }
}

- (void)setChartData:(KSDChartData *)chartData {
  _chartData = chartData;
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        self.navigationItem.rightBarButtonItem.enabled = (_chartData != nil);
    });
}

static void (^dataRetrievalHandler)(NSData *data, NSURLResponse *response, NSError *error);
static void (^chartRetrievalHandler)(NSData *data, NSURLResponse *response, NSError *error);

- (void)stockDataFor:(NSString *)symbol
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    dataRetrievalHandler =
    ^(NSData *data, NSURLResponse *response, NSError *error) {
      NSString *csv = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      NSArray *array = [csv khr_csv];
      
      //  NSLog(@"%@", [UIFont familyNames]);
      UIFont *font = [UIFont fontWithName:@"LED BOARD REVERSED" size:17];
      //  UIFont *font = [UIFont fontWithName:@"Score Board" size:17];
      
      dispatch_queue_t mainQueue = dispatch_get_main_queue();
      dispatch_sync(mainQueue, ^{
        [array enumerateObjectsUsingBlock:^(NSString *string, NSUInteger index, BOOL *stop) {
          //    NSLog(@"%@", string);
          UILabel *label =
          objc_msgSend(self, NSSelectorFromString(_labelDictionary[_yahooCommandTags[index]]));
          [UIView transitionWithView:label duration:0.3
                             options:UIViewAnimationOptionCurveEaseInOut
                          animations:^{ label.alpha = 0; }
                          completion:^(BOOL finished){
                            label.text = string;
                            label.font = font;
                            label.textColor = [UIColor yellowColor];
                            label.alpha = 1.0;
                          }];
        }];
      });
    };
  });
  
  [_stockDataRetriever stockDataFor:symbol
                             commands:[_yahooCommandTags componentsJoinedByString:@""]
                     completionHadler:dataRetrievalHandler];
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:KSD_STOCK_SYMBOL_SELECTED object:self];
}

- (void)configureView
{
   if (self.detailItem) {
    NSString *symbol = [[self.detailItem valueForKey:@"symbol"] description];
    [self stockDataFor:symbol];
    self.title = symbol;
  }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Stock List", @"Stock List");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma -
#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
  if ([segue.identifier isEqualToString:@"ChartSegue"]) {
    KSDChartsViewController *chartsViewController = segue.destinationViewController;
    chartsViewController.data = _chartData;
    chartsViewController.transitioningDelegate = self;
    chartsViewController.modalPresentationStyle = UIModalPresentationCustom;
  }
}

#pragma -
#pragma mark - Transitioning

- (id<UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *) presented
                                                                   presentingController:(UIViewController *) presenting
                                                                       sourceController:(UIViewController *) source
{
  return _chartsAnimationController;
}

@end
