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
  
  //Remember scaled CTM
  CGAffineTransform scaledTransform = CGContextGetCTM(context);
  
  [self unscaleCTM:context rect:rect];
  
  [self drawValueLabelsAndGridLines:self.data.macdLabels transform:scaledTransform context:context];
  [self drawMonthlyLabelsAndGridLines:scaledTransform context:context yRange:self.data.macdRange];
}


@end
