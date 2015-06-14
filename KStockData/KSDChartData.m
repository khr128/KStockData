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
#import "KSDFractalDimensionMinMax.h"

static const NSUInteger maxDrawCount = 252;
static const NSUInteger labelDivisions = 5;
static const CGFloat rsiOversoldLevel = 30;
static const CGFloat rsiOverboughtLevel = 70;

static const NSUInteger macdLongPeriod = 26;
static const NSUInteger macdShortPeriod = 12;
static const NSUInteger macdSignalPeriod = 9;

static const NSUInteger fractalDimensionHalfPeriod = 19;

@implementation KSDChartData {
  NSMutableArray *_allDates;
  NSMutableArray *_allPrices;
  
  NSMutableArray *_allOpen;
  NSMutableArray *_allClose;
  
  NSMutableArray *_allHigh;
  NSMutableArray *_allLow;
}

- (void)calculatePriceRange {
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

- (void)calculateMacdRange {
  CGFloat minMacd = MIN([_macdSignalLine floatMin], [_macdLine floatMin]);
  CGFloat maxMacd = MAX([_macdSignalLine floatMax], [_macdLine floatMax]);
  
  NSMutableArray *histogram = [[NSMutableArray alloc] initWithCapacity:_macdSignalLine.count];
  [_macdSignalLine enumerateObjectsUsingBlock:^(NSNumber *signal, NSUInteger idx, BOOL *stop) {
    CGFloat signalValue = [signal floatValue];
    CGFloat lineValue = [_macdLine[idx] floatValue];
    [histogram addObject:[NSNumber numberWithFloat:signalValue - lineValue]];
  }];
  
  minMacd = MIN(minMacd, [histogram floatMin]);
  maxMacd = MAX(maxMacd, [histogram floatMax]);
  
  _macdRange = KSDRangeMake(minMacd, maxMacd);
}

- (void)calculateYRanges {
  [self calculatePriceRange];
  [self calculateMacdRange];
  _fractalDimensionRange = KSDRangeMake(1, 2);
}

- (void)adjustDrawCounts {
  NSUInteger drawCount = MIN(maxDrawCount, _allDates.count);
  NSRange drawRange = NSMakeRange(0, drawCount);
  
  if (drawCount < _allDates.count) {
    _dates = [_allDates subarrayWithRange:drawRange];
    _prices = [_allPrices subarrayWithRange:drawRange];
    _open = [_allOpen subarrayWithRange:drawRange];
    _close = [_allClose subarrayWithRange:drawRange];
    _high = [_allHigh subarrayWithRange:drawRange];
    _low = [_allLow subarrayWithRange:drawRange];
  } else {
    _dates = [_allDates copy];
    _prices = [_allPrices copy];
    _open = [_allOpen copy];
    _close = [_allClose copy];
    _high = [_allHigh copy];
    _low = [_allLow copy];
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
  if (drawCount < _macdSignalLine.count) {
    _macdSignalLine = [_macdSignalLine subarrayWithRange:drawRange];
    _macdLine = [_macdLine subarrayWithRange:drawRange];
  } else {
    _macdLine = [_macdLine subarrayWithRange:NSMakeRange(0, _macdSignalLine.count)];
  }
  
  if (drawCount < _fractalDimensions.count) {
    _fractalDimensions = [_fractalDimensions subarrayWithRange:drawRange];
  }

  _timeRange = KSDRangeMake(-1, drawCount);
}

- (void)calculateDerivedData {
  _tenDMA = [self generateEMA:10];
  _fiftyDMA = [self generateEMA:50];
  _twoHundredDMA = [self generateSMA:200];
  
  _rsi = [self generateRSI:14];
  _rsiRange = KSDRangeMake(0, 100);
  
  _macdLine = [self generateMacdLine];
  _macdSignalLine = [self exponentialMovingAverageOf:_macdLine withWindow:macdSignalPeriod];
  
  _fractalDimensions = [self generateFractalDimensions:_tenDMA];
  
  [self adjustDrawCounts];
  [self calculateYRanges];
  
  [self generatePriceLabels];
  [self generateMonthLabels];
  [self generateRsiLabels];
  [self generateMacdLabels];
  [self generateFractalDimensionLabels];
}

- (id)initWithColumns:(NSDictionary *)columns andSymbol:(NSString *)symbol{
  if (self = [super init]) {
    _symbol = symbol;
    _allDates = [NSMutableArray arrayWithArray:columns[@"Date"]];
    _allPrices = [NSMutableArray arrayWithArray:columns[@"Close"]];
    
    _allOpen = [NSMutableArray arrayWithArray:columns[@"Open"]];
    _allClose = [NSMutableArray arrayWithArray:columns[@"Close"]];
    
    _allHigh = [NSMutableArray arrayWithArray:columns[@"High"]];
    _allLow = [NSMutableArray arrayWithArray:columns[@"Low"]];
    
    [self calculateDerivedData];
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


static NSDictionary *monthAbbrev = nil;

- (void)generateMonthLabels {
  if (_dates.count < 1) {
    _monthLabels = @{};
    return;
  }
  
  NSMutableDictionary *labels = [@{} mutableCopy];  
  __block NSString *currentMonth = [_dates[0] substringWithRange:NSMakeRange(5, 2)];
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    monthAbbrev = @{@"01":@"Jan", @"02":@"Feb", @"03":@"Mar", @"04":@"Apr", @"05":@"May", @"06":@"Jun",
                    @"07":@"Jul", @"08":@"Aug", @"09":@"Sep", @"10":@"Oct", @"11":@"Nov", @"12":@"Dec"};
  });
  
  [_dates enumerateObjectsUsingBlock:^(NSString *date, NSUInteger index, BOOL *stop) {
    NSString *month = [date substringWithRange:NSMakeRange(5, 2)];
    if ([month isEqualToString:currentMonth] == NO) {
      labels[[NSNumber numberWithInt:index]] = monthAbbrev[currentMonth];
      currentMonth = month;
    }
  }];
  _monthLabels = [labels copy];
}

- (NSArray *)generateSMA:(NSInteger)window {
  if (window >= _allPrices.count) {
    return @[];
  }
  NSInteger maxIndex = _allPrices.count - window;
  NSMutableArray *values = [NSMutableArray arrayWithCapacity:maxIndex+1];
  [_allPrices enumerateObjectsUsingBlock:^(NSNumber *price, NSUInteger index, BOOL *stop) {
    if (index > maxIndex) {
      *stop = YES;
    } else {
      if (index == 0) {
        CGFloat sum = 0;
        for (NSUInteger i=0; i < window; ++i) {
          sum += [_allPrices[i] floatValue];
        }
        [values addObject:[NSNumber numberWithFloat:sum/window]];
      } else {
        CGFloat prevValue = [values[index - 1] floatValue];
        CGFloat value = prevValue + ([_allPrices[index+window-1] floatValue] - [_allPrices[index-1] floatValue])/window;
        [values addObject:[NSNumber numberWithFloat:value]];
      }
    }
  }];
  return [values copy];
}

- (NSArray *)exponentialMovingAverageOf:(NSArray *)data withWindow:(NSInteger)window {
  if (window >= data.count) {
    return @[];
  }
  NSInteger maxIndex = data.count - window;
  NSMutableArray *values = [NSMutableArray arrayWithCapacity:maxIndex+1];
  NSArray *reversePrices = [[data reverseObjectEnumerator] allObjects];
  [reversePrices enumerateObjectsUsingBlock:^(NSNumber *price, NSUInteger index, BOOL *stop) {
    if (index > maxIndex) {
      *stop = YES;
    } else {
      if (index == 0) {
        CGFloat sum = 0;
        for (NSUInteger i=0; i < window; ++i) {
          sum += [reversePrices[i] floatValue];
        }
        [values addObject:[NSNumber numberWithFloat:sum/window]];
      } else {
        CGFloat prevValue = [values[index - 1] floatValue];
        CGFloat value =
        [self exponentialAverageWithWindow:window previous:prevValue current:[reversePrices[index+window-1] floatValue]];
        [values addObject:[NSNumber numberWithFloat:value]];
      }
    }
  }];
  return [[[values copy] reverseObjectEnumerator] allObjects];
}

- (NSArray *)generateEMA:(NSInteger)window {
  return [self exponentialMovingAverageOf:_allPrices withWindow:window];
}


#pragma mark -
#pragma mark RSI

- (CGFloat)rsi:(CGFloat)averageLoss averageGain:(CGFloat)averageGain {
  CGFloat value = 100*averageGain/(averageGain + averageLoss);
  return value;
}

- (CGFloat)rsiAverageWithWindow:(NSUInteger)window previous:(CGFloat)previous current:(CGFloat)current {
  return ((window - 1)*previous + current)/window;
}

- (CGFloat)exponentialAverageWithWindow:(NSUInteger)window previous:(CGFloat)previous current:(CGFloat)current {
  return ((window - 1)*previous + 2*current)/(window+1);
}

- (void)findRsiOversoldOverboughtRegions:(NSArray *)rsiData {
  __block BOOL inOversoldRegion = NO;
  __block BOOL inOverboughtRegion = NO;
  __block KSDRegion *region;
  __block CGFloat min, max;
  __block CGFloat left, right;
  __block NSMutableArray *oversold = [@[] mutableCopy];
  __block NSMutableArray *overbought = [@[] mutableCopy];
  [rsiData enumerateObjectsUsingBlock:^(NSNumber *rsi, NSUInteger i, BOOL *stop) {
    CGFloat value = [rsi floatValue];
    if (value < rsiOversoldLevel && (inOversoldRegion == NO && inOverboughtRegion == NO)) {
      inOversoldRegion = YES;
      min = i;
      left = [self intersectionWithLevel:rsiOversoldLevel forIndex:i inArray:rsiData];
    } else if (value > rsiOversoldLevel && (inOversoldRegion == YES && inOverboughtRegion == NO)) {
      max = i - 1;
      right = [self intersectionWithLevel:rsiOversoldLevel forIndex:i inArray:rsiData];
      region = [[KSDRegion alloc] initWithLeft:left range:KSDRangeMake(min, max) right:right base:rsiOversoldLevel];
      [oversold addObject:region];
      inOversoldRegion = NO;
    } else if (value > rsiOverboughtLevel  && (inOversoldRegion == NO && inOverboughtRegion == NO)) {
      min = i;
      left = [self intersectionWithLevel:rsiOverboughtLevel forIndex:i inArray:rsiData];
      inOverboughtRegion = YES;
    } else if (value < rsiOverboughtLevel && (inOversoldRegion == NO && inOverboughtRegion == YES)) {
      max = i - 1;
      right = [self intersectionWithLevel:rsiOverboughtLevel forIndex:i inArray:rsiData];
      region = [[KSDRegion alloc] initWithLeft:left range:KSDRangeMake(min, max) right:right base:rsiOverboughtLevel];
      [overbought addObject:region];
      inOverboughtRegion = NO;
    }
  }];
  
  if (inOverboughtRegion == YES) {
    max = rsiData.count - 1;
    right = max;
    region = [[KSDRegion alloc] initWithLeft:left range:KSDRangeMake(min, max) right:right base:rsiOverboughtLevel];
    [overbought addObject:region];
    inOverboughtRegion = NO;
  } else if (inOversoldRegion == YES) {
    max = rsiData.count - 1;
    right = max;
    region = [[KSDRegion alloc] initWithLeft:left range:KSDRangeMake(min, max) right:right base:rsiOversoldLevel];
    [oversold addObject:region];
    inOversoldRegion = NO;
  }
  
 
  _rsiOverboughtRegions = [overbought copy];
  _rsiOversoldRegions = [oversold copy];
}

- (NSArray *)generateRSI:(NSUInteger)periods {
  if (_allPrices.count < 1) {
    return @[];
  }
  
  NSMutableArray *rsi = [@[] mutableCopy];
  NSUInteger start = MIN(_allDates.count - 1, maxDrawCount + periods - 1);
  CGFloat averageLoss = 0.0f;
  CGFloat averageGain = 0.0f;
  unsigned long maxPeriods = MIN(periods, _allDates.count);
  for (int i = 1; i < maxPeriods; ++i) {
    CGFloat diff = [_allPrices[start - i] floatValue] - [_allPrices[start - i + 1] floatValue];
    if (diff < 0.0f) {
      averageLoss -= diff;
    } else {
      averageGain += diff;
    }
  }
  averageLoss /= periods;
  averageGain /= periods;
  
  [rsi addObject:[NSNumber numberWithFloat:[self rsi:averageLoss averageGain:averageGain]]];
  
  for (long i = start - maxPeriods - 1; i > -1; --i) {
    CGFloat diff = [_allPrices[i] floatValue] - [_allPrices[i + 1] floatValue];
    if (diff < 0.0f) {
      averageLoss = [self rsiAverageWithWindow:periods previous:averageLoss current:-diff];
      averageGain = [self rsiAverageWithWindow:periods previous:averageGain current:0];
    } else {
      averageGain = [self rsiAverageWithWindow:periods previous:averageGain current:diff];
      averageLoss = [self rsiAverageWithWindow:periods previous:averageLoss current:0];
    }
    [rsi addObject:[NSNumber numberWithFloat:[self rsi:averageLoss averageGain:averageGain]]];
  }
  
  NSArray *reverseRsi = [[[rsi copy] reverseObjectEnumerator] allObjects];
  
  [self findRsiOversoldOverboughtRegions:reverseRsi];
  
  
  return reverseRsi;
}

- (CGFloat)intersectionWithLevel:(CGFloat)level forIndex:(NSUInteger)i inArray:(NSArray *)data {
  if (i == 0) {
    return 0;
  }
  CGFloat f0 = [data[i] floatValue];
  CGFloat fm = [data[i-1] floatValue];
  
  return i - 1 + (level - fm)/(f0 - fm);
}

- (void) generateRsiLabels {
  _rsiLabels = @[@0, @10, @30, @50, @70, @90];
}

#pragma mark -
#pragma mark MACD
- (NSArray *)generateMacdLine {
  NSArray *emaLongArray = [self generateEMA:macdLongPeriod];
  NSArray *emaShortArray = [self generateEMA:macdShortPeriod];
  
  NSMutableArray *line = [[NSMutableArray alloc] initWithCapacity:emaLongArray.count];
  [emaLongArray enumerateObjectsUsingBlock:^(NSNumber *emaLong, NSUInteger index, BOOL *stop) {
    CGFloat lineValue = [emaLong floatValue] - [emaShortArray[index] floatValue];
    [line addObject:[NSNumber numberWithFloat:lineValue]];
  }];
  return [line copy];
}

- (void)generateMacdLabels {
  CGFloat diff = ceilf(_macdRange.max) - floorf(_macdRange.min);
  if (diff == 0.0f) {
    diff = 1.0f;
  }
  
  const NSUInteger macdLabelDivisions = 8;
  const CGFloat div = diff/macdLabelDivisions;
  
  NSMutableArray *labels = [@[@0] mutableCopy];
  for (int i=1; i <= macdLabelDivisions; ++i) {
    CGFloat value = i*div;
    if (value <= _macdRange.max) {
      [labels addObject:[NSNumber numberWithFloat:value]];
    } else {
      if (i == 1) {
        [labels addObject:[NSNumber numberWithFloat:_macdRange.max]];
      }
    }
    if (-value >= _macdRange.min) {
      [labels addObject:[NSNumber numberWithFloat:-value]];
    } else {
      if (i == 1) {
        [labels addObject:[NSNumber numberWithFloat:_macdRange.min]];
      }
    }
  }
  _macdLabels = [labels copy];
}

#pragma mark -
#pragma mark Fractal Dimensions

- (void) generateFractalDimensionLabels {
  _fractalDimensionLabels = @[@1.2, @1.4, @1.6, @1.8];
}

- (NSArray *)generateFractalDimensions:(NSArray *)data {
  
  if (data.count < 2*fractalDimensionHalfPeriod) {
    return @[];
  }
  
  NSMutableArray *fractalDimensions = [@[] mutableCopy];
  KSDFractalDimensionMinMax *firstHalfMinMax = [[KSDFractalDimensionMinMax alloc] initWithArray:data
                                                                                     startIndex:0
                                                                                         period:fractalDimensionHalfPeriod];
  KSDFractalDimensionMinMax *secondHalfMinMax = [[KSDFractalDimensionMinMax alloc] initWithArray:data
                                                                                     startIndex:fractalDimensionHalfPeriod-1
                                                                                         period:fractalDimensionHalfPeriod];
  
  NSUInteger count = data.count - 2*fractalDimensionHalfPeriod;
  for (int i=0; i<count; ++i) {
    [firstHalfMinMax calculate];
    [secondHalfMinMax calculate];
    float minMax = MIN(firstHalfMinMax.max, secondHalfMinMax.max);
    float maxMin = MAX(firstHalfMinMax.min, secondHalfMinMax.min);
    float maxMax = MAX(firstHalfMinMax.max, secondHalfMinMax.max);
    float minMin = MIN(firstHalfMinMax.min, secondHalfMinMax.min);
    float fractalDimension = 1 + log2f(1 + (minMax - maxMin)/(maxMax - minMin));
    [fractalDimensions addObject:@(fractalDimension)];
  }
  return [self exponentialMovingAverageOf:fractalDimensions withWindow:10];
}

#pragma mark -
#pragma Add Current Data

- (void)addCurrentData:(NSArray *)data forDate:(NSString *)dateString {
  [_allDates insertObject:dateString atIndex:0];
  [_allPrices insertObject:data[3] atIndex:0];
  [_allOpen insertObject:data[0] atIndex:0];
  [_allHigh insertObject:data[1] atIndex:0];
  [_allLow insertObject:data[2] atIndex:0];
  [_allClose insertObject:data[3] atIndex:0];
  [self calculateDerivedData];
}

- (void)updateCurrentData:(NSArray *)data {
  _allPrices[0] = data[3];
  _allOpen[0] = data[0];
  _allHigh[0] = data[1];
  _allLow[0] = data[2];
  _allClose[0] = data[3];
  [self calculateDerivedData];
}
@end
