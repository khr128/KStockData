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
#import "Reachability.h"

typedef NS_ENUM(NSInteger, KSDOversoldOverbought) {
  KSDOversold = 1,
  KSDOverBought = 0
};

@interface KSDMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)refreshStockLists:(id)sender;
@end

@implementation KSDMasterViewController {
  UIPopoverController *_popoverController;
  NSMutableDictionary *_chartDataDictionary;
  KSDStockDataRetriever *_stockDataRetriever, *_chartDataRetriever;
  Reachability *_hostReachable;
}

- (void)awakeFromNib
{
  self.clearsSelectionOnViewWillAppear = NO;
  self.preferredContentSize = CGSizeMake(320.0, 600.0);
  [super awakeFromNib];
  [self startReachabilityNotifierFor:@"finance.yahoo.com"];
}

- (void) startReachabilityNotifierFor:(NSString *)hostName {
  // check for internet connection
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
  
  // check if a pathway to a random host exists
  _hostReachable = [Reachability reachabilityWithHostName: hostName];
  [_hostReachable startNotifier];
}

- (void) checkNetworkStatus:(NSNotification *)notice {
  NetworkStatus hostStatus = [_hostReachable currentReachabilityStatus];
  if (hostStatus == NotReachable) {
    self.canReachStockDataServer = NO;
    UIAlertView *alert = [[UIAlertView alloc]
													initWithTitle:@"Data feed problem"
													message:@"Please make sure that your iPad is connected to the Internet"
													delegate:nil
													cancelButtonTitle:@"Dismiss"
													otherButtonTitles:nil];
		[alert show];

  } else {
    self.canReachStockDataServer = YES;
    [self refreshStockLists:nil];
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
	// Do any additional setup after loading the view, typically from a nib.
  UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(refreshStockLists:)];

  self.navigationItem.leftBarButtonItem = refreshButton;

  UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
  self.navigationItem.rightBarButtonItem = addButton;
  self.detailViewController = (KSDDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  
  _chartDataDictionary = [@{} mutableCopy];
  _stockDataRetriever = [KSDStockDataRetriever new];
  _chartDataRetriever = [KSDStockDataRetriever new];
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

- (void)refreshStockLists:(id)sender {
  [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{  
  return self.canReachStockDataServer ? [[self.fetchedResultsController sections] count] : 0;
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
  bgColorView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.3 alpha:1.0];
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
  
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  [self configureCell:cell atIndexPath:indexPath];
  
  NSString *symbol = [[object valueForKey:@"symbol"] description];
  KSDChartData *chartData = _chartDataDictionary[symbol];
  
  BOOL chartDataAvailable = chartData && [chartData isKindOfClass:[KSDChartData class]] == YES;
  self.detailViewController.chartData = chartDataAvailable ? chartData : nil;
  
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


static const NSTimeInterval secondsPerDay = 3600*24;
static const NSString *loadingGuard = @"Loading...";

- (void)updateChartCSV:(NSMutableString *)chartCsv withCurrentData:(NSString *)currentDataString  add:(BOOL)add {
  NSRange firstCR = [chartCsv rangeOfString:@"\n"];
  NSInteger afterFirstCRIndex = firstCR.location+firstCR.length;
  if (add == NO) {
    NSRange secondCR = [chartCsv rangeOfString:@"\n"
                                       options:NSLiteralSearch
                                         range:NSMakeRange(afterFirstCRIndex, chartCsv.length - afterFirstCRIndex)];
    [chartCsv deleteCharactersInRange:NSMakeRange(afterFirstCRIndex, secondCR.location - afterFirstCRIndex+1)];
    
  }
  [chartCsv insertString:currentDataString atIndex:afterFirstCRIndex];
}

- (NSString *)todayString {
  NSDate *now = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd"];
  NSString *nowString = [dateFormatter stringFromDate:now];
  return nowString;
}

- (void)updateCurrentStockData:(KSDChartData *)chartData
                         stock:(NSManagedObject *)stock
                        symbol:(NSString *)symbol
                       section:(NSInteger)section
{
  NSDate *updatedAt  = [stock valueForKeyPath:@"updatedAt"];
  if ([updatedAt timeIntervalSinceNow] > -10) {
    return;
  }
  
  if ([KSDStockDataRetriever isStockMarketOpen] == YES) {
    [_stockDataRetriever stockDataFor:symbol
                             commands:@"ohgl1v"
                     completionHadler:^(NSData *data, NSURLResponse *response, NSError *error) {
                       NSString *csv = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                       NSArray *array = [csv khr_csv];
                       KSDChartData *chartData = _chartDataDictionary[symbol];
                       
                       if ([array[0] isEqualToString:@"N/A"] == NO) {
                         [chartData updateCurrentData:array];
                         
                         NSString *currentDataString = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@\n",
                                                        [self todayString], array[0], array[1], array[2], array[3], array[4], array[3]];
                         
                         NSMutableString *chartCsv = [[stock valueForKeyPath:@"chartDataCSV"] mutableCopy];
                         [self updateChartCSV:chartCsv withCurrentData:currentDataString add:NO];
                         
                         NSDate *updatedAt = [NSDate date];
                         [stock setValue:updatedAt forKey:@"updatedAt"];
                         [stock setValue:chartCsv forKey:@"chartDataCSV"];
                         [self updateRsiOverboughtOverSold:stock chartData:chartData section:section];
                       }
                       
                       self.detailViewController.chartData = chartData;
                     }];
  } else {
    self.detailViewController.chartData = chartData;
  }
}

- (void)updateRsiOverboughtOverSold:(NSManagedObject *)stock chartData:(KSDChartData *)chartData section:(NSInteger)section {
  if (section == KSDOverBought) {
    if (chartData.rsi.count > 0) {
      [stock setValue:chartData.rsi[0] forKey:@"rsiOverbought"];
    } else {
      [stock setValue:@100 forKey:@"rsiOverbought"];
    }
  } else {
    if (chartData.rsi.count > 0) {
      [stock setValue:chartData.rsi[0] forKey:@"rsiOversold"];
    } else {
      [stock setValue:@0 forKey:@"rsiOversold"];
    }
  }
}

- (void)retrieveChartData:(NSManagedObject *)stock section:(NSInteger)section symbol:(NSString *)symbol {
  void (^chartRetrievalHandler)(NSData *data, NSURLResponse *response, NSError *error) =
  ^(NSData *data, NSURLResponse *response, NSError *error) {
    NSString *csv = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    KSDChartData *chartData = [[KSDChartData alloc] initWithColumns:[csv khr_csv_columns] andSymbol:symbol];
    _chartDataDictionary[symbol] = chartData;
    self.detailViewController.chartData = chartData;
    
    NSDate *updatedAt = [NSDate date];
    [stock setValue:updatedAt forKey:@"updatedAt"];
    [stock setValue:csv forKey:@"chartDataCSV"];
    
    [self updateRsiOverboughtOverSold:stock chartData:chartData section:section];
//    [stock.managedObjectContext save:NULL];
  };
  
  id cache = _chartDataDictionary[symbol];
  
  if ([cache respondsToSelector:@selector(isEqualToString:)] == NO ||
      [cache isEqualToString:(NSString *)loadingGuard] == NO) {
    
    NSDate *updatedAt  = [stock valueForKeyPath:@"updatedAt"];
    if (!updatedAt || [updatedAt timeIntervalSinceNow] < -secondsPerDay) {
      _chartDataDictionary[symbol] = loadingGuard;
      [_chartDataRetriever chartDataFor: symbol
                                  years: 2.0
                       completionHadler: chartRetrievalHandler];
    } else {
      if (!cache) {
        dispatch_queue_t queue = dispatch_queue_create("com.khr.KStock.ChartDataQueue", NULL);
        dispatch_async(queue, ^{
          NSString *csv = [stock valueForKeyPath:@"chartDataCSV"];
          KSDChartData *chartData = [[KSDChartData alloc] initWithColumns:[csv khr_csv_columns] andSymbol:symbol];
          _chartDataDictionary[symbol] = chartData;
          [self updateCurrentStockData:chartData stock:stock symbol:symbol section:section];
        });
      } else {
        [self updateCurrentStockData:cache stock:stock symbol:symbol section:section];
      }
    }
  } else {
    self.detailViewController.chartData = nil;
  }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  NSString *symbol = [[object valueForKey:@"symbol"] description];
  cell.textLabel.text = [NSString stringWithFormat:@"%@ ...",symbol];
  
  void (^changeRetrievalHandler)(NSData *data, NSURLResponse *response, NSError *error) =
  ^(NSData *data, NSURLResponse *response, NSError *error) {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
      NSString *csv = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      NSArray *array = [csv khr_csv];
      NSString *change = array[0];
      
      UILabel *changeLabel = ((KSDSymbolTableViewCell*) cell).changeLabel;
      changeLabel.text = change;
      UIFont *font = [UIFont fontWithName:@"LED BOARD REVERSED" size:17];
      changeLabel.font = font;
      
      cell.textLabel.Text = symbol;

      UIColor *textColor =  ([change characterAtIndex:0] == '+' ? [UIColor greenColor] : [UIColor redColor]);
      changeLabel.textColor = textColor;
      cell.textLabel.textColor = textColor;
    });
  };
  
  [_stockDataRetriever stockDataFor:symbol commands:@"c" completionHadler:changeRetrievalHandler];
  
  NSManagedObject *stock = [self.fetchedResultsController objectAtIndexPath:indexPath];
  [self retrieveChartData:stock section:indexPath.section symbol:symbol];
}

@end
