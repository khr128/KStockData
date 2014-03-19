//
//  KSDStockDataRetriever.m
//  KStockData
//
//  Created by khr on 3/19/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDStockDataRetriever.h"

#define YAHOO_FINANCE_COMMAND_URL "http://finance.yahoo.com/d/quotes.csv?"

@implementation KSDStockDataRetriever
+ (void)stockDataFor:(NSString *)symbol
            commands:(NSString *)commands
    completionHadler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completionHadler
{
  NSString *url = [[NSString alloc] initWithFormat:@"%ss=%@&f=%@", YAHOO_FINANCE_COMMAND_URL, symbol, commands];
  NSURL *webServiceURL = [[NSURL alloc] initWithString:url];
  NSURLRequest *request = [ NSURLRequest requestWithURL:webServiceURL];
  NSOperationQueue *requestQueue = [NSOperationQueue new];
  [NSURLConnection sendAsynchronousRequest:request queue:requestQueue completionHandler: completionHadler];
}

@end
