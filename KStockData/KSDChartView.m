//
//  KSDChartView.m
//  KStockData
//
//  Created by khr on 3/21/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDChartView.h"

@implementation KSDChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, 2.0);
  CGContextSetLineCap(context, kCGLineCapRound);
  
  CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
  CGContextMoveToPoint(context, 30, 30);
  CGContextAddLineToPoint(context, 300, 400);
  CGContextStrokePath(context);
}

@end
