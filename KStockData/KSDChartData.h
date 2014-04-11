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
- (id)initWithColumns:(NSDictionary *)columns andSymbol:(NSString *)symbol;
- (NSArray *)generateSMA:(NSInteger)window;
- (void)addCurrentData:(NSArray *)data forDate:(NSString *)dateString;
- (void)calculateDerivedData;

@property (readonly, strong, nonatomic) NSString *symbol;

@property (readonly, nonatomic) KSDRange timeRange;
@property (readonly, nonatomic) KSDRange priceRange;

@property (strong, nonatomic, readonly) NSMutableArray *dates;
@property (strong, nonatomic, readonly) NSDictionary *monthLabels;
@property (strong, nonatomic, readonly) NSMutableArray *prices;
@property (strong, nonatomic, readonly) NSArray *priceLabels;
@property (strong, nonatomic, readonly) NSArray *tenDMA;
@property (strong, nonatomic, readonly) NSArray *fiftyDMA;
@property (strong, nonatomic, readonly) NSArray *twoHundredDMA;
@property (strong, nonatomic, readonly) NSMutableArray *open;
@property (strong, nonatomic, readonly) NSMutableArray *close;

@property (strong, nonatomic, readonly) NSMutableArray *high;
@property (strong, nonatomic, readonly) NSMutableArray *low;

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

//Fractal Dimension
@property (strong, nonatomic, readonly) NSArray *fractalDimensions;
@property (strong, nonatomic, readonly) NSArray *fractalDimensionLabels;
@property (readonly, assign, nonatomic) KSDRange fractalDimensionRange;

@end
