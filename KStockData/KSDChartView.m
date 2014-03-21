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
  CGContextTranslateCTM(context, 0.0, rect.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  
  CGContextSetLineWidth(context, 2.0);
  CGContextSetLineCap(context, kCGLineCapRound);
  
  CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
  CGContextMoveToPoint(context, 30, 30);
  CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - 30, rect.origin.y + rect.size.height - 30);
  CGContextStrokePath(context);
}

@end
