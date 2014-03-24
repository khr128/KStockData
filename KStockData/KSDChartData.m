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
    
    [self generatePriceLabels];
    [self generateMonthLabels];
    _tenDMA = [self generateDMA:10];
    _fiftyDMA = [self generateDMA:50];
  }
  return self;
}

- (void)generatePriceLabels {
  CGFloat minLabel = ceil(_priceRange.min);
  CGFloat maxLabel = floor(_priceRange.max);
  
  if (_priceRange.max - _priceRange.min > 30) {
    minLabel += 10 - fmodf(minLabel, 10);
    maxLabel -= fmodf(maxLabel, 10);
  }
  
  CGFloat diff = maxLabel - minLabel;
  
  const int labelDivisions = 5;
  const CGFloat div = diff/labelDivisions;
  
  NSMutableArray *labels = [@[] mutableCopy];
  for (int i=0; i <= labelDivisions; ++i) {
    [labels addObject:[NSNumber numberWithFloat:minLabel + i*div]];
  }
  _priceLabels = [labels copy];
}

- (void)generateMonthLabels {
  NSMutableDictionary *labels = [@{} mutableCopy];
  NSDateFormatter *dateFormatter = [NSDateFormatter new];
  [dateFormatter setDateFormat:@"MMM"];
  
  __block NSString *currentMonth = [dateFormatter stringFromDate:_dates[0]];
  
  [_dates enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger index, BOOL *stop) {
    NSString *month = [dateFormatter stringFromDate:date];
    if ([month isEqualToString:currentMonth] == NO) {
      labels[[NSNumber numberWithInt:index]] = currentMonth;
      currentMonth = month;
    }
  }];
  _monthLabels = [labels copy];
}

- (NSArray *)generateDMA:(NSInteger)window {
  if (window >= _prices.count) {
    return @[];
  }
  NSMutableArray *values = [@[] mutableCopy];
  [_prices enumerateObjectsUsingBlock:^(NSNumber *price, NSUInteger index, BOOL *stop) {
    if (index > _prices.count - 1 - window) {
      *stop = YES;
    } else {
      if (index == 0) {
        CGFloat sum = 0;
        for (int i=index; i < index + window; ++i) {
          sum += [_prices[i] floatValue];
        }
        [values addObject:[NSNumber numberWithFloat:sum/window]];
      } else {
        CGFloat prevValue = [values[index - 1] floatValue];
        CGFloat value = prevValue + ([_prices[index+window-1] floatValue] - [_prices[index-1] floatValue])/window;
        [values addObject:[NSNumber numberWithFloat:value]];
      }
    }
  }];
  return [values copy];
}
@end
