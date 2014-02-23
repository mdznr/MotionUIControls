//
//  MTZViewController.m
//  MotionUIControls
//
//  Created by Matt Zanchelli on 2/13/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZViewController.h"
#import "MTZSlider.h"
#import "MTZPerspectiveView.h"

#import <QuartzCore/QuartzCore.h>

// If defined, automatically animate, else, use motion effects.
//#define AUTOMATICALLY_ANIMATE

@interface MTZViewController ()

@property (weak, nonatomic) IBOutlet MTZPerspectiveView *perspectiveView;

@end

@implementation MTZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
	// If iPad, automatically animate.
	if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
#ifdef AUTOMATICALLY_ANIMATE
		[self animatePerspectiveView];
#else
		self.perspectiveView.perspectiveType = MTZPerspectiveTypeDevice;
#endif
	}
}

// Automatically animate the perspective view.
#warning Animation of perspective view does not recreate Motion Effects.
- (void)animatePerspectiveView
{
	// Clear out motion effects
	self.perspectiveView.motionEffects = nil;
	
	// Straight
	CATransform3D straight = CATransform3DIdentity;
	
	// Right
	CATransform3D right = CATransform3DIdentity;
	right.m34 = 1.0f / 2000;
	CATransform3DRotate(right, 60.0f * M_PI / 180.0f, 0, -1, 0);
	
	// Left
	CATransform3D left = CATransform3DIdentity;
	left.m34 = 1.0f / 2000;
	CATransform3DRotate(left, 60.0f * M_PI / 180.0f, 0, 1, 0);
	
	// Top
	CATransform3D top = CATransform3DIdentity;
	top.m34 = 1.0f / 2000;
	CATransform3DRotate(top, 60.0f * M_PI / 180.0f, -1, 0, 0);
	
	// Down
	CATransform3D bottom = CATransform3DIdentity;
	bottom.m34 = 1.0f / 2000;
	CATransform3DRotate(bottom, 60.0f * M_PI / 180.0f, 1, 0, 0);
	
	CAKeyframeAnimation *motionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	motionAnimation.duration = 10.0f;
	motionAnimation.repeatCount = FLT_MAX;
	motionAnimation.values = @[[NSValue valueWithCATransform3D:straight],
							   [NSValue valueWithCATransform3D:right],
							   [NSValue valueWithCATransform3D:left],
							   [NSValue valueWithCATransform3D:straight],
							   [NSValue valueWithCATransform3D:top],
							   [NSValue valueWithCATransform3D:bottom],
							   [NSValue valueWithCATransform3D:straight]];
	motionAnimation.keyTimes = @[@(1/9),
								 @(2/9),
								 @(1/9),
								 @(2/9),
								 @(1/9),
								 @(2/9)];
	motionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	motionAnimation.autoreverses = YES;
	
	[self.perspectiveView.layer addAnimation:motionAnimation forKey:@"transform"];
}

- (void)viewDidDisappear:(BOOL)animated
{
	// Remove possible looping animation.
	if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
		[self.perspectiveView.layer removeAllAnimations];
	}
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
