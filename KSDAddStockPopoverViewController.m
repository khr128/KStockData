//
//  KSDAddStockPopoverViewController.m
//  KStockData
//
//  Created by khr on 3/13/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDAddStockPopoverViewController.h"
#import "KSDMasterViewController.h"

@interface KSDAddStockPopoverViewController ()

@end

@implementation KSDAddStockPopoverViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextfieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  NSManagedObjectContext *context = [self.masterViewController.fetchedResultsController managedObjectContext];
  NSEntityDescription *entity = [[self.masterViewController.fetchedResultsController fetchRequest] entity];
  NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
  
  // If appropriate, configure the new managed object.
  // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
  [newManagedObject setValue:[textField.text capitalizedString] forKey:@"symbol"];
  
  // Save the context.
  NSError *error = nil;
  if (![context save:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
  
  [self.presentingPopoverController dismissPopoverAnimated:YES];
  
  return YES;
}

@end
