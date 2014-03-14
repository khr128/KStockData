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

  NSString *valueString;
  
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
      scanner.scanLocation += 1;
   }

    [values addObject:valueString];
  }
  return values;
}
@end
