//
//  KSDRsiCharcView.m
//  KStockData
//
//  Created by khr on 3/25/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDRsiChartView.h"
#import "KSDChartData.h"

@implementation KSDRsiChartView

- (void)drawRect:(CGRect)rect
{
  CGContextRef context = [self getTranslatedContext:rect];
  [self computeChartDimensions];
  [self drawChartFrameInContext:context chartHeight:self.chartHeight chartWidth:self.chartWidth];
  
  [self drawString:[NSString stringWithFormat:@"RSI(14)  %0.2f", [self.data.rsi[0] floatValue]]
                at:CGPointMake(self.chartWidth/2, self.chartHeight + 3)
     withAlignment:NSTextAlignmentCenter
         inContext:context];
  
  [self scaleAndTranslateCTM:context withYRange:self.data.rsiRange];
  
  [self highlightRegions:self.data.rsiOverboughtRegions withColor:[UIColor blueColor] context:context];
  [self highlightRegions:self.data.rsiOversoldRegions withColor:[UIColor yellowColor] context:context];
  
  [self drawDataLineWithWidth: 1.0f
                      context: context
                         data: self.data.rsi
                        color: [UIColor greenColor]
                       yRange: self.data.rsiRange];
  
  //Remember scaled CTM
  CGAffineTransform scaledTransform = CGContextGetCTM(context);
  
  [self unscaleCTM:context rect:rect];
  
  [self drawValueLabelsAndGridLines:self.data.rsiLabels transform:scaledTransform context:context];
  [self drawMonthlyLabelsAndGridLines:scaledTransform context:context yRange:self.data.rsiRange];
}

@end
