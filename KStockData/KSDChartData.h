//
//  KSDChartData.h
//  KStockData
//
//  Created by khr on 3/22/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSDRange.h"

@interface KSDChartData : NSObject
- (id)initWithColumns:(NSDictionary *)columns;
- (NSArray *)generateSMA:(NSInteger)window;

@property (readonly, nonatomic) KSDRange timeRange;
@property (readonly, nonatomic) KSDRange priceRange;

@property (strong, nonatomic, readonly) NSArray *dates;
@property (strong, nonatomic, readonly) NSDictionary *monthLabels;
@property (strong, nonatomic, readonly) NSArray *prices;
@property (strong, nonatomic, readonly) NSArray *priceLabels;
@property (strong, nonatomic, readonly) NSArray *tenDMA;
@property (strong, nonatomic, readonly) NSArray *fiftyDMA;
@property (strong, nonatomic, readonly) NSArray *twoHundredDMA;
@property (strong, nonatomic, readonly) NSArray *open;
@property (strong, nonatomic, readonly) NSArray *close;

@property (strong, nonatomic, readonly) NSArray *high;
@property (strong, nonatomic, readonly) NSArray *low;

//Oscillators and indicators
//RSI
@property (strong, nonatomic, readonly) NSArray *rsi;
@property (strong, nonatomic, readonly) NSArray *rsiLabels;
@property (readonly, nonatomic) KSDRange rsiRange;
@property (readonly, nonatomic) NSArray *rsiOversoldRegions;
@property (readonly, nonatomic) NSArray *rsiOverboughtRegions;

//MACD
@property (strong, nonatomic, readonly) NSArray *macdLine;
@property (strong, nonatomic, readonly) NSArray *macdSignalLine;
@property (assign, nonatomic, readonly) KSDRange macdRange;
@property (strong, nonatomic, readonly) NSArray *macdLabels;
@end
