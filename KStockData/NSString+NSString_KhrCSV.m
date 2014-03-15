//
//  NSString+NSString_KhrCSV.m
//  KStockData
//
//  Created by khr on 3/13/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "NSString+NSString_KhrCSV.h"

static NSCharacterSet *commaSet = nil;
static NSCharacterSet *doubleQuotationSet = nil;
static NSCharacterSet *lineEndSet = nil;


@implementation NSString (NSString_KhrCSV)
- (NSArray *)khr_csv {
  NSMutableArray *values = [NSMutableArray new];
  NSScanner *scanner = [NSScanner scannerWithString:self];
  
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    commaSet = [NSCharacterSet characterSetWithCharactersInString:@","];
    doubleQuotationSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    lineEndSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  });

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

    [values addObject:[[valueString stringByTrimmingCharactersInSet:lineEndSet] khr_stripHTML]];
  }
  return values;
}

static NSCharacterSet *openingTokens = nil;
static NSCharacterSet *semicolonSet = nil;
static NSCharacterSet *closingBracketSet = nil;

- (NSString *) khr_stripHTML {
  NSScanner *scanner = [NSScanner scannerWithString:self];
  
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    openingTokens = [NSCharacterSet characterSetWithCharactersInString:@"<&"];
    semicolonSet = [NSCharacterSet characterSetWithCharactersInString:@"; <"];
    closingBracketSet = [NSCharacterSet characterSetWithCharactersInString:@">"];
  });

  NSMutableString *processedString = [NSMutableString new];
  NSString *scanString;
  
  while ([scanner isAtEnd] == NO) {
    [scanner scanUpToCharactersFromSet:openingTokens intoString:&scanString];
    if (scanString) {
      [processedString appendString:scanString];
      scanString = nil;
    }
    if ([scanner isAtEnd] == NO) {
      unichar c = [self characterAtIndex:scanner.scanLocation];
      switch (c) {
        case '<':
          scanner.scanLocation++;
          [scanner scanUpToCharactersFromSet:closingBracketSet intoString:nil];
          scanner.scanLocation++;
          break;
        case '&':
          [scanner scanUpToCharactersFromSet:semicolonSet intoString:&scanString];
          unichar c2 = [self characterAtIndex:scanner.scanLocation];
          if (c2 == ';') {
            scanner.scanLocation++;
          } else {
            if (scanString) {
              [processedString appendString:scanString];
            }
            if (c2 == ' ') {
              [processedString appendString:@" "];
            }
          }
          scanString = nil;
          break;
          
        default:
          scanner.scanLocation++;
          break;
      }
    }
  }
  return processedString;
}
@end
