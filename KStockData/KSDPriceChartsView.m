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


- (void)drawHighLowBarsWithWidth: (CGFloat)lineWidth
                         context: (CGContextRef)context
                          yRange: (KSDRange)yRange
{
  long count = self.data.prices.count;
  for (int i=0; i < count; ++i) {
    CGContextMoveToPoint(context, count-i-1, [self.data.low[i] floatValue]);
    CGContextAddLineToPoint(context, count-i-1, [self.data.high[i] floatValue]);
  }
  
  [self strokePathWithoutScaling:context lineWidth:lineWidth color:[UIColor whiteColor] yRange:yRange];
}

- (void)drawOpenCloseCandlesInContext: (CGContextRef)context
                                width: (CGFloat)candleWidth
                               yRange: (KSDRange)yRange
{
  long count = self.data.prices.count;
  for (int i=0; i < count; ++i) {
    CGFloat open = [self.data.open[i] floatValue];
    CGFloat close = [self.data.close[i] floatValue];
    if (close < open) {
      CGContextMoveToPoint(context, count-i-1, close);
      CGContextAddLineToPoint(context, count-i-1, open);
    }
  }
  
  [self strokePathWithoutScaling:context lineWidth:candleWidth color:[UIColor redColor] yRange:yRange];
  
  for (int i=0; i < count; ++i) {
    CGFloat open = [self.data.open[i] floatValue];
    CGFloat close = [self.data.close[i] floatValue];
    if (close > open) {
      CGContextMoveToPoint(context, count-i-1, open);
      CGContextAddLineToPoint(context, count-i-1, close);
    }
  }
  
  [self strokePathWithoutScaling:context lineWidth:candleWidth color:[UIColor greenColor] yRange:yRange];
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
  
  
  [self drawDataLineWithWidth: 1.0f
                      context: context
                         data: self.data.prices
                        color: [UIColor yellowColor]
                       yRange: self.data.priceRange];
  [self drawDataLineWithWidth: 1.0f
                      context: context
                         data: self.data.tenDMA
                        color: [UIColor whiteColor]
                       yRange:self.data.priceRange];
  [self drawDataLineWithWidth: 1.0f
                      context: context
                         data: self.data.fiftyDMA
                        color: [UIColor blueColor]
                       yRange: self.data.priceRange];
  [self drawDataLineWithWidth: 1.0f
                      context: context
                         data: self.data.twoHundredDMA
                        color: [UIColor redColor]
                       yRange: self.data.priceRange];
  
  [self drawHighLowBarsWithWidth:0.5 context:context yRange:self.data.priceRange];
  [self drawOpenCloseCandlesInContext:context width:2.5f yRange:self.data.priceRange];
  
  //Remember scaled CTM
  CGAffineTransform scaledTransform = CGContextGetCTM(context);
  
  [self unscaleCTM:context rect:rect];

  [self drawValueLabelsAndGridLines:self.data.priceLabels transform:scaledTransform context:context];
  [self drawMonthlyLabelsAndGridLines:scaledTransform context:context yRange:self.data.priceRange];
}


@end
