//
//  KSDFractalDimensionChartView.m
//  KStockData
//
//  Created by khr on 4/3/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDFractalDimensionChartView.h"
#import "KSDChartData.h"

@implementation KSDFractalDimensionChartView

- (void)drawRect:(CGRect)rect
{
  CGContextRef context = [self getTranslatedContext:rect];
  [self computeChartDimensions];
  [self drawChartFrameInContext:context chartHeight:self.chartHeight chartWidth:self.chartWidth];
  
  [self drawString:[NSString stringWithFormat:@"Fractal Dimension (30)  %0.2f", [self.data.fractalDimensions[0] floatValue]]
                at:CGPointMake(self.chartWidth/2, self.chartHeight + 3)
     withAlignment:NSTextAlignmentCenter
         inContext:context];
  
  
  [self scaleAndTranslateCTM:context withYRange:self.data.fractalDimensionRange];
  
  [self drawDataLineWithWidth: 1.0f
                      context: context
                         data: self.data.fractalDimensions
                        color: [UIColor greenColor]
                       yRange: self.data.fractalDimensionRange];
  
  //Remember scaled CTM
  CGAffineTransform scaledTransform = CGContextGetCTM(context);
  
  [self unscaleCTM:context rect:rect];
  
  [self drawValueLabelsAndGridLines:self.data.fractalDimensionLabels transform:scaledTransform context:context];
  [self drawMonthlyLabelsAndGridLines:scaledTransform context:context yRange:self.data.fractalDimensionRange];
}

@end
