//
//  KStockDataTests.m
//  KStockDataTests
//
//  Created by khr on 3/12/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+NSString_KhrCSV.h"

@interface NSStringKhrCSVTests : XCTestCase

@end

@implementation NSStringKhrCSVTests {
  NSString *_testCSVString;
  NSString *_testHTMLString;
  NSString *_testCSVColumnsString;
}

- (void)setUp
{
    [super setUp];
  _testCSVString = @"\"1\",2,\"3,4\",5,6,7,8,\"9\"\r\n";
  _testHTMLString = @"This &nbsp;<b>&x that; &y </b>&nbsp;";
  _testCSVColumnsString = @"a,b,c,d\n1,2,3,2014-01-02\n5,6,7,2013-12-24\n9,0,1,2013-03-08\n";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testShouldNotBeNil {
    XCTAssertNotNil([_testCSVString khr_csv], @"Unexpected nil returned");
}

- (void)testShouldNotBeEmpty {
  XCTAssertNotEqual([[_testCSVString khr_csv] count], 0, @"Empty array returned");
}

- (void)testShouldExtractCorrectValues {
  NSArray *csv = [_testCSVString khr_csv];
  XCTAssertEqual(csv.count, 8, @"Incorrect CSV value count");
  [csv enumerateObjectsUsingBlock:^(NSString *valueString, NSUInteger index, BOOL *stop) {
    NSString *expectedString = [NSString stringWithFormat:@"%u", index + 1];
    if (index == 2) {
      expectedString = @"3,4";
    } else if (index == 3) {
      expectedString = @"5";
    } else if (index > 3) {
      expectedString = [NSString stringWithFormat:@"%u", index + 2];
    }
    XCTAssertEqualObjects(valueString, expectedString, @"Incorrect value");
  }];
}

- (void)testShouldStripHTML {
  NSString *noHTML = [_testHTMLString khr_stripHTML];
  NSString *expected = @"This &x that; &y ";
  XCTAssertEqualObjects(noHTML, expected, @"incorrect HTML stripping");
}

- (void)testShouldExtractColumnDictionary {
  NSDictionary *columns = [_testCSVColumnsString khr_csv_columns];
  XCTAssertNotNil(columns, @"Unexpected nil returned for columns");
  
  NSArray *keys = [columns allKeys];
  NSArray *expectedKeys = @[@"a", @"b", @"c", @"d"];
  
  XCTAssertEqual(keys.count, expectedKeys.count, @"Wrong number of column keys");
  NSInteger expectedValueCount = 3;
  for (NSString *key in expectedKeys) {
    XCTAssertTrue([keys containsObject:key], @"Missing key '%@' in column keys", key);
    NSArray *values = columns[key];
    XCTAssertEqual(values.count, expectedValueCount, @"Unexpected value count for column key '%@'", key);
    
    if ([key isEqualToString:@"a"]) {
      NSArray *expectedValues = @[@1, @5, @9];
      XCTAssertEqualObjects(values, expectedValues, @"Incorrect values for column key '%@'", key);
    }
    if ([key isEqualToString:@"b"]) {
      NSArray *expectedValues = @[@2, @6, @0];
      XCTAssertEqualObjects(values, expectedValues, @"Incorrect values for column key '%@'", key);
    }
    if ([key isEqualToString:@"c"]) {
      NSArray *expectedValues = @[@3, @7, @1];
      XCTAssertEqualObjects(values, expectedValues, @"Incorrect values for column key '%@'", key);
    }
    if ([key isEqualToString:@"d"]) {
      
      NSArray *expectedValues = @[
                                  @"2014-01-02",
                                  @"2013-12-24",
                                  @"2013-03-08"
                                  ];
      XCTAssertEqualObjects(values, expectedValues, @"Incorrect values for column key '%@'", key);
    }
   }
}


@end
