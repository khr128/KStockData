//
//  NSArrayKhrMinMaxTests.m
//  KStockData
//
//  Created by khr on 3/22/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+KhrMinMax.h"

@interface NSArrayKhrMinMaxTests : XCTestCase

@end

@implementation NSArrayKhrMinMaxTests {
  NSArray *_testArray;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
  _testArray = @[@-1, @-2.34, @4.01, @8.91];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFloatMin {
  float min = [_testArray floatMin];
  XCTAssertEqual(min, -2.34f, @"Unexpected min value in array");
}

- (void)testFloatMax {
  float max = [_testArray floatMax];
  XCTAssertEqual(max, 8.91f, @"Unexpected min value in array");
}

@end
