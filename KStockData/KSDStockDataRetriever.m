//
//  KSDStockDataRetriever.m
//  KStockData
//
//  Created by khr on 3/19/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDStockDataRetriever.h"

#define YAHOO_FINANCE_COMMAND_URL "http://finance.yahoo.com/d/quotes.csv?"
static NSString *yahooCommandFormat = @"%ss=%@&f=%@";

#define YAHOO_CHART_URL "http://ichart.finance.yahoo.com/table.csv?"
#define SECONDS_IN_YEAR (365*24*3600)
//"ichart.finance.yahoo.com/table.csv?s=AAPL&d=4&e=2&f=2011&g=d&a=0&b=1&c=2008&ignore.csv"
static NSString *yahooChartFormat = @"%ss=%@&d=%d&e=%@&f=%@&g=d&a=%d&b=%@&c=%@&ignore.csv";

@implementation KSDStockDataRetriever

- (void)sendRequest:(NSString *)url completionHadler:(void (^)( NSData *, NSURLResponse *,NSError *))completionHadler
{
  NSURL *webServiceURL = [[NSURL alloc] initWithString:url];
  NSURLSession *session = [NSURLSession sharedSession];
  [[session dataTaskWithURL: webServiceURL completionHandler: completionHadler] resume];
}

- (void)stockDataFor:(NSString *)symbol
            commands:(NSString *)commands
    completionHadler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHadler
{
  NSString *url = [[NSString alloc] initWithFormat:yahooCommandFormat, YAHOO_FINANCE_COMMAND_URL, symbol, commands];
  [self sendRequest:url completionHadler:completionHadler];
}

- (void)chartDataFor:(NSString *)symbol
               years:(float)years
    completionHadler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHadler
{
  NSDate *today = [NSDate date];
  NSDate *yearAgo = [[NSDate alloc] initWithTimeIntervalSinceNow:-SECONDS_IN_YEAR*years];
  
  NSDateFormatter *dayFormatter = [NSDateFormatter new];
  [dayFormatter setDateFormat:@"dd"];
  NSDateFormatter *monthFormatter = [NSDateFormatter new];
  [monthFormatter setDateFormat:@"MM"];
  NSDateFormatter *yearFormatter = [NSDateFormatter new];
  [yearFormatter setDateFormat:@"yyyy"];
  
  NSString *url = [[NSString alloc] initWithFormat:yahooChartFormat, YAHOO_CHART_URL, symbol,
                   [[monthFormatter stringFromDate:today] intValue]-1,
                   [dayFormatter stringFromDate:today],
                   [yearFormatter stringFromDate:today],
                   [[monthFormatter stringFromDate:yearAgo] intValue]-1,
                   [dayFormatter stringFromDate:yearAgo],
                   [yearFormatter stringFromDate:yearAgo]
                   ];
  [self sendRequest:url completionHadler:completionHadler];
}

+ (BOOL)isStockMarketOpen {
  NSDate *now = [NSDate date];
  
  NSCalendar *cal = [NSCalendar currentCalendar];
  [cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
  NSDateComponents *dateComp = [cal components: NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitWeekday
                                      fromDate:now];
  
  //Report as open after it opens on this day (even after in closes on this day)
  return (dateComp.weekday > 1 && dateComp.weekday < 7) &&
  (dateComp.hour > 9  || (dateComp.hour == 9 && dateComp.minute > 45));
}

@end
