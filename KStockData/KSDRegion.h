//
//  KSDRegion.h
//  KStockData
//
//  Created by khr on 3/25/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSDRange.h"

@interface KSDRegion : NSObject
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) KSDRange range;
@property (nonatomic, assign) CGFloat right;

- (instancetype)initWithLeft:(CGFloat)left range:(KSDRange)range right:(CGFloat)right;
@end
