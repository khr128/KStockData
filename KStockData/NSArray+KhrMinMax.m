//
//  NSArray+KhrMinMax.m
//  KStockData
//
//  Created by khr on 3/22/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "NSArray+KhrMinMax.h"

@implementation NSArray (KhrMinMax)
- (float)floatMin {
  if (self.count < 1) {
    return 0;
  }
  
  __block float min = [[self objectAtIndex:0] floatValue];
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_apply(self.count, queue, ^(size_t index){
    float value = [[self objectAtIndex:index] floatValue];
    if (value < min) {
      min = value;
    }
  });
  return min;
}

- (float)floatMax {
  if (self.count < 1) {
    return 0;
  }
  
  __block float max = [[self objectAtIndex:0] floatValue];
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_apply(self.count, queue, ^(size_t index){
    float value = [[self objectAtIndex:index] floatValue];
    if (value > max) {
      max = value;
    }
  });
  return max;
}
@end
