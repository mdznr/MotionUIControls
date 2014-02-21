//
//  MTZSlider.m
//  MotionUIControls
//
//  Created by Matt Zanchelli on 2/13/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZSlider.h"

#import "MTZSliderCatalog.h"

/// Enable parallax effect on thumb view.
#define THUMB_VIEW_PARALLAX

/// Enable parallax effect on the near shadow view.
#define NEAR_SHADOW_VIEW_PARALLAX


@interface MTZSlider ()

/// The thumb view.
@property (strong, nonatomic, readonly) UIView *thumbView;

/// The closer shadow view with little diffusion.
@property (strong, nonatomic) UIImageView *nearShadowView;

/// The futher shadow with a lot of diffusion.
@property (strong, nonatomic) UIImageView *farShadowView;

@end


@implementation MTZSlider


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
	[self setThumbImage:[MTZSliderCatalog thumbImage] forState:UIControlStateNormal];
	
	// Near shadow image view.
	_nearShadowView = [[UIImageView alloc] initWithImage:[MTZSliderCatalog thumb_Near_ShadowImage]];
	[self insertSubview:_nearShadowView belowSubview:self.thumbView];
	
	// Far shadow image view.
	_farShadowView = [[UIImageView alloc] initWithImage:[MTZSliderCatalog thumb_Far_ShadowImage]];
	[self insertSubview:_farShadowView belowSubview:_nearShadowView];
	
	[self synchronizeThumbViewAndShadows];
	
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
/// The absolute maximum distance to translate the thumb view.
static int thumbViewParallaxAbsoluteMax = 4;
#endif

#ifdef NEAR_SHADOW_VIEW_PARALLAX
/// Multiplied by thumbViewParallaxAbsoluteMax.
static int nearShadowViewParallaxFraction = 1/4;
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
	
#ifdef NEAR_SHADOW_VIEW_PARALLAX
	// Horizontal motion
	UIInterpolatingMotionEffect *horizontalShadow = [[UIInterpolatingMotionEffect alloc]
			initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontalShadow.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-thumbViewParallaxAbsoluteMax * nearShadowViewParallaxFraction, 0, 0)];
	horizontalShadow.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(thumbViewParallaxAbsoluteMax * nearShadowViewParallaxFraction, 0, 0)];
	[_nearShadowView addMotionEffect:horizontalShadow];
	
	// Vertical motion
	UIInterpolatingMotionEffect *verticalShadow = [[UIInterpolatingMotionEffect alloc]
											 initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	verticalShadow.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -thumbViewParallaxAbsoluteMax * nearShadowViewParallaxFraction, 0)];
	verticalShadow.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, thumbViewParallaxAbsoluteMax * nearShadowViewParallaxFraction, 0)];
	[_nearShadowView addMotionEffect:verticalShadow];
#endif
	
	[self observeThumbViewFrame];
}

- (void)thumbViewFrameChanged
{
	[self synchronizeThumbViewAndShadows];
}

- (void)synchronizeThumbViewAndShadows
{
	_nearShadowView.center = CGPointMake(self.thumbView.center.x, self.thumbView.center.y + 3);
	_farShadowView.center = CGPointMake(self.thumbView.center.x, self.thumbView.center.y + 5.5);
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
