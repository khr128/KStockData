//
//  KSDIndicatorChartViewController.m
//  KStockData
//
//  Created by khr on 3/27/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDIndicatorChartViewController.h"

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
    self.view.frame = CGRectMake(0, 0, self.view.superview.frame.size.width, 0.4*self.view.superview.frame.size.height);

    UICollisionBehavior *collision = [self collisionBehavior];
    if (collision) {
      [_animator removeBehavior:collision];
    }
    
    collision = [[UICollisionBehavior alloc] initWithItems:@[self.view]];
    
    //boundary for the indicator view to rest
    NSLog(@"Superview height: %f", self.view.superview.frame.size.height);
    NSLog(@"View height: %f", self.view.frame.size.height);
    CGFloat boundary = 1.4*self.view.superview.frame.size.height - _offset;
    CGPoint boundaryStart = CGPointMake(0.0, boundary);
    CGPoint boundaryEnd = CGPointMake(self.view.superview.frame.size.width, boundary);
    
    [collision addBoundaryWithIdentifier:@1 fromPoint:boundaryStart toPoint:boundaryEnd];

    NSLog(@"Boundary: %f", boundary);

    [_animator updateItemUsingCurrentState:self.view];
    [_animator addBehavior:collision];
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

- (UICollisionBehavior *)collisionBehavior {
  for (UICollisionBehavior *behavior in _animator.behaviors) {
    if (behavior.class == [UICollisionBehavior class] && behavior.items[0] == self.view) {
      return behavior;
    }
  }
  return nil;
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
