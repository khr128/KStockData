//
//  KSDPlotView.m
//  KStockData
//
//  Created by khr on 3/25/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDPlotView.h"
#import "KSDChartData.h"
@import CoreText;

const CGFloat kKSDChartFrameMargin = 20.0;
const CGFloat kKSDTopBottomMarginFraction = 0.04;

@implementation KSDPlotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setData:(KSDChartData *)data {
  _data = data;
  [self setNeedsDisplay];
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
  if (data.count < 2) {
    return;
  }
  
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

- (void)computeChartDimensions
{
  _chartWidth = self.frame.size.width - 2*kKSDChartFrameMargin;
  _chartHeight = self.frame.size.height - 2*kKSDChartFrameMargin;
}

- (CGContextRef)getTranslatedContext:(CGRect)rect
{
  // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  
  CGContextTranslateCTM(context, 0.0, rect.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextTranslateCTM(context, kKSDChartFrameMargin, kKSDChartFrameMargin);
  return context;
}

- (void)scaleAndTranslateCTM:(CGContextRef)context withYRange:(KSDRange)yRange
{
  CGFloat dataWidth = self.data.timeRange.max - self.data.timeRange.min;
  _unadjustedDataHeight = yRange.max - self.data.priceRange.min;
  CGFloat dataHeight = _unadjustedDataHeight*(1 + 2*kKSDTopBottomMarginFraction);
  
  _lineScale = (self.chartWidth + self.chartHeight)/(dataWidth + dataHeight);
  CGFloat xScale = self.chartWidth/dataWidth;
  CGFloat yScale = self.chartHeight/dataHeight;
  
  CGContextScaleCTM(context, xScale, yScale);
  CGContextTranslateCTM(context,
                        -self.data.timeRange.min,
                        -(yRange.min - _unadjustedDataHeight*kKSDTopBottomMarginFraction));
}

- (void)unscaleCTM:(CGContextRef)context rect:(CGRect)rect
{
  //Set unscaled transformation matrix
  CGContextRestoreGState(context);
  CGContextTranslateCTM(context, 0.0, rect.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
}

- (void)drawMonthlyLabelsAndGridLines:(CGAffineTransform)scaledTransform
                              context:(CGContextRef)context
                                count:(long)count
                               yRange:(KSDRange)yRange
{
  //Draw monthly labels
  __block CGPoint transformedPoint =
  CGPointApplyAffineTransform(CGPointMake(0, (yRange.min - self.unadjustedDataHeight*kKSDTopBottomMarginFraction)), scaledTransform);
  CGFloat transformedTimeLabelY = transformedPoint.y/self.contentScaleFactor;
  transformedPoint =
  CGPointApplyAffineTransform(CGPointMake(0, (yRange.max + self.unadjustedDataHeight*kKSDTopBottomMarginFraction)), scaledTransform);
  CGFloat transformedTimeLabelYTop = transformedPoint.y/self.contentScaleFactor;
  
  long labelCount = self.data.monthLabels.count;
  
  NSMutableArray *transformedTimeLabels = [[NSMutableArray alloc] initWithCapacity:labelCount];
  [self.data.monthLabels enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *label, BOOL *stop) {
    transformedPoint = CGPointApplyAffineTransform(CGPointMake(count - [key floatValue] - 1, 0), scaledTransform);
    CGFloat tx = transformedPoint.x/self.contentScaleFactor;
    [transformedTimeLabels addObject:[NSNumber numberWithFloat:tx]];
    
    [self drawString:label at:CGPointMake(tx, kKSDChartFrameMargin/2-5) inContext:context];
  }];
  
  for (int i=0; i < labelCount; ++i) {
    CGFloat labelValue = [transformedTimeLabels[i] floatValue];
    CGContextMoveToPoint(context, labelValue, transformedTimeLabelY);
    CGContextAddLineToPoint(context, labelValue, transformedTimeLabelYTop);
  }
  
  CGContextStrokePath(context);
}

@end