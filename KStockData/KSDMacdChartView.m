//
//  KSDMacdChartView.m
//  KStockData
//
//  Created by khr on 3/29/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDMacdChartView.h"
#import "KSDChartData.h"

@implementation KSDMacdChartView

- (void)drawHistogramInContext: (CGContextRef)context
                                width: (CGFloat)candleWidth
                               yRange: (KSDRange*)yRange
{
  long count = self.data.macdLine.count;
  long priceCount = self.data.prices.count;

  for (int i=0; i < count; ++i) {
    CGFloat signal = [self.data.macdSignalLine[i] floatValue];
    CGFloat line = [self.data.macdLine[i] floatValue];
    if (line < signal) {
      CGContextMoveToPoint(context, priceCount-i-1, 0);
      CGContextAddLineToPoint(context, priceCount-i-1, signal - line);
    }
  }
  
  [self strokePathWithoutScaling:context lineWidth:candleWidth color:[UIColor greenColor] yRange:yRange];
  
  for (int i=0; i < count; ++i) {
    CGFloat signal = [self.data.macdSignalLine[i] floatValue];
    CGFloat line = [self.data.macdLine[i] floatValue];
    if (line > signal) {
      CGContextMoveToPoint(context, priceCount-i-1, 0);
      CGContextAddLineToPoint(context, priceCount-i-1, signal - line);
    }
  }
  
  [self strokePathWithoutScaling:context lineWidth:candleWidth color:[UIColor redColor] yRange:yRange];
}

- (void)drawRect:(CGRect)rect
{
 CGContextRef context = [self getTranslatedContext:rect];
 [self computeChartDimensions];
 [self drawChartFrameInContext:context chartHeight:self.chartHeight chartWidth:self.chartWidth];
 
  [self drawString:@"MACD(9 12 26)"
                at:CGPointMake(self.chartWidth/2, self.chartHeight + 3)
     withAlignment:NSTextAlignmentCenter
         inContext:context];
  
  [self scaleAndTranslateCTM:context withYRange:self.data.macdRange];
  
  [self drawDataLineWithWidth: 1.0f
                      context: context
                         data: self.data.macdLine
                        color: [UIColor greenColor]
                       yRange: self.data.macdRange];
  [self drawDataLineWithWidth: 1.0f
                      context: context
                         data: self.data.macdSignalLine
                        color: [UIColor redColor]
                       yRange: self.data.macdRange];
  
  [self drawHistogramInContext:context width:2 yRange:self.data.macdRange];
  
  //Remember scaled CTM
  CGAffineTransform scaledTransform = CGContextGetCTM(context);
  
  [self unscaleCTM:context rect:rect];
  
  [self drawValueLabelsAndGridLines:self.data.macdLabels transform:scaledTransform context:context];
  [self drawMonthlyLabelsAndGridLines:scaledTransform context:context yRange:self.data.macdRange];
}


@end
