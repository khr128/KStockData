//
//  KSDRegion.m
//  KStockData
//
//  Created by khr on 3/25/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDRegion.h"

@implementation KSDRegion
- (instancetype)initWithLeft:(CGFloat)left range:(KSDRange)range right:(CGFloat)right base:(CGFloat)base{
  if (self = [super init]) {
    _left = left;
    _range = range;
    _right = right;
    _base = base;
  }
  return self;
}
@end
