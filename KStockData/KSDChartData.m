//
//  KSDChartData.m
//  KStockData
//
//  Created by khr on 3/22/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDChartData.h"
#import "NSArray+KhrMinMax.h"
#import "KSDRegion.h"

static const NSUInteger maxDrawCount = 252;
static const NSUInteger labelDivisions = 5;

@implementation KSDChartData

- (void)adjustDrawCounts {
  NSUInteger drawCount = MIN(maxDrawCount, _dates.count);
  NSRange drawRange = NSMakeRange(0, drawCount);
  
  if (drawCount < _dates.count) {
    _dates = [_dates subarrayWithRange:drawRange];
    _prices = [_prices subarrayWithRange:drawRange];
    _open = [_open subarrayWithRange:drawRange];
    _close = [_close subarrayWithRange:drawRange];
    _high = [_high subarrayWithRange:drawRange];
    _low = [_low subarrayWithRange:drawRange];
  }
  
  if (drawCount < _tenDMA.count) {
    _tenDMA = [_tenDMA subarrayWithRange:drawRange];
  }
  if (drawCount < _fiftyDMA.count) {
    _fiftyDMA = [_fiftyDMA subarrayWithRange:drawRange];
  }
  if (drawCount < _twoHundredDMA.count) {
    _twoHundredDMA = [_twoHundredDMA subarrayWithRange:drawRange];
  }
  
  _timeRange = KSDRangeMake(-1, drawCount);
  
  CGFloat minPrice = MIN([_prices floatMin], [_low floatMin]);
  if (_twoHundredDMA.count > 1) {
    minPrice = MIN(minPrice, [_twoHundredDMA floatMin]);
  }
  
  CGFloat maxPrice = MAX([_prices floatMax], [_high floatMax]);
  if (_fiftyDMA.count > 1) {
    maxPrice = MAX(maxPrice, [_fiftyDMA floatMax]);
  }
  if (_tenDMA.count > 1) {
    maxPrice = MAX(maxPrice, [_tenDMA floatMax]);
  }
  
  _priceRange = KSDRangeMake(minPrice, maxPrice);
}

- (id)initWithColumns:(NSDictionary *)columns {
  if (self = [super init]) {
    _dates = [NSArray arrayWithArray:columns[@"Date"]];
    _prices = [NSArray arrayWithArray:columns[@"Close"]];
    
    _open = [NSArray arrayWithArray:columns[@"Open"]];
    _close = [NSArray arrayWithArray:columns[@"Close"]];
    
    _high = [NSArray arrayWithArray:columns[@"High"]];
    _low = [NSArray arrayWithArray:columns[@"Low"]];
    
    _tenDMA = [self generateDMA:10];
    _fiftyDMA = [self generateDMA:50];
    _twoHundredDMA = [self generateDMA:200];
    _rsi = [self generateRSI:14];
    _rsiRange = KSDRangeMake(0, 100);
 
    [self adjustDrawCounts];
    
    [self generatePriceLabels];
    [self generateMonthLabels];
    [self generateRsiLabels];
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
        for (NSUInteger i=index; i < index + window; ++i) {
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

- (CGFloat)rsi:(CGFloat)averageLoss averageGain:(CGFloat)averageGain {
  CGFloat value = 100*averageGain/(averageGain + averageLoss);
  return value;
}

- (CGFloat)exponentialEverageWithWindow:(NSUInteger)window previous:(CGFloat)previos current:(CGFloat)current {
  return ((window - 1)*previos + current)/window;
}

- (NSArray *)generateRSI:(NSUInteger)periods {
  NSMutableArray *rsi = [@[] mutableCopy];
  NSUInteger start = MIN(_dates.count - 1, maxDrawCount + periods - 1);
  CGFloat averageLoss = 0.0f;
  CGFloat averageGain = 0.0f;
  for (int i = 1; i < periods; ++i) {
    CGFloat diff = [_prices[start - i] floatValue] - [_prices[start - i + 1] floatValue];
    if (diff < 0.0f) {
      averageLoss -= diff;
    } else {
      averageGain += diff;
    }
  }
  averageLoss /= periods;
  averageGain /= periods;
  
  [rsi addObject:[NSNumber numberWithFloat:[self rsi:averageLoss averageGain:averageGain]]];
  
  for (int i = start - periods - 1; i > -1; --i) {
    CGFloat diff = [_prices[i] floatValue] - [_prices[i + 1] floatValue];
    if (diff < 0.0f) {
      averageLoss = [self exponentialEverageWithWindow:periods previous:averageLoss current:-diff];
    } else {
      averageGain = [self exponentialEverageWithWindow:periods previous:averageGain current:diff];
    }
    [rsi addObject:[NSNumber numberWithFloat:[self rsi:averageLoss averageGain:averageGain]]];
  }
  
  NSArray *reverseRsi = [[[rsi copy] reverseObjectEnumerator] allObjects];
  
  __block BOOL inRegion = NO;
  __block KSDRegion *region;
  __block CGFloat min, max;
  __block CGFloat left, right;
  __block NSMutableArray *oversold = [@[] mutableCopy];
  __block NSMutableArray *overbought = [@[] mutableCopy];
  [reverseRsi enumerateObjectsUsingBlock:^(NSNumber *rsi, NSUInteger i, BOOL *stop) {
    CGFloat value = [rsi floatValue];
    if (value < 30 && inRegion == NO) {
      inRegion = YES;
      min = i;
      left = [self intersectionWithLevel:30 forIndex:i inArray:reverseRsi];
    } else if (value > 30 && inRegion == YES) {
      max = i - 1;
      right = [self intersectionWithLevel:30 forIndex:i inArray:reverseRsi];
      region = [[KSDRegion alloc] initWithLeft:left range:KSDRangeMake(min, max) right:right];
      [oversold addObject:region];
      inRegion = NO;
    } else if (value > 70  && inRegion == NO) {
      max = i;
      left = [self intersectionWithLevel:30 forIndex:i inArray:reverseRsi];
      inRegion = YES;
    } else if (value < 70 && inRegion == YES) {
      max = i - 1;
      right = [self intersectionWithLevel:30 forIndex:i inArray:reverseRsi];
      region = [[KSDRegion alloc] initWithLeft:left range:KSDRangeMake(min, max) right:right];
      [overbought addObject:region];
      inRegion = NO;
    }
  }];
  
  _rsiOverboughtRegions = [overbought copy];
  _rsiOversoldRegions = [oversold copy];
  
  
  return reverseRsi;
}

- (CGFloat)intersectionWithLevel:(CGFloat)level forIndex:(NSUInteger)i inArray:(NSArray *)data {
  CGFloat f0 = [data[i] floatValue];
  CGFloat fm = [data[i-1] floatValue];
  
  return i+1 +(level - fm)/(f0 - fm);
}

- (void) generateRsiLabels {
  _rsiLabels = @[@0, @10, @30, @50, @70, @90];
}
@end
