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

- (NSArray *)generateDates:(const NSUInteger)count
{
  NSMutableArray *dates = [@[] mutableCopy];
  for (int i=0; i<count; ++i) {
    [dates addObject:[[NSDate alloc] initWithTimeIntervalSinceNow:-i]];
  }
  return [dates copy];
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  //Date,Open,High,Low,Close,Volume,Adj Close
  
  const NSUInteger count = 15;
  NSArray *dates = [self generateDates:count];
  
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
  
  _testData = [[KSDChartData alloc] initWithColumns:_columns andSymbol:@"A"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInstantiation
{
  XCTAssertEqual(_testData.tenDMA.count, 6, @"Unexpected 10DMA count");
  NSArray *expected10DMA = @[@4.5, @5.5, @6.5, @7.5, @8.5, @9.5];
  XCTAssertEqualObjects(_testData.tenDMA, expected10DMA, @"Unexpected 10DMA values");
}

- (void)testRSI {
  NSArray *values =
  @[
    @44.34f, @44.09f, @44.15f, @43.61f, @44.33f, @44.83f, @45.10f, @45.42f, @45.84f, @46.08f, @45.89f, @46.03f, @45.61f, @46.28f,
    @46.28f, @46.00f, @46.03f, @46.41f, @46.22f, @45.64f, @46.21f
    ];
  values = [[values reverseObjectEnumerator] allObjects];
  
  NSArray *dates = [self generateDates:values.count];
 
  _columns = @{
               @"Date": dates,
               @"Open": values,
               @"High": values,
               @"Low":  values,
               @"Close": values,
               @"Volume": values,
               @"Adj Close": values
               };
  
  _testData = [[KSDChartData alloc] initWithColumns:_columns andSymbol:@"A"];
  
  NSUInteger expectedRsiCount = values.count - 14;
  XCTAssertEqual(_testData.rsi.count, expectedRsiCount, @"Unexpected RSI count");
  
  NSArray *expectedRSI = @[
                           @70.46411,
                           @67.88618,
                           @66.46452,
                           @67.5415,
                           @66.48784,
                           @60.8108,
                           @63.09839
                           ];
  expectedRSI = [[expectedRSI reverseObjectEnumerator] allObjects];
  
  [_testData.rsi enumerateObjectsUsingBlock:^(NSNumber *rsi, NSUInteger i, BOOL *stop) {
    XCTAssertEqualWithAccuracy([rsi floatValue], [expectedRSI[i] floatValue], 1.0e-5, @"Unexpected RSI value");
  }];
  
}

@end
