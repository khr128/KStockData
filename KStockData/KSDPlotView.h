//
//  KSDPlotView.h
//  KStockData
//
//  Created by khr on 3/25/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KStockData-Swift.h"

@class KSDChartData;

extern const CGFloat kKSDChartFrameMargin;
extern const CGFloat kKSDTopBottomMarginFraction;


@interface KSDPlotView : UIView

@property (weak, nonatomic) KSDChartData *data;

- (void)drawString:(NSString *)label at:(CGPoint)position withAlignment:(NSTextAlignment)alignment inContext:(CGContextRef)context;

- (void)drawChartFrameInContext: (CGContextRef)context chartHeight: (CGFloat)chartHeight chartWidth: (CGFloat)chartWidth;

- (void)drawDataLineWithWidth: (CGFloat)lineWidth
                      context: (CGContextRef)context
                         data: (NSArray*)data
                        color: (UIColor*)color
                       yRange: (KSDRange*)yRange;

@property (nonatomic, assign, readonly) CGFloat chartWidth;

@property (nonatomic, assign, readonly) CGFloat chartHeight;

- (void)computeChartDimensions;

- (CGContextRef)getTranslatedContext: (CGRect)rect;

@property (nonatomic, assign, readonly) CGFloat unadjustedDataHeight;

- (void)scaleAndTranslateCTM: (CGContextRef)context  withYRange:(KSDRange*)yRange;

- (void)unscaleCTM: (CGContextRef)context rect: (CGRect)rect;

- (void)drawMonthlyLabelsAndGridLines: (CGAffineTransform)scaledTransform context: (CGContextRef)context yRange: (KSDRange*)yRange;

- (void)setGridlineStyle: (CGContextRef)context;

- (void)drawValueLabelsAndGridLines: (NSArray*)values transform: (CGAffineTransform)transform context: (CGContextRef)context;

- (void)highlightRegions: (NSArray*)regions withColor: (UIColor*)color context: (CGContextRef)context;
- (void)strokePathWithoutScaling: (CGContextRef)context lineWidth: (CGFloat)lineWidth color: (UIColor*)color yRange: (KSDRange *)yRange;

@end
