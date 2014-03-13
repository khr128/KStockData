//
//  KSDDetailViewController.m
//  KStockData
//
//  Created by khr on 3/12/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDDetailViewController.h"
#import <objc/message.h>

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
  _yahooCommandTags = @[@"n", @"k", @"q", @"j", @"r1", @"y", @"p"];
  _labelDictionary = @{@"n": @"nameLabel",
                       @"k": @"fiftyTwoWeekHighLabel",
                       @"q": @"exDividendDateLabel",
                       @"j": @"fiftyTwoWeekLowLabel",
                       @"r1": @"dividendPayDateLabel",
                       @"y": @"dividendYieldLabel",
                       @"p": @"previousCloseLabel"
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
  NSString *csv = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSArray *array = [csv componentsSeparatedByString: @","];
  
  [array enumerateObjectsUsingBlock:^(NSString *string, NSUInteger index, BOOL *stop) {
    NSString *trimmedValueString = [string stringByTrimmingCharactersInSet:
                                    [NSCharacterSet characterSetWithCharactersInString:@"\""]];
    NSLog(@"%@", trimmedValueString);
    
    UILabel *label = objc_msgSend(self, NSSelectorFromString(_labelDictionary[_yahooCommandTags[index]]));
    label.text = trimmedValueString;
  }];
}

- (void)configureView
{
    // Update the user interface for the detail item.

  if (self.detailItem) {
    NSString *symbol = [[self.detailItem valueForKey:@"symbol"] description];
    self.symbolLabel.text = symbol;
    [self stockDataFor:symbol];
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
