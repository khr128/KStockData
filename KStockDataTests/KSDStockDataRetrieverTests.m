//
//  KSDStockDataRetrieverTests.m
//  KStockData
//
//  Created by khr on 4/11/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KSDStockDataRetriever.h"

@interface KSDStockDataRetrieverTests : XCTestCase

@end

@implementation KSDStockDataRetrieverTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIsStockMarketOpen
{
  NSDate *now = [NSDate date];
  NSCalendar *cal = [NSCalendar currentCalendar];
  [cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
  NSDateComponents *dateComp = [cal components: NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:now];
  
  BOOL marketIsOpen = (dateComp.hour > 9 && dateComp.hour < 16) ||
  (dateComp.hour == 9 && dateComp.minute > 45) ||
  (dateComp.hour == 16 && dateComp.minute < 15);

  if (marketIsOpen == YES) {
    XCTAssertTrue([KSDStockDataRetriever isStockMarketOpen], @"Unexpected result for \"%s\"", __PRETTY_FUNCTION__);
  } else {
    XCTAssertFalse([KSDStockDataRetriever isStockMarketOpen], @"Unexpected result for \"%s\"", __PRETTY_FUNCTION__);
  }
}

@end
