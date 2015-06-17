//
//  KSDRegion.h
//  KStockData
//
//  Created by khr on 3/25/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KStockData-Swift.h"

@interface KSDRegion : NSObject
@property (nonatomic, assign, readonly) CGFloat left;
@property (nonatomic, strong, readonly) KSDRange* range;
@property (nonatomic, assign, readonly) CGFloat right;
@property (nonatomic, assign, readonly) CGFloat base;

- (instancetype)initWithLeft:(CGFloat)left range:(KSDRange*)range right:(CGFloat)right base:(CGFloat)base;
@end
