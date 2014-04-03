//
//  KSDFractalDimensionMinMax.m
//  KStockData
//
//  Created by khr on 4/3/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDFractalDimensionMinMax.h"

@implementation KSDFractalDimensionMinMax {
  NSMutableIndexSet *_currentIndexSet;
  NSArray *_data;
  NSUInteger _currentMaxIndex;
  NSUInteger _currentMinIndex;
}

- (id)initWithArray:(NSArray *)data startIndex:(NSUInteger)startIndex period:(NSUInteger)period {
  if (self = [super init]) {
    _data = data;
    _currentIndexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, period)];
    _currentMaxIndex = -1;
    _currentMinIndex = -1;
  }
  return self;
}

- (void)calculate {
  if ([_currentIndexSet containsIndex:_currentMinIndex] == YES) {
    NSUInteger lastIndexInPeriod = [_currentIndexSet lastIndex];
    float lastValueInPeriod = [_data[lastIndexInPeriod] floatValue];
    if (_min > lastValueInPeriod) {
      _min = lastValueInPeriod;
      _currentMinIndex = lastIndexInPeriod;
    }
  } else {
    __block float min = [_data[[_currentIndexSet firstIndex]] floatValue];
    [_data enumerateObjectsAtIndexes: _currentIndexSet
                             options: 0
                          usingBlock: ^(NSNumber *value, NSUInteger index, BOOL *stop) {
                            float v = [value floatValue];
                            if (min > v) {
                              min = v;
                              _currentMinIndex = index;
                            }
                          }];
    _min = min;
  }
  
  if ([_currentIndexSet containsIndex:_currentMaxIndex] == YES) {
    NSUInteger lastIndexInPeriod = [_currentIndexSet lastIndex];
    float lastValueInPeriod = [_data[lastIndexInPeriod] floatValue];
    if (_max < lastValueInPeriod) {
      _max = lastValueInPeriod;
      _currentMaxIndex = lastIndexInPeriod;
    }
  } else {
    __block float max = [_data[[_currentIndexSet firstIndex]] floatValue];
    [_data enumerateObjectsAtIndexes: _currentIndexSet
                             options: 0
                          usingBlock: ^(NSNumber *value, NSUInteger index, BOOL *stop) {
                            float v = [value floatValue];
                            if (max < v) {
                              max = v;
                              _currentMaxIndex = index;
                            }
                          }];
    _max = max;
  }
  
  [_currentIndexSet shiftIndexesStartingAtIndex:[_currentIndexSet firstIndex] by:1];
}
@end
