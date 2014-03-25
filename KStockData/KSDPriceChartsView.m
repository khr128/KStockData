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

- (void)drawHighLowBarsWithWidth:(CGFloat)lineWidth context:(CGContextRef)context count:(long)count
{
  CGContextSetLineWidth(context, lineWidth);
  CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
  
  for (int i=0; i < count; ++i) {
    CGContextMoveToPoint(context, count-i-1, [self.data.low[i] floatValue]);
    CGContextAddLineToPoint(context, count-i-1, [self.data.high[i] floatValue]);
  }
  
  CGContextStrokePath(context);
}

- (void)drawOpenCloseCandlesInContext:(CGContextRef)context candleWidth:(CGFloat)candleWidth count:(long)count
{
  CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
  
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

- (void)drawPriceLabelsAndGridLines:(CGAffineTransform)scaledTransform count:(long)count context:(CGContextRef)context
{
  //Transform coord to make drawing independent of scale.
  NSMutableArray *transformedPriceLabels = [[NSMutableArray alloc] initWithCapacity:self.data.priceLabels.count];
  CGFloat transformedLabelX = 0;
  CGFloat transformedLabelXRight = 0;
  
  CGPoint transformedPoint = CGPointApplyAffineTransform(CGPointMake(count, [self.data.priceLabels[0] floatValue]), scaledTransform);
  transformedLabelXRight = transformedPoint.x / self.contentScaleFactor;
  
  for (NSNumber *labelValue in self.data.priceLabels) {
    transformedPoint = CGPointApplyAffineTransform(CGPointMake(0, [labelValue floatValue]), scaledTransform);
    [transformedPriceLabels addObject:[NSNumber numberWithFloat:transformedPoint.y/self.contentScaleFactor]];
    
    transformedLabelX = transformedPoint.x;
  }
  
  transformedLabelX /= self.contentScaleFactor;
  
  
  //Draw horizontal grid lines
  long labelCount = self.data.priceLabels.count;
  
  CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
  CGContextSetLineWidth(context, 0.5);
  CGFloat dashArray[] = {3, 5};
  CGContextSetLineDash(context, 0, dashArray, 2);
  
  for (int i=0; i < labelCount; ++i) {
    CGFloat labelValue = [transformedPriceLabels[i] floatValue];
    CGContextMoveToPoint(context, transformedLabelX, labelValue);
    CGContextAddLineToPoint(context, transformedLabelXRight, labelValue);
  }
  
  CGContextStrokePath(context);
  
  //Draw price-axis labels
  
  for (int i=0; i<labelCount; ++i) {
    NSNumber *value = self.data.priceLabels[i];
    NSString *label = [value stringValue];
    [self drawString:label at:CGPointMake(transformedLabelX + 10, [transformedPriceLabels[i] floatValue]+2) inContext:context];
  }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  CGContextRef context = [self getTranslatedContext:rect];
  [self computeChartDimensions];
  [self drawChartFrameInContext:context chartHeight:self.chartHeight chartWidth:self.chartWidth];
  
  [self scaleAndTranslateCTM:context withYRange:self.data.priceRange];
  
  long count = self.data.prices.count;
  
  [self drawDataLineWithWidth:0.25/self.lineScale context:context data:self.data.prices color:[UIColor yellowColor]];
  [self drawDataLineWithWidth:0.25/self.lineScale context:context data:self.data.tenDMA color:[UIColor whiteColor]];
  [self drawDataLineWithWidth:0.25/self.lineScale context:context data:self.data.fiftyDMA color:[UIColor blueColor]];
  [self drawDataLineWithWidth:0.25/self.lineScale context:context data:self.data.twoHundredDMA color:[UIColor redColor]];
  [self drawHighLowBarsWithWidth:0.75/self.lineScale context:context count:count];
  [self drawOpenCloseCandlesInContext:context candleWidth:3.75/self.lineScale count:count];
  
  //Remember scaled CTM
  CGAffineTransform scaledTransform = CGContextGetCTM(context);
  
  [self unscaleCTM:context rect:rect];

  [self drawPriceLabelsAndGridLines:scaledTransform count:count context:context];
  [self drawMonthlyLabelsAndGridLines:scaledTransform context:context count:count yRange:self.data.priceRange];
}


@end
