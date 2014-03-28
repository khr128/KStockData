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
  
//  BOOL _needsLayoutAfterOrientationDidChange;
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
  
  [nc addObserverForName:UIDeviceOrientationDidChangeNotification
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note) {
//                _needsLayoutAfterOrientationDidChange = YES;
                for (KSDIndicatorChartViewController *indicatorViewController in _indicatorViewControllers) {
                  [indicatorViewController defineViewGeometry];
                }
              }];
 
  _indicatorViewControllers = [@[] mutableCopy];
  
  UIView *superView = self.view;
  _animator = [[UIDynamicAnimator alloc] initWithReferenceView:superView];
  _animator.delegate = self;
  _gravity = [UIGravityBehavior new];
  [_animator addBehavior:_gravity];
  _gravity.magnitude = 4.0;
  
  KSDPriceChartsView *priceView = [[KSDPriceChartsView alloc] init];
  priceView.data = self.data;
  [priceView setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [self addChildViewControllerWithView:priceView draggable:NO withOffset:0];
  
  CGFloat navBarOffset = self.navigationController.navigationBar.bounds.size.height
  + self.navigationController.navigationBar.frame.origin.y;
  
  NSLayoutConstraint *c1 = [NSLayoutConstraint
                                      constraintWithItem:priceView
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:superView
                                      attribute:NSLayoutAttributeTop
                                      multiplier:1.0 constant:navBarOffset];
  
  NSLayoutConstraint *c2 = [NSLayoutConstraint
                  constraintWithItem:priceView
                  attribute:NSLayoutAttributeCenterX
                  relatedBy:NSLayoutRelationEqual
                  toItem:superView
                  attribute:NSLayoutAttributeCenterX
                  multiplier:1.0 constant:0.0];
  
  NSLayoutConstraint *c3 = [NSLayoutConstraint
                  constraintWithItem:priceView
                  attribute:NSLayoutAttributeWidth
                  relatedBy:NSLayoutRelationEqual
                  toItem:superView
                  attribute:NSLayoutAttributeWidth
                  multiplier:1.0 constant:0.0];
  
  NSLayoutConstraint *c4 = [NSLayoutConstraint
                  constraintWithItem:priceView
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
        [self addVelocityToView:draggedView fromGesture:gesture];
        [_animator updateItemUsingCurrentState:draggedView];
        _draggingView = NO;
      }
      break;
      
      
    default:
      break;
  }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark Dynamic Animator callbacks

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
//  if (_needsLayoutAfterOrientationDidChange == YES) {
//    for (KSDIndicatorChartViewController *indicatorViewController in _indicatorViewControllers) {
//      [indicatorViewController defineViewGeometry];
//    }
//    _needsLayoutAfterOrientationDidChange = NO;
//  }
}

@end
