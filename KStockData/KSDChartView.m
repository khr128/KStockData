//
//  KSDChartView.m
//  KStockData
//
//  Created by khr on 3/21/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDChartView.h"
#import "KSDChartData.h"

#define KDS_CHART_FRAME_MARGIN 30

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
  CGContextTranslateCTM(context, KDS_CHART_FRAME_MARGIN, KDS_CHART_FRAME_MARGIN);
  
  //Draw frame
  CGFloat chartWidth = self.frame.size.width - 2*KDS_CHART_FRAME_MARGIN;
  CGFloat chartHeight = self.frame.size.height - 2*KDS_CHART_FRAME_MARGIN;

  CGContextSetLineWidth(context, 2.0);
  CGContextAddRect(context, CGRectMake(0, 0, chartWidth, chartHeight));
  CGContextStrokePath(context);
 
  //Draw data
  CGFloat dataWidth = self.data.timeRange.max - self.data.timeRange.min;
  CGFloat dataHeight = self.data.priceRange.max - self.data.priceRange.min;
  
  CGFloat lineScale = (fabsf(chartWidth) + fabsf(chartHeight))/(fabsf(dataWidth) + fabsf(dataHeight));
  CGFloat xScale = chartWidth/dataWidth;
  CGFloat yScale = chartHeight/dataHeight;
  
  CGContextScaleCTM(context, xScale, yScale);
  CGContextTranslateCTM(context, -self.data.timeRange.min, -self.data.priceRange.min);
 
  CGContextBeginPath(context);
  CGContextSetLineWidth(context, 0.5/lineScale);
  
  CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
  int count = self.data.prices.count;
  CGContextMoveToPoint(context, count-1, [self.data.prices[0] floatValue]);
  for (int i=1; i < count; ++i) {
    CGContextAddLineToPoint(context, count-i-1, [self.data.prices[i] floatValue]);
  }
  CGContextStrokePath(context);
}

@end
