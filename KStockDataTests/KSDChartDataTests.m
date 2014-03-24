//
//  KSDChartDataTests.m
//  KStockData
//
//  Created by khr on 3/24/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KSDChartData.h"

@interface KSDChartDataTests : XCTestCase

@end

@implementation KSDChartDataTests {
  NSDictionary *_columns;
  KSDChartData *_testData;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  //Date,Open,High,Low,Close,Volume,Adj Close
  
  const NSUInteger count = 15;
  NSMutableArray *dates = [@[] mutableCopy];
  for (int i=0; i<count; ++i) {
    [dates addObject:[[NSDate alloc] initWithTimeIntervalSinceNow:-i]];
  }
  
  NSMutableArray *values = [@[] mutableCopy];
  for (int i=0; i<count; ++i) {
    [values addObject:[NSNumber numberWithInt:i]];
  }
  
  _columns = @{
               @"Date": dates,
               @"Open": values,
               @"High": values,
               @"Low":  values,
               @"Close": values,
               @"Volume": values,
               @"Adj Close": values
               };
  
  _testData = [[KSDChartData alloc] initWithColumns:_columns];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInstantiation
{
  XCTAssertEqual(_testData.tenDMA.count, 5, @"Unexpected 10DMA count");
  NSArray *expected10DMA = @[@4.5, @5.5, @6.5, @7.5, @8.5];
  XCTAssertEqualObjects(_testData.tenDMA, expected10DMA, @"Unexpected 10DMA values");
}

@end
