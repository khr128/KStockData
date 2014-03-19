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

#define YAHOO_FINANCE_COMMAND_URL "http://finance.yahoo.com/d/quotes.csv?"

@interface KSDDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation KSDDetailViewController {
  NSArray *_yahooCommandTags;
  NSDictionary *_labelDictionary;
}

- (void)awakeFromNib {
  _yahooCommandTags = @[@"n", @"k", @"q", @"j", @"r1", @"y", @"p", @"g", @"h", @"l1", @"o", @"b2", @"t1", @"c", @"r", @"v", @"t7", @"p6", @"p5", @"e"];
  _labelDictionary = @{@"n": @"nameLabel",
                       @"k": @"fiftyTwoWeekHighLabel",
                       @"q": @"exDividendDateLabel",
                       @"j": @"fiftyTwoWeekLowLabel",
                       @"r1": @"dividendPayDateLabel",
                       @"y": @"dividendYieldLabel",
                       @"p": @"previousCloseLabel",
                       @"g": @"daysLowLabel",
                       @"h": @"daysHighLabel",
                       @"l1": @"lastTradeWithTimeLabel",
                       @"o": @"openLabel",
                       @"b2": @"askLabel",
                       @"t1": @"lastTradeTimeLabel",
                       @"c": @"changePercentLabel",
                       @"r": @"peRatioLabel",
                       @"v": @"volumeLabel",
                       @"t7": @"tickerTrendLabel",
                       @"p6": @"priceToBookLabel",
                       @"p5": @"priceToSalesLabel",
                       @"e": @"earningsPerShareLabel"
                       };
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

- (void)stockDataFor:(NSString *)symbol
{
  NSString *url = [[NSString alloc]
                   initWithFormat:@"%ss=%@&f=%@",
                   YAHOO_FINANCE_COMMAND_URL,
                   symbol,
                   [_yahooCommandTags componentsJoinedByString:@""]];
  NSURL *webServiceURL = [[NSURL alloc] initWithString:url];
  NSURLRequest *request = [ NSURLRequest requestWithURL:webServiceURL];
  NSURLResponse *response;
  NSError *error;
  NSData *data =
  [NSURLConnection sendSynchronousRequest:request
                        returningResponse:&response
                                    error:&error];
  NSString *csv = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSArray *array = [csv khr_csv];
  
//  NSLog(@"%@", [UIFont familyNames]);
  UIFont *font = [UIFont fontWithName:@"LED BOARD REVERSED" size:17];
//  UIFont *font = [UIFont fontWithName:@"Score Board" size:17];
  
  [array enumerateObjectsUsingBlock:^(NSString *string, NSUInteger index, BOOL *stop) {
//    NSLog(@"%@", string);
    UILabel *label = objc_msgSend(self, NSSelectorFromString(_labelDictionary[_yahooCommandTags[index]]));
    [UIView transitionWithView:label duration:0.3
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{ label.alpha = 0; }
                    completion:^(BOOL finished){
                      label.text = string;
                      label.font = font;
                      label.textColor = [UIColor greenColor];
                      label.alpha = 1.0;
                    }];
  }];
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
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
