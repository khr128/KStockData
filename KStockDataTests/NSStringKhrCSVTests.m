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
}

- (void)setUp
{
    [super setUp];
  _testCSVString = @"\"1\",2,\"3,4\",5\r\n";
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
  XCTAssertEqual(csv.count, 4, @"Incorrect CSV value count");
  [csv enumerateObjectsUsingBlock:^(NSString *valueString, NSUInteger index, BOOL *stop) {
    NSString *expectedString = [NSString stringWithFormat:@"%d", index+1];
    XCTAssertEqualObjects(valueString, expectedString, @"Incorrect value");
  }];
}

@end
