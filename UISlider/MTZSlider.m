//
//  MTZSlider.m
//  MotionUIControls
//
//  Created by Matt Zanchelli on 2/13/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZSlider.h"

// Enable parallax effect on thumb view. This may lead to "inaccurate" UISliders.
#define THUMB_VIEW_PARALLAX


@interface MTZSlider ()

/// The thumb view.
@property (strong, nonatomic, readonly) UIView *thumbView;

/// The closer shadow view with little diffusion.
@property (strong, nonatomic) UIImageView *nearShadowView;

/// The futher shadow with a lot of diffusion.
@property (strong, nonatomic) UIImageView *farShadowView;

@end


@implementation MTZSlider

/// The asset name for the thumb view.
static NSString *thumbViewAssetName = @"Thumb";

/// The asset name for the near shadow image view.
static NSString *nearShadowViewAssetName = @"Thumb_Near_Shadow";

/// The asset name for the far shadow image view.
static NSString *farShadowViewAssetName = @"Thumb_Far_Shadow";


#pragma mark - Creating & Deallocating

- (instancetype)init
{
	self = [super init];
	if ( self ) {
		[self _MTZSlider_setUp];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		[self _MTZSlider_setUp];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self ) {
		[self _MTZSlider_setUp];
	}
	return self;
}

- (void)_MTZSlider_setUp
{
	// Need to perform after delay, otherwise UISlider views are uninitialized.
	[self performSelector:@selector(_MTZSlider_setUp_isNowReady) withObject:nil afterDelay:DBL_MIN];
}

- (void)_MTZSlider_setUp_isNowReady
{
	// Use custom image for thumb view.
	[self setThumbImage:[UIImage imageNamed:thumbViewAssetName] forState:UIControlStateNormal];
	
	// Near shadow image view.
	_nearShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:nearShadowViewAssetName]];
	_nearShadowView.center = CGPointMake(self.thumbView.center.x, self.thumbView.center.y + 3);
	[self insertSubview:_nearShadowView belowSubview:self.thumbView];
	
	// Far shadow image view.
	_farShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:farShadowViewAssetName]];
	_farShadowView.center = CGPointMake(self.thumbView.center.x, self.thumbView.center.y + 6);
	[self insertSubview:_farShadowView belowSubview:_nearShadowView];
	
	[self setUpThumbViewMotionEffects];
}

- (void)dealloc
{
	// Stop observing thumb view frame.
	@try {
		[self.thumbView removeObserver:self
							forKeyPath:@"frame"
							   context:ThumbViewFrameContext];
	} @catch (NSException *exception) {
	}
}


#pragma mark - Properties

static NSString *thumbViewKeyPath = @"_thumbView";

- (UIView *)thumbView
{
	return (UIView *) [self valueForKeyPath:thumbViewKeyPath];
}


#pragma mark - Motion Effects

#ifdef THUMB_VIEW_PARALLAX
static int thumbViewParallaxAbsoluteMax = 5;
#endif

- (void)setUpThumbViewMotionEffects
{
#ifdef THUMB_VIEW_PARALLAX
	// Horizontal motion
	UIInterpolatingMotionEffect *horizontal = [[UIInterpolatingMotionEffect alloc]
			 initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontal.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-thumbViewParallaxAbsoluteMax, 0, 0)];
	horizontal.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(thumbViewParallaxAbsoluteMax, 0, 0)];
	[self.thumbView addMotionEffect:horizontal];
	
	// Vertical motion
	UIInterpolatingMotionEffect *vertical = [[UIInterpolatingMotionEffect alloc]
			 initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	vertical.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -thumbViewParallaxAbsoluteMax, 0)];
	vertical.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, thumbViewParallaxAbsoluteMax, 0)];
	[self.thumbView addMotionEffect:vertical];
#endif
	
//	[self observeThumbViewFrame];
}

- (void)thumbViewFrameChanged
{
	NSLog(@"%@", NSStringFromCGRect(self.thumbView.frame));
}


#pragma mark - Key Value Observing

/// For use in KVO contexts.
static void *ThumbViewFrameContext = &ThumbViewFrameContext;

- (void)observeThumbViewFrame
{
	// Observe frame of the thumb view.
	[self.thumbView addObserver:self
					 forKeyPath:@"frame"
						options:NSKeyValueObservingOptionNew
						context:ThumbViewFrameContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if ( context == ThumbViewFrameContext ) {
		if ( [keyPath isEqualToString:@"frame"] ) {
			[self thumbViewFrameChanged];
		}
	}
}

@end
