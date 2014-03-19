//
//  KSDStockDataRetriever.h
//  KStockData
//
//  Created by khr on 3/19/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSDStockDataRetriever : NSObject
+ (void)stockDataFor:(NSString *)symbol
            commands:(NSString *)commands
    completionHadler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completionHadler;
@end
