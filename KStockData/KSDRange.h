//
//  KSDRange.h
//  KStockData
//
//  Created by khr on 3/25/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#ifndef KStockData_KSDRange_h
#define KStockData_KSDRange_h

typedef struct KSDRange {
  float min;
  float max;
} KSDRange;

KSDRange KSDRangeMake(float min, float max);

#endif
