//
//  KSDMasterViewController.m
//  KStockData
//
//  Created by khr on 3/12/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDMasterViewController.h"
#import "KSDDetailViewController.h"
#import "KSDAddStockPopoverViewController.h"
#import "KSDStockDataRetriever.h"
#import "NSString+NSString_KhrCSV.h"
#import "KSDSymbolTableViewCell.h"
#import "KSDChartData.h"

@interface KSDMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation KSDMasterViewController {
  UIPopoverController *_popoverController;
  NSMutableDictionary *_chartDataDictionary;
}

- (void)awakeFromNib
{
  self.clearsSelectionOnViewWillAppear = NO;
  self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.navigationItem.leftBarButtonItem = self.editButtonItem;

  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
  self.navigationItem.rightBarButtonItem = addButton;
  self.detailViewController = (KSDDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  
  _chartDataDictionary = [@{} mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
  KSDAddStockPopoverViewController *popoverViewController = [KSDAddStockPopoverViewController new];
  _popoverController =
  [[UIPopoverController alloc] initWithContentViewController:popoverViewController];
  _popoverController.popoverContentSize = CGSizeMake(296, 96);
  popoverViewController.presentingPopoverController = _popoverController;
  popoverViewController.masterViewController = self;
  
  [_popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  [self configureCell:cell atIndexPath:indexPath];
  
  UIView *bgColorView = [[UIView alloc] init];
  bgColorView.backgroundColor = [UIColor darkGrayColor];
//  bgColorView.layer.cornerRadius = 7;
  bgColorView.layer.masksToBounds = YES;
  [cell setSelectedBackgroundView:bgColorView];
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
  
  NSString *symbol = [[object valueForKey:@"symbol"] description];
  KSDChartData *chartData = _chartDataDictionary[symbol];
  if (chartData && [chartData isKindOfClass:[KSDChartData class]] == YES) {
    self.detailViewController.chartData = chartData;
  }
  
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  [self configureCell:cell atIndexPath:indexPath];
  
  self.detailViewController.detailItem = object;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UILabel *label = [UILabel new];
  label.backgroundColor = [UIColor darkGrayColor];
  label.textColor = [UIColor lightGrayColor];
  label.text = section == 0 ? @" Watch For Overbought" : @" Watch For Oversold";
  return label;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  // Edit the entity name as appropriate.
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stock" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  
  // Set the batch size to a suitable number.
  [fetchRequest setFetchBatchSize:20];
  
  // Edit the sort key as appropriate.
  NSSortDescriptor *rsiOverboughtSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rsiOverbought" ascending:NO];
  NSSortDescriptor *rsiOversoldSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rsiOversold" ascending:YES];
  NSSortDescriptor *watchTypeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"watchType" ascending:NO];
  NSArray *sortDescriptors = @[rsiOverboughtSortDescriptor, rsiOversoldSortDescriptor, watchTypeSortDescriptor];
  
  [fetchRequest setSortDescriptors:sortDescriptors];
  
  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                           initWithFetchRequest:fetchRequest
                                                           managedObjectContext:self.managedObjectContext
                                                           sectionNameKeyPath:@"watchType"
                                                           cacheName:@"Master"];
  aFetchedResultsController.delegate = self;
  self.fetchedResultsController = aFetchedResultsController;
  
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
	}
  
  return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeUpdate:
      [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
      
    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
  NSString *symbol = [[object valueForKey:@"symbol"] description];
  
  void (^changeRetrievalHandler)(NSURLResponse *response, NSData *data, NSError *error) =
  ^(NSURLResponse *response, NSData *data, NSError *error) {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
      NSString *csv = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      NSArray *array = [csv khr_csv];
      NSString *change = array[0];
      
      UILabel *changeLabel = ((KSDSymbolTableViewCell*) cell).changeLabel;
      changeLabel.text = change;
      UIFont *font = [UIFont fontWithName:@"LED BOARD REVERSED" size:17];
      changeLabel.font = font;

      UIColor *textColor =  ([change characterAtIndex:0] == '+' ? [UIColor greenColor] : [UIColor redColor]);
      changeLabel.textColor = textColor;
      cell.textLabel.textColor = textColor;
    });
  };
  
  cell.textLabel.text = symbol;
  
  [KSDStockDataRetriever stockDataFor:symbol commands:@"c" completionHadler:changeRetrievalHandler];
  
  NSManagedObject *stock = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  void (^chartRetrievalHandler)(NSURLResponse *response, NSData *data, NSError *error) =
  ^(NSURLResponse *response, NSData *data, NSError *error) {
    NSString *csv = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    KSDChartData *chartData = [[KSDChartData alloc] initWithColumns:[csv khr_csv_columns]];
    
    _chartDataDictionary[symbol] = chartData;
    self.detailViewController.chartData = chartData;
    
    NSDate *updatedAt = [NSDate date];
    [stock setValue:updatedAt forKey:@"updatedAt"];
    [stock setValue:csv forKey:@"chartDataCSV"];
    
    if (indexPath.section == 0) {
      [stock setValue:chartData.rsi[0] forKey:@"rsiOverbought"];
    } else {
      [stock setValue:chartData.rsi[0] forKey:@"rsiOversold"];
    }
  };
  
  NSDate *updatedAt  = [stock valueForKeyPath:@"updatedAt"];
  NSString *csv = [stock valueForKeyPath:@"chartDataCSV"];
  
  static const NSTimeInterval secondsPerDay = 3600*24;
  static const NSString *loadingGuard = @"Loading...";
  
  id cache = _chartDataDictionary[symbol];
  
  if ([cache respondsToSelector:@selector(isEqualToValue:)] == NO ||
      [cache isEqualToString:(NSString *)loadingGuard] == NO) {
    if (!updatedAt || [updatedAt timeIntervalSinceNow] < -secondsPerDay) {
      _chartDataDictionary[symbol] = loadingGuard;
      [KSDStockDataRetriever chartDataFor: symbol
                                    years: 2.0
                         completionHadler: chartRetrievalHandler];
    } else {
      if (!cache) {
        KSDChartData *chartData = [[KSDChartData alloc] initWithColumns:[csv khr_csv_columns]];
        _chartDataDictionary[symbol] = chartData;
        self.detailViewController.chartData = chartData;
      }
    }
  }
}

@end
