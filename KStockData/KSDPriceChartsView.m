//
//  KSDChartView.m
//  KStockData
//
//  Created by khr on 3/21/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDPriceChartsView.h"
#import "KSDChartData.h"

@implementation KSDPriceChartsView

- (void)drawHighLowBarsWithWidth:(CGFloat)lineWidth context:(CGContextRef)context
{
  CGContextSetLineWidth(context, lineWidth);
  CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
  
  long count = self.data.prices.count;
  for (int i=0; i < count; ++i) {
    CGContextMoveToPoint(context, count-i-1, [self.data.low[i] floatValue]);
    CGContextAddLineToPoint(context, count-i-1, [self.data.high[i] floatValue]);
  }
  
  CGContextStrokePath(context);
}

- (void)drawOpenCloseCandlesInContext:(CGContextRef)context candleWidth:(CGFloat)candleWidth
{
  CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);

  long count = self.data.prices.count;
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
  
  CGContextDrawPath(context, kCGPathFill);
  
  CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
  
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
  
  CGContextDrawPath(context, kCGPathFill);
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef context = [self getTranslatedContext:rect];
  [self computeChartDimensions];
  [self drawChartFrameInContext:context chartHeight:self.chartHeight chartWidth:self.chartWidth];
  
  [self drawString:@"Price History"
                at:CGPointMake(self.chartWidth/2, self.chartHeight + 3)
     withAlignment:NSTextAlignmentCenter
         inContext:context];
  
  [self scaleAndTranslateCTM:context withYRange:self.data.priceRange];
  
  
  [self drawDataLineWithWidth:0.25/self.lineScale context:context data:self.data.prices color:[UIColor yellowColor]];
  [self drawDataLineWithWidth:0.25/self.lineScale context:context data:self.data.tenDMA color:[UIColor whiteColor]];
  [self drawDataLineWithWidth:0.25/self.lineScale context:context data:self.data.fiftyDMA color:[UIColor blueColor]];
  [self drawDataLineWithWidth:0.25/self.lineScale context:context data:self.data.twoHundredDMA color:[UIColor redColor]];
  [self drawHighLowBarsWithWidth:0.75/self.lineScale context:context];
  [self drawOpenCloseCandlesInContext:context candleWidth:3.75/self.lineScale];
  
  //Remember scaled CTM
  CGAffineTransform scaledTransform = CGContextGetCTM(context);
  
  [self unscaleCTM:context rect:rect];

  [self drawValueLabelsAndGridLines:self.data.priceLabels transform:scaledTransform context:context];
  [self drawMonthlyLabelsAndGridLines:scaledTransform context:context yRange:self.data.priceRange];
}


@end
