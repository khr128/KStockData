//
//  KSDChartView.m
//  KStockData
//
//  Created by khr on 3/21/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDChartView.h"
#import "KSDChartData.h"

#define KSD_CHART_FRAME_MARGIN 30
#define KSD_TOP_BOTTOM_MARGIN_FRACTION 0.04

@implementation KSDChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setData:(KSDChartData *)data {
  _data = data;
  [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextTranslateCTM(context, 0.0, rect.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextTranslateCTM(context, KSD_CHART_FRAME_MARGIN, KSD_CHART_FRAME_MARGIN);
  
  //Draw frame
  CGFloat chartWidth = self.frame.size.width - 2*KSD_CHART_FRAME_MARGIN;
  CGFloat chartHeight = self.frame.size.height - 2*KSD_CHART_FRAME_MARGIN;
  
  
  CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);

  CGContextSetLineWidth(context, 2.0);
  CGContextAddRect(context, CGRectMake(0, 0, chartWidth, chartHeight));
  CGContextStrokePath(context);
 
  CGFloat dataWidth = self.data.timeRange.max - self.data.timeRange.min;
  CGFloat unadjustedDataHeight = self.data.priceRange.max - self.data.priceRange.min;
  CGFloat dataHeight = unadjustedDataHeight*(1 + 2*KSD_TOP_BOTTOM_MARGIN_FRACTION);
  
  CGFloat lineScale = (fabsf(chartWidth) + fabsf(chartHeight))/(fabsf(dataWidth) + fabsf(dataHeight));
  CGFloat xScale = chartWidth/dataWidth;
  CGFloat yScale = chartHeight/dataHeight;
  
  CGContextScaleCTM(context, xScale, yScale);
  CGContextTranslateCTM(context,
                        -self.data.timeRange.min,
                        -(self.data.priceRange.min - unadjustedDataHeight*KSD_TOP_BOTTOM_MARGIN_FRACTION));
  
  long count = self.data.prices.count;

  //Draw data
  CGContextSetLineWidth(context, 0.25/lineScale);
  
  CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
  
  CGContextMoveToPoint(context, count-1, [self.data.prices[0] floatValue]);
  for (int i=1; i < count; ++i) {
    CGContextAddLineToPoint(context, count-i-1, [self.data.prices[i] floatValue]);
  }
  CGContextStrokePath(context);
  
  //Draw high/low
  CGContextSetLineWidth(context, 0.75/lineScale);
  CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
  
  for (int i=0; i < count; ++i) {
    CGContextMoveToPoint(context, count-i-1, [self.data.low[i] floatValue]);
    CGContextAddLineToPoint(context, count-i-1, [self.data.high[i] floatValue]);
  }
  
  CGContextStrokePath(context);
 
  //Draw candles
  CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
  
  CGFloat candleWidth = 3.75/lineScale;
  for (int i=0; i < count; ++i) {
    CGFloat open = [self.data.open[i] floatValue];
    CGFloat close = [self.data.close[i] floatValue];
    if (close > open) {
      CGFloat candleHeight = fabsf(open - close);
      CGContextAddRect(context, CGRectMake(count - i - 1 - candleWidth/2,
                                           open,
                                           candleWidth,
                                           candleHeight));
    }
  }
  
  CGContextDrawPath(context, kCGPathEOFill);
  
  CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
  
  for (int i=0; i < count; ++i) {
    CGFloat open = [self.data.open[i] floatValue];
    CGFloat close = [self.data.close[i] floatValue];
    if (close < open) {
      CGFloat candleHeight = fabsf(open - close);
      CGContextAddRect(context, CGRectMake(count - i - 1 - candleWidth/2,
                                           close,
                                           candleWidth,
                                           candleHeight));
    }
  }
  
  CGContextDrawPath(context, kCGPathEOFill);
}

@end
