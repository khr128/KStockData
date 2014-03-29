//
//  KSDIndicatorChartViewController.m
//  KStockData
//
//  Created by khr on 3/27/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDIndicatorChartViewController.h"
#import "KSDChartsViewController.h"

@interface KSDIndicatorChartViewController ()

@end

@implementation KSDIndicatorChartViewController

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
    // Do any additional setup after loading the view.
}

- (void)defineViewGeometry {
  if (_dynamic == YES) {
    KSDChartsViewController *parentController = ((KSDChartsViewController *)self.parentViewController);
    CGPoint snapPoint = [parentController dockingSnapPoint];

    self.view.frame = CGRectMake(0, snapPoint.y+1, self.view.superview.frame.size.width, 0.4*self.view.superview.frame.size.height);

    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[self.view]];
    collision.collisionMode = UICollisionBehaviorModeBoundaries;
    
    //boundary for the indicator view to rest
    CGFloat boundary = 1.4*self.view.superview.frame.size.height - _offset;
    CGPoint boundaryStart = CGPointMake(0.0, boundary);
    CGPoint boundaryEnd = CGPointMake(self.view.superview.frame.size.width, boundary);
    
    [collision addBoundaryWithIdentifier:@1 fromPoint:boundaryStart toPoint:boundaryEnd];

    [_animator updateItemUsingCurrentState:self.view];
    [_animator addBehavior:collision];
    
    boundaryStart = CGPointMake(0, snapPoint.y);
    boundaryEnd = CGPointMake(self.view.frame.size.width, snapPoint.y);
    [collision addBoundaryWithIdentifier:@"snapPointCollisionBoundary" fromPoint:boundaryStart toPoint:boundaryEnd];
    collision.collisionDelegate = parentController;
    
    UIDynamicItemBehavior* itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.view]];
    itemBehavior.elasticity = 0.5;
    itemBehavior.allowsRotation = NO;
    [_animator addBehavior:itemBehavior];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self defineViewGeometry];
  
  if (_dynamic == YES) {
    [_gravity addItem:self.view];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.view]];
    [_animator addBehavior:itemBehavior];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
