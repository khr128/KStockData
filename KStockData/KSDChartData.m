//
//  KSDChartData.m
//  KStockData
//
//  Created by khr on 3/22/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDChartData.h"
#import "NSArray+KhrMinMax.h"

NS_INLINE KSDRange KSDRangeMake(float min, float max) {
  KSDRange r;
  r.min = min;
  r.max = max;
  return r;
}


@implementation KSDChartData

- (id)initWithColumns:(NSDictionary *)columns {
  if (self = [super init]) {
    _dates = [NSArray arrayWithArray:columns[@"Date"]];
    _prices = [NSArray arrayWithArray:columns[@"Close"]];
    
    _open = [NSArray arrayWithArray:columns[@"Open"]];
    _close = [NSArray arrayWithArray:columns[@"Close"]];
    
    _high = [NSArray arrayWithArray:columns[@"High"]];
    _low = [NSArray arrayWithArray:columns[@"Low"]];
    
    _timeRange = KSDRangeMake(0, _dates.count);
    _priceRange = KSDRangeMake([_prices floatMin], [_prices floatMax]);
    
    _maxHigh = [_high floatMax];
    _minLow = [_low floatMin];
  
  }
  return self;
}
@end
