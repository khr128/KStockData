//
//  KSDFractalDimensionMinMax.h
//  KStockData
//
//  Created by khr on 4/3/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSDFractalDimensionMinMax : NSObject
- (id)initWithArray:(NSArray *)data startIndex:(NSUInteger)startIndex period:(NSUInteger)period;
- (void)calculate;

@property (nonatomic, assign, readonly) float min;
@property (nonatomic, assign, readonly) float max;
@end
