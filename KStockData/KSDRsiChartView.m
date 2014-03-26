//
//  KSDRsiCharcView.m
//  KStockData
//
//  Created by khr on 3/25/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDRsiChartView.h"
#import "KSDChartData.h"
#import "KSDRegion.h"

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
  
  
  //draw overbought region
  CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
  
  long priceCount = self.data.prices.count;
  
  for (KSDRegion *region in self.data.rsiOverboughtRegions) {
    NSUInteger min = (uint)(region.range.min + 0.5);
    NSUInteger max = (uint)(region.range.max + 0.5);
    CGContextMoveToPoint(context, priceCount-region.left-1, 70);
    for (int i=min; i <= max; ++i) {
      CGContextAddLineToPoint(context, priceCount-i-1, [self.data.rsi[i] floatValue]);
    }
    CGContextAddLineToPoint(context, priceCount - region.right - 1, 70);
    CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFill);
  }
  
  //draw oversold region
  CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
  
  for (KSDRegion *region in self.data.rsiOversoldRegions) {
    NSUInteger min = (uint)(region.range.min + 0.5);
    NSUInteger max = (uint)(region.range.max + 0.5);
    CGContextMoveToPoint(context, priceCount-region.left-1, 30);
    for (int i=min; i <= max; ++i) {
      CGContextAddLineToPoint(context, priceCount-i-1, [self.data.rsi[i] floatValue]);
    }
    CGContextAddLineToPoint(context, priceCount - region.right - 1, 30);
    CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFill);
  }

  [self drawDataLineWithWidth:0.5/self.lineScale context:context data:self.data.rsi color:[UIColor greenColor]];
  
  //Remember scaled CTM
  CGAffineTransform scaledTransform = CGContextGetCTM(context);
  
  [self unscaleCTM:context rect:rect];
  
  [self drawValueLabelsAndGridLines:self.data.rsiLabels transform:scaledTransform context:context];
  [self drawMonthlyLabelsAndGridLines:scaledTransform context:context yRange:self.data.rsiRange];
}

@end
