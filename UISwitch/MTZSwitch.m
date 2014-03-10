//
//  MTZSwitch.m
//  MotionUIControls
//
//  Created by Matt Zanchelli on 2/24/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZSwitch.h"
#import "MTZSwitchCatalog.h"

/// Enable parallax effect on thumb view.
//#define THUMB_VIEW_PARALLAX

/// Enable parallax effect on the near shadow view.
#define NEAR_SHADOW_VIEW_PARALLAX

/// Enable parallax effect on the far shadow view.
#define FAR_SHADOW_VIEW_PARALLAX


@interface MTZSwitch ()

/// The image for the thumb.
@property (strong, nonatomic) UIImage *thumbImage;

/// The thumb view.
@property (strong, nonatomic) UIView *thumbView;

/// The closer shadow view with little diffusion.
@property (strong, nonatomic) UIImageView *nearShadowView;

/// The futher shadow with a lot of diffusion.
@property (strong, nonatomic) UIImageView *farShadowView;

@end


@implementation MTZSwitch

#pragma mark - Creating & Deallocating

- (instancetype)init
{
	self = [super init];
	if ( self ) {
		[self _MTZSwitch_setUp];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		[self _MTZSwitch_setUp];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self ) {
		[self _MTZSwitch_setUp];
	}
	return self;
}

- (void)_MTZSwitch_setUp
{
	// Need to perform after delay, otherwise UISlider views are uninitialized.
	[self performSelector:@selector(_MTZSwitch_setUp_isNowReady) withObject:nil afterDelay:DBL_MIN];
}

- (void)_MTZSwitch_setUp_isNowReady
{
	// Use custom image for thumb view.
	self.thumbImage = [MTZSwitchCatalog switchThumbImage];

	// Add the near shadow image view.
	_nearShadowView = [[UIImageView alloc] initWithImage:[MTZSwitchCatalog switchThumbNearShadowImage]];
	[[self valueForKeyPath:@"_control"] insertSubview:_nearShadowView belowSubview:[self thumbView]];

	// Add the far shadow image view.
	_farShadowView = [[UIImageView alloc] initWithImage:[MTZSwitchCatalog switchThumbFarShadowImage]];
	[[self valueForKeyPath:@"_control"] insertSubview:_farShadowView belowSubview:_nearShadowView];

	[self synchronizeThumbViewAndShadows];

	[self setUpThumbViewMotionEffects];
}

- (void)dealloc
{
	[self stopObservingThumbViewFrame];
}


#pragma mark - Properties

- (UIView *)thumbView
{
	// If already found once, return it early.
	if ( _thumbView != nil ) return _thumbView;
	
	// The thumbview is a subview.
	NSArray *subviews = [[self valueForKeyPath:@"_control"] subviews];
	
	// Find and return the first image view (assuming there's only one).
	for ( UIView *view in subviews ) {
		if ( [view isKindOfClass:[UIImageView class]] ) {
			_thumbView = view;
			return self.thumbView;
		}
	}
	
	// Could not find a subview of UIImageView in _control.
	return nil;
}

- (void)setThumbImage:(UIImage *)image
{
	((UIImageView *) self.thumbView).image = image;
}

- (UIImage *)thumbImage
{
	return ((UIImageView *) self.thumbView).image;
}


#pragma mark - Motion Effects

/// The absolute maximum distance to translate the thumb view.
#ifdef THUMB_VIEW_PARALLAX
static int thumbViewParallaxAbsoluteMax = 0;
#endif

#ifdef NEAR_SHADOW_VIEW_PARALLAX
/// Multiplied by thumbViewParallaxAbsoluteMax.
static int nearShadowViewParallaxMultiple = -4;
#endif

#ifdef FAR_SHADOW_VIEW_PARALLAX
/// Multipled by thumbViewParallaxAbsoluteMax.
static int farShadowViewParallaxMultiple = -5;
#endif

- (void)setUpThumbViewMotionEffects
{
#ifdef THUMB_VIEW_PARALLAX
	// Horizontal motion
	UIInterpolatingMotionEffect *horizontal = [[UIInterpolatingMotionEffect alloc]
			initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontal.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-thumbViewParallaxAbsoluteMax, 0, 0)];
	horizontal.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation( thumbViewParallaxAbsoluteMax, 0, 0)];
	[self.thumbView addMotionEffect:horizontal];

	// Vertical motion
	UIInterpolatingMotionEffect *vertical = [[UIInterpolatingMotionEffect alloc]
			initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	vertical.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -thumbViewParallaxAbsoluteMax, 0)];
	vertical.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0,  thumbViewParallaxAbsoluteMax, 0)];
	[self.thumbView addMotionEffect:vertical];
#endif

#ifdef NEAR_SHADOW_VIEW_PARALLAX
	// Horizontal motion
	UIInterpolatingMotionEffect *horizontalShadow = [[UIInterpolatingMotionEffect alloc]
			initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontalShadow.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-nearShadowViewParallaxMultiple, 0, 0)];
	horizontalShadow.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation( nearShadowViewParallaxMultiple, 0, 0)];
	[_nearShadowView addMotionEffect:horizontalShadow];

	// Vertical motion
	UIInterpolatingMotionEffect *verticalShadow = [[UIInterpolatingMotionEffect alloc]
			initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	verticalShadow.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -nearShadowViewParallaxMultiple, 0)];
	verticalShadow.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0,  nearShadowViewParallaxMultiple, 0)];
	[_nearShadowView addMotionEffect:verticalShadow];
#endif

#ifdef FAR_SHADOW_VIEW_PARALLAX
	// Horizontal motion
	UIInterpolatingMotionEffect *horizontalFarShadow = [[UIInterpolatingMotionEffect alloc]
			initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontalFarShadow.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-farShadowViewParallaxMultiple, 0, 0)];
	horizontalFarShadow.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation( farShadowViewParallaxMultiple, 0, 0)];
	[_farShadowView addMotionEffect:horizontalFarShadow];

	// Vertical motion
	UIInterpolatingMotionEffect *verticalFarShadow = [[UIInterpolatingMotionEffect alloc]
			initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	verticalFarShadow.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -farShadowViewParallaxMultiple, 0)];
	verticalFarShadow.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0,  farShadowViewParallaxMultiple, 0)];
	[_farShadowView addMotionEffect:verticalFarShadow];
#endif

	[self observeThumbViewFrame];
}

- (void)thumbViewFrameChanged
{
	NSLog(@"%@", NSStringFromCGRect(self.thumbView.frame) );
	[self synchronizeThumbViewAndShadows];
}

- (void)synchronizeThumbViewAndShadows
{
	_nearShadowView.center = CGPointMake(self.thumbView.center.x, self.thumbView.center.y + 3);
	_farShadowView.center = CGPointMake(self.thumbView.center.x, self.thumbView.center.y + 5.5);
}


#pragma mark - Key Value Observing

/// For use in KVO contexts.
static void *MTZSliderThumbViewFrameContext = &MTZSliderThumbViewFrameContext;

#warning The thumb view is actually the image view.
#warning The shadows should stretch on active state of thumb.
- (void)observeThumbViewFrame
{
	NSLog(@"%@", NSStringFromCGRect(self.thumbView.frame));
	// Observe frame of the thumb view.
	[self.thumbView addObserver:self
					 forKeyPath:@"frame"
						options:NSKeyValueObservingOptionNew
						context:MTZSliderThumbViewFrameContext];
}

- (void)stopObservingThumbViewFrame
{
	@try {
		[self.thumbView removeObserver:self
							forKeyPath:@"frame"
							   context:MTZSliderThumbViewFrameContext];
	} @catch (NSException *exception) {
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if ( context == MTZSliderThumbViewFrameContext ) {
		if ( [keyPath isEqualToString:@"frame"] ) {
			[self thumbViewFrameChanged];
		}
	}
}

@end
