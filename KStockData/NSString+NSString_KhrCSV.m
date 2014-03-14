//
//  NSString+NSString_KhrCSV.m
//  KStockData
//
//  Created by khr on 3/13/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "NSString+NSString_KhrCSV.h"

@implementation NSString (NSString_KhrCSV)
- (NSArray *)khr_csv {
  NSMutableArray *values = [NSMutableArray new];
  NSScanner *scanner = [NSScanner scannerWithString:self];
  NSCharacterSet *commaSet = [NSCharacterSet characterSetWithCharactersInString:@","];
  NSCharacterSet *doubleQuotationSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
  NSCharacterSet *lineEndSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *valueString;
  NSUInteger maxLocation = [self length] - 1;
  
  while ([scanner isAtEnd] == NO) {
    NSUInteger startingLocation = scanner.scanLocation;
    
    [scanner scanUpToCharactersFromSet:commaSet intoString:&valueString];
    NSUInteger commaLocation = scanner.scanLocation;
    scanner.scanLocation = startingLocation;
    [scanner scanUpToCharactersFromSet:doubleQuotationSet intoString:nil];
    NSUInteger doubleQuotationLocation = scanner.scanLocation;
    
    if (doubleQuotationLocation < commaLocation) {
      scanner.scanLocation = doubleQuotationLocation+1;
      [scanner scanUpToCharactersFromSet:doubleQuotationSet intoString:&valueString];
      [scanner scanUpToCharactersFromSet:commaSet intoString:nil];
      if ([scanner isAtEnd] == NO) {
        scanner.scanLocation += 1;
      }
    } else {
      if (commaLocation < maxLocation) {
        scanner.scanLocation = commaLocation + 1;
      }
    }

    [values addObject:[valueString stringByTrimmingCharactersInSet:lineEndSet]];
  }
  return values;
}
@end
