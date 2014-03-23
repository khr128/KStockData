//
//  KSDChartView.m
//  KStockData
//
//  Created by khr on 3/21/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDChartView.h"
#import "KSDChartData.h"
@import CoreText;

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
  CGContextSaveGState(context);
  
  CGContextTranslateCTM(context, 0.0, rect.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextTranslateCTM(context, KSD_CHART_FRAME_MARGIN, KSD_CHART_FRAME_MARGIN);
  
  //Draw frame
  CGFloat chartWidth = self.frame.size.width - 2*KSD_CHART_FRAME_MARGIN;
  CGFloat chartHeight = self.frame.size.height - 2*KSD_CHART_FRAME_MARGIN;
  
  
  CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);

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
  
  //Draw y-axis labels
  
  //Transform coord to make drawing independent of scale.
  NSMutableArray *transformedPriceLabels = [[NSMutableArray alloc] initWithCapacity:self.data.priceLabels.count];
  CGFloat transformedLabelX = 0;
  CGFloat transformedLabelXRight = 0;
  CGAffineTransform transform = CGContextGetCTM(context);
  
  CGPoint transformedPoint = CGPointApplyAffineTransform(CGPointMake(count, [self.data.priceLabels[0] floatValue]), transform);
  transformedLabelXRight = transformedPoint.x / self.contentScaleFactor;

  for (NSNumber *labelValue in self.data.priceLabels) {
    transformedPoint = CGPointApplyAffineTransform(CGPointMake(0, [labelValue floatValue]), transform);
    [transformedPriceLabels addObject:[NSNumber numberWithFloat:transformedPoint.y/self.contentScaleFactor]];
    
    transformedLabelX = transformedPoint.x;
   }
  
  transformedLabelX /= self.contentScaleFactor;
  
  //Set unscaled transformation matrix
  CGContextRestoreGState(context);
  CGContextTranslateCTM(context, 0.0, rect.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  
  //Draw horizontal grid lines
  int labelCount = self.data.priceLabels.count;
  
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
  
  //Draw y-axis labels
 
  for (int i=0; i<labelCount; ++i) {
    NSNumber *value = self.data.priceLabels[i];
    NSString *label = [value stringValue];
    [self drawString:label at:CGPointMake(transformedLabelX + 10, [transformedPriceLabels[i] floatValue]+2) inContext:context];
  }
  
}

- (void)drawString:(NSString *)label at:(CGPoint)position inContext:(CGContextRef)context {
  // Prepare font
  CTFontRef font = CTFontCreateWithName(CFSTR("TimesNewRomanPSMT"), 18, NULL);
  
  // Create an attributed string
  CFStringRef keys[] = { kCTFontAttributeName, kCTForegroundColorAttributeName };
  CFTypeRef values[] = { font, [UIColor whiteColor].CGColor };
  CFDictionaryRef attr = CFDictionaryCreate(NULL,
                                            (const void **)&keys,
                                            (const void **)&values,
                                            sizeof(keys) / sizeof(keys[0]),
                                            &kCFTypeDictionaryKeyCallBacks,
                                            &kCFTypeDictionaryValueCallBacks);
  CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, (CFStringRef)label, attr);
  CFRelease(attr);
  
  // Draw the string
  CTLineRef line = CTLineCreateWithAttributedString(attrString);
  CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//  CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
  
  CGContextSetTextPosition(context, position.x, position.y);
  CTLineDraw(line, context);
  
  // Clean up
  CFRelease(line);
  CFRelease(attrString);
  CFRelease(font);
}

@end
