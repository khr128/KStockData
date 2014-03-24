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

- (void)drawChartFrameInContext:(CGContextRef)context chartHeight:(CGFloat)chartHeight chartWidth:(CGFloat)chartWidth
{
  //Draw frame 
  CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
  
  CGContextSetLineWidth(context, 2.0);
  CGContextAddRect(context, CGRectMake(0, 0, chartWidth, chartHeight));
  CGContextStrokePath(context);
}

- (void)drawDataLineWithWidth:(CGFloat)lineWidth
                      context:(CGContextRef)context
                         data:(NSArray *)data
                        color:(UIColor *)color
{
  CGContextSetLineWidth(context, lineWidth);
  
  CGContextSetStrokeColorWithColor(context, color.CGColor);
  
  long count = data.count;
  long priceCount = self.data.prices.count;
  CGContextMoveToPoint(context, priceCount-1, [data[0] floatValue]);
  for (int i=1; i < count; ++i) {
    CGContextAddLineToPoint(context, priceCount-i-1, [data[i] floatValue]);
  }
  CGContextStrokePath(context);
}

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

- (void)drawOpenCloseCandlesinContext:(CGContextRef)context candleWidth:(CGFloat)candleWidth count:(long)count
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
  
  CGFloat chartWidth = self.frame.size.width - 2*KSD_CHART_FRAME_MARGIN;
  CGFloat chartHeight = self.frame.size.height - 2*KSD_CHART_FRAME_MARGIN;
 
  
  [self drawChartFrameInContext:context chartHeight:chartHeight chartWidth:chartWidth];
  
 
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
  

  [self drawDataLineWithWidth:0.25/lineScale context:context data:self.data.prices color:[UIColor yellowColor]];
  [self drawDataLineWithWidth:0.25/lineScale context:context data:self.data.tenDMA color:[UIColor whiteColor]];
  [self drawHighLowBarsWithWidth:0.75/lineScale context:context count:count];
  [self drawOpenCloseCandlesinContext:context candleWidth:3.75/lineScale count:count];
  
  //Draw y-axis labels
  
  //Transform coord to make drawing independent of scale.
  NSMutableArray *transformedPriceLabels = [[NSMutableArray alloc] initWithCapacity:self.data.priceLabels.count];
  CGFloat transformedLabelX = 0;
  CGFloat transformedLabelXRight = 0;
  CGAffineTransform scaledTransform = CGContextGetCTM(context);
  
  __block CGPoint transformedPoint = CGPointApplyAffineTransform(CGPointMake(count, [self.data.priceLabels[0] floatValue]), scaledTransform);
  transformedLabelXRight = transformedPoint.x / self.contentScaleFactor;

  for (NSNumber *labelValue in self.data.priceLabels) {
    transformedPoint = CGPointApplyAffineTransform(CGPointMake(0, [labelValue floatValue]), scaledTransform);
    [transformedPriceLabels addObject:[NSNumber numberWithFloat:transformedPoint.y/self.contentScaleFactor]];
    
    transformedLabelX = transformedPoint.x;
   }
  
  transformedLabelX /= self.contentScaleFactor;
  
  //Set unscaled transformation matrix
  CGContextRestoreGState(context);
  CGContextTranslateCTM(context, 0.0, rect.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  
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
  
  //Draw y-axis labels
 
  for (int i=0; i<labelCount; ++i) {
    NSNumber *value = self.data.priceLabels[i];
    NSString *label = [value stringValue];
    [self drawString:label at:CGPointMake(transformedLabelX + 10, [transformedPriceLabels[i] floatValue]+2) inContext:context];
  }
  
  transformedPoint =
  CGPointApplyAffineTransform(CGPointMake(0, (self.data.priceRange.min - unadjustedDataHeight*KSD_TOP_BOTTOM_MARGIN_FRACTION)), scaledTransform);
  CGFloat transformedTimeLabelY = transformedPoint.y/self.contentScaleFactor;
  transformedPoint =
  CGPointApplyAffineTransform(CGPointMake(0, (self.data.priceRange.max + unadjustedDataHeight*KSD_TOP_BOTTOM_MARGIN_FRACTION)), scaledTransform);
  CGFloat transformedTimeLabelYTop = transformedPoint.y/self.contentScaleFactor;
  
  labelCount = self.data.monthLabels.count;

  NSMutableArray *transformedTimeLabels = [[NSMutableArray alloc] initWithCapacity:labelCount];
  [self.data.monthLabels enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *label, BOOL *stop) {
    transformedPoint = CGPointApplyAffineTransform(CGPointMake(count - [key floatValue] - 1, 0), scaledTransform);
    CGFloat tx = transformedPoint.x/self.contentScaleFactor;
    [transformedTimeLabels addObject:[NSNumber numberWithFloat:tx]];
    
    [self drawString:label at:CGPointMake(tx, KSD_CHART_FRAME_MARGIN/2-2) inContext:context];
  }];
  
  for (int i=0; i < labelCount; ++i) {
    CGFloat labelValue = [transformedTimeLabels[i] floatValue];
    CGContextMoveToPoint(context, labelValue, transformedTimeLabelY);
    CGContextAddLineToPoint(context, labelValue, transformedTimeLabelYTop);
  }
  
  CGContextStrokePath(context);
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
