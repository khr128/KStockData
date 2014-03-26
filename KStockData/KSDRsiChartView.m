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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef context = [self getTranslatedContext:rect];
  [self computeChartDimensions];
  [self drawChartFrameInContext:context chartHeight:self.chartHeight chartWidth:self.chartWidth];
  [self scaleAndTranslateCTM:context withYRange:self.data.rsiRange];
  
  [self drawDataLineWithWidth:0.5/self.lineScale context:context data:self.data.rsi color:[UIColor greenColor]];
  
  //Remember scaled CTM
  CGAffineTransform scaledTransform = CGContextGetCTM(context);
  
  [self unscaleCTM:context rect:rect];
  
  [self drawValueLabelsAndGridLines:self.data.rsiLabels transform:scaledTransform context:context];
  [self drawMonthlyLabelsAndGridLines:scaledTransform context:context yRange:self.data.rsiRange];
}

@end
