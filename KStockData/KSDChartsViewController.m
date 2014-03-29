//
//  KSDChartsViewController.m
//  KStockData
//
//  Created by khr on 3/20/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDChartsViewController.h"
#import "KSDPriceChartsView.h"
#import "KSDRsiChartView.h"
#import "Externals.h"
#import "KSDDetailViewController.h"
#import "KSDIndicatorChartViewController.h"

@interface KSDChartsViewController ()

@end

@implementation KSDChartsViewController {
  NSMutableArray *_indicatorViewControllers;
  CGPoint _previousTouchPoint;
  BOOL _draggingView;
  
  UIDynamicAnimator *_animator;
  UIGravityBehavior *_gravity;
  
  UISnapBehavior *_snap;
  BOOL _viewDocked;
  
  KSDPriceChartsView *_priceView;
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
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserverForName:KSD_STOCK_SYMBOL_SELECTED
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note){
                KSDDetailViewController *detailsViewController = note.object;
                for (KSDIndicatorChartViewController *indicatorViewController in _indicatorViewControllers) {
                  ((KSDPlotView *)indicatorViewController.view).data = detailsViewController.chartData;
                };
              }];
 
  _indicatorViewControllers = [@[] mutableCopy];
  
  UIView *superView = self.view;
  _animator = [[UIDynamicAnimator alloc] initWithReferenceView:superView];
  _gravity = [UIGravityBehavior new];
  [_animator addBehavior:_gravity];
  _gravity.magnitude = 4.0;
  
  _priceView = [[KSDPriceChartsView alloc] init];
  _priceView.data = self.data;
  [_priceView setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [self addChildViewControllerWithView:_priceView draggable:NO withOffset:0];
  
  CGFloat navBarOffset = self.navigationController.navigationBar.bounds.size.height
  + self.navigationController.navigationBar.frame.origin.y;
  
  NSLayoutConstraint *c1 = [NSLayoutConstraint
                                      constraintWithItem:_priceView
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:superView
                                      attribute:NSLayoutAttributeTop
                                      multiplier:1.0 constant:navBarOffset];
  
  NSLayoutConstraint *c2 = [NSLayoutConstraint
                  constraintWithItem:_priceView
                  attribute:NSLayoutAttributeCenterX
                  relatedBy:NSLayoutRelationEqual
                  toItem:superView
                  attribute:NSLayoutAttributeCenterX
                  multiplier:1.0 constant:0.0];
  
  NSLayoutConstraint *c3 = [NSLayoutConstraint
                  constraintWithItem:_priceView
                  attribute:NSLayoutAttributeWidth
                  relatedBy:NSLayoutRelationEqual
                  toItem:superView
                  attribute:NSLayoutAttributeWidth
                  multiplier:1.0 constant:0.0];
  
  NSLayoutConstraint *c4 = [NSLayoutConstraint
                  constraintWithItem:_priceView
                  attribute:NSLayoutAttributeHeight
                  relatedBy:NSLayoutRelationEqual
                  toItem:superView
                  attribute:NSLayoutAttributeHeight
                  multiplier:0.5 constant:0];
  
  [superView addConstraints:@[c1, c2, c3, c4]];
  
  CGFloat offset = 50;
  KSDRsiChartView *rsiView = [[KSDRsiChartView alloc] init];
  rsiView.data = self.data;
  [rsiView setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [self addChildViewControllerWithView:rsiView draggable:YES withOffset:2*offset];
  
  rsiView = [[KSDRsiChartView alloc] init];
  rsiView.data = self.data;
  [rsiView setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [self addChildViewControllerWithView:rsiView draggable:YES withOffset:offset];
}

- (void)addChildViewControllerWithView:(UIView *)view draggable:(BOOL) draggable withOffset:(CGFloat)offset{
  UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  KSDIndicatorChartViewController *indicatorViewController =
  [myStoryboard instantiateViewControllerWithIdentifier:@"IndicatorChartVC"];
  
  indicatorViewController.view = view;
  indicatorViewController.animator = _animator;
  indicatorViewController.gravity = _gravity;
  indicatorViewController.dynamic = draggable;
  indicatorViewController.offset = offset;
  
  [_indicatorViewControllers addObject:indicatorViewController];
  
  //add as a child
  [self addChildViewController:indicatorViewController];
  [self.view addSubview:view];
  [indicatorViewController didMoveToParentViewController:self];
  
  if (draggable == YES) {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handlePan:)];
    [view addGestureRecognizer:pan];
  }
}

- (UIDynamicItemBehavior *)itemBehaviorForView:(UIView *)view {
  for (UIDynamicItemBehavior *behavior in _animator.behaviors) {
    if (behavior.class == [UIDynamicItemBehavior class] && behavior.items[0] == view) {
      return behavior;
    }
  }
  return nil;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
  CGPoint touchPoint = [gesture locationInView:self.view];
  UIView *draggedView = gesture.view;
  
  switch (gesture.state) {
    case UIGestureRecognizerStateBegan:
    {
      _draggingView = YES;
      _previousTouchPoint = touchPoint;
      [UIView transitionWithView:draggedView duration:0.5
                         options:UIViewAnimationOptionCurveEaseInOut
                      animations:^{ draggedView.alpha = 0.7; }
                      completion:nil];
    }
      break;
      
    case UIGestureRecognizerStateChanged:
      if (_draggingView == YES) {
        CGFloat yOffset = _previousTouchPoint.y - touchPoint.y;
        draggedView.center = CGPointMake(draggedView.center.x, draggedView.center.y - yOffset);
        _previousTouchPoint = touchPoint;
      }
      break;
      
    case UIGestureRecognizerStateEnded:
      if (_draggingView == YES) {
        [UIView transitionWithView:draggedView duration:0.5
                           options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{ draggedView.alpha = 1; }
                        completion:nil];
        
        [self tryDockView:draggedView];
        
        [self addVelocityToView:draggedView fromGesture:gesture];
        [_animator updateItemUsingCurrentState:draggedView];
        _draggingView = NO;
      }
      break;
      
      
    default:
      break;
  }
}

- (void)setAlphaWithDockedView:(UIView *)view alpha:(CGFloat)alpha {
  for (KSDIndicatorChartViewController *indicatorViewController in _indicatorViewControllers) {
    
    if (indicatorViewController.dynamic == YES && indicatorViewController.view != view) {
      [UIView transitionWithView:indicatorViewController.view duration:0.5
                         options:UIViewAnimationOptionCurveEaseInOut
                      animations:^{ indicatorViewController.view.alpha = alpha; }
                      completion:nil];
    };
  };
}

- (void)addVelocityToView:(UIView *)view fromGesture:(UIPanGestureRecognizer *)gesture {
  CGPoint velocity = [gesture velocityInView:self.view];
  velocity.x = 0;
  UIDynamicItemBehavior *behavior = [self itemBehaviorForView:view];
  [behavior addLinearVelocity:velocity forItem:view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGPoint)dockingSnapPoint {
  return CGPointMake(self.view.center.x,
                                  (self.view.frame.size.height
                                   + _priceView.frame.origin.y + _priceView.frame.size.height)/2);
}

- (void)tryDockView:(UIView *)view {
  CGPoint snapPoint = [self dockingSnapPoint];
  
  BOOL viewHasReachedDockLocation = view.frame.origin.y < snapPoint.y;
  if (viewHasReachedDockLocation) {
    if (_viewDocked == NO) {
      _snap = [[UISnapBehavior alloc] initWithItem:view snapToPoint:snapPoint];
      [_animator addBehavior:_snap];
      [self setAlphaWithDockedView:view alpha:0.0];
      _viewDocked = YES;
    } else {
      [_animator removeBehavior:_snap];
      [self setAlphaWithDockedView:view alpha:1.0];
      _viewDocked = NO;
    }
  }
}

#pragma mark -
#pragma mark UICollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior
      beganContactForItem:(id<UIDynamicItem>)item
   withBoundaryIdentifier:(id<NSCopying>)identifier
                  atPoint:(CGPoint)p
{
  if ([@"snapPointCollisionBoundary" isEqual:identifier]) {
    UIView *view = (UIView *)item;
    [self tryDockView:view];
  }
}
@end
