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

@property (readonly, nonatomic) KSDRange timeRange;
@property (readonly, nonatomic) KSDRange priceRange;
@property (readonly, nonatomic, assign) CGFloat maxHigh;
@property (readonly, nonatomic, assign) CGFloat minLow;

@property (strong, nonatomic, readonly) NSArray *dates;
@property (strong, nonatomic, readonly) NSArray *prices;
@property (strong, nonatomic, readonly) NSArray *open;
@property (strong, nonatomic, readonly) NSArray *close;

@property (strong, nonatomic, readonly) NSArray *high;
@property (strong, nonatomic, readonly) NSArray *low;

@end
