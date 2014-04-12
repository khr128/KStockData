//
//  KSDAddStockPopoverViewController.m
//  KStockData
//
//  Created by khr on 3/13/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDAddStockPopoverViewController.h"
#import "KSDMasterViewController.h"
#import "KSDDetailViewController.h"
#import "KSDStockDataRetriever.h"
#import "NSString+NSString_KhrCSV.h"

@interface KSDAddStockPopoverViewController ()

@end

@implementation KSDAddStockPopoverViewController {
  KSDStockDataRetriever *_stockDataRetriever;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  _stockDataRetriever = [KSDStockDataRetriever new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextfieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  NSString *symbol = [textField.text uppercaseString];
  [_stockDataRetriever stockDataFor:symbol
                           commands:@"e1"
                   completionHadler:^(NSData *data, NSURLResponse *response, NSError *error) {
                     NSString *csv = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                     NSArray *array = [csv khr_csv];
                     
                     dispatch_queue_t mainQueue = dispatch_get_main_queue();
                     if ([array[0] isEqualToString:@"N/A"]) {
                       NSManagedObjectContext *context = [self.masterViewController.fetchedResultsController managedObjectContext];
                       NSEntityDescription *entity = [[self.masterViewController.fetchedResultsController fetchRequest] entity];
                       
                       NSFetchRequest *fetchRequest = [NSFetchRequest new];
                       fetchRequest.entity = entity;
                       fetchRequest.predicate = [NSPredicate predicateWithFormat:@"symbol == %@", symbol];
                       
                       NSError *fetchError = nil;
                       NSArray *fetchedData = [context executeFetchRequest:fetchRequest error:&fetchError];
                       
                       if (fetchedData.count < 1) {
                          dispatch_async(mainQueue, ^{
                           NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
                           
                           // If appropriate, configure the new managed object.
                           // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
                           [newManagedObject setValue:[textField.text uppercaseString] forKey:@"symbol"];
                           
                           [newManagedObject setValue: [self.overBoughtSold titleForSegmentAtIndex:self.overBoughtSold.selectedSegmentIndex]
                                               forKey: @"watchType"];
                           
                           
                           // Save the context.
                           NSError *saveError = nil;
                           if (![context save:&saveError]) {
                             // Replace this implementation with code to handle the error appropriately.
                             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                             NSLog(@"Unresolved error %@, %@", error, [saveError userInfo]);
                             abort();
                           }
                           
                            self.masterViewController.detailViewController.detailItem = newManagedObject;
                           
                           NSIndexPath *rowIndexPath = self.masterViewController.tableView.indexPathForSelectedRow;
                           [self.masterViewController.tableView deselectRowAtIndexPath:rowIndexPath animated:YES];
                         });
                       }
                     }
                     
                     dispatch_async(mainQueue, ^{
                       [self.presentingPopoverController dismissPopoverAnimated:YES];
                     });
                   }];

  return YES;
}

@end
