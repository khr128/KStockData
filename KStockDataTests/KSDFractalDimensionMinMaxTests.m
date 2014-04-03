//
//  KSDFractalDimensionMinMax.m
//  KStockData
//
//  Created by khr on 4/3/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KSDFractalDimensionMinMax.h"

@interface KSDFractalDimensionMinMaxTests : XCTestCase

@end

@implementation KSDFractalDimensionMinMaxTests {
  NSArray *_testData;
  NSArray *_expectedMins, *_expectedMaxes;
  KSDFractalDimensionMinMax *_minMax;
}

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  _testData = @[@-15, @15, @10, @10, @10, @-16, @-15, @-14];
  _expectedMaxes = @[@15, @15, @10, @10];
  _expectedMins = @[@-15, @-16, @-16, @-16];
  
  _minMax = [[KSDFractalDimensionMinMax alloc] initWithArray:_testData startIndex:0 period:5];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCalculation0 {
  [_expectedMins enumerateObjectsUsingBlock:^(NSNumber *expectedMinNumber, NSUInteger index, BOOL *stop) {
    [_minMax calculate];
    float expectedMin = [expectedMinNumber floatValue];
    float expectedMax = [_expectedMaxes[index] floatValue];
    XCTAssertEqual(_minMax.min, expectedMin, @"Unexpected min value");
    XCTAssertEqual(_minMax.max, expectedMax, @"Unexpected max value");
  }];
}

@end
