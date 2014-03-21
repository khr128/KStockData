//
//  NSString+NSString_KhrCSV.h
//  KStockData
//
//  Created by khr on 3/13/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_KhrCSV)
- (NSArray *)khr_csv;
- (NSString *)khr_stripHTML;
- (NSDictionary *)khr_csv_columns;
@end
