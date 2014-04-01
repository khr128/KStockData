//
//  KSDChartsAnimationController.m
//  KStockData
//
//  Created by khr on 3/31/14.
//  Copyright (c) 2014 khr. All rights reserved.
//

#import "KSDChartsAnimationController.h"

@implementation KSDChartsAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return 3.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController *toViewController = [transitionContext
                                        viewControllerForKey:UITransitionContextToViewControllerKey];
  
  CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
  
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  toViewController.view.frame = CGRectOffset(finalFrame, 0, screenBounds.size.height);
  
  UIView *containerView = [transitionContext containerView];
  [containerView addSubview:toViewController.view];
  
  NSTimeInterval duration = [self transitionDuration:transitionContext];
  
  [UIView animateWithDuration:duration
                   animations:^{
                     toViewController.view.frame = finalFrame;
                   }
                   completion:^(BOOL finished) {
                     [transitionContext completeTransition:YES];
                   }];
}
@end
