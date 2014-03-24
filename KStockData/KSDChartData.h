//
//  KSDChartData.h
//  KStockData
//
//  Created by khr on 3/22/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct KSDRange {
  float min;
  float max;
} KSDRange;

@interface KSDChartData : NSObject
- (id)initWithColumns:(NSDictionary *)columns;
- (NSArray *)generateDMA:(NSInteger)window;

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

@end
