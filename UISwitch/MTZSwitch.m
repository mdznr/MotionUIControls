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
#define THUMB_VIEW_PARALLAX

/// Enable parallax effect on the near shadow view.
#define NEAR_SHADOW_VIEW_PARALLAX


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
	// Stop observing thumb view frame.
	@try {
		[self.thumbView removeObserver:self
							forKeyPath:@"frame"
							   context:ThumbViewFrameContext];
	} @catch (NSException *exception) {
	}
}


#pragma mark - Properties

/*
 
 po [self _ivarDescription]
 ...
 _control (UIView<_UISwitchInternalViewProtocol>*): <_UISwitchInternalViewNeueStyle1: 0x10980a390>
 ...
 
 
 po [self valueForKeyPath:@"_control"]
 <_UISwitchInternalViewNeueStyle1: 0x10980a390; frame = (0 0; 51 31); gestureRecognizers = <NSArray: 0x10980bab0>; layer = <CALayer: 0x10980a4c0>>
 
 
 po [[self valueForKeyPath:@"_control"] subviews]
 <__NSArrayM 0x10980c2f0>(
 <UIView: 0x10980a860; frame = (35.5 0; 15.5 31); clipsToBounds = YES; layer = <CALayer: 0x10980a920>>,
 <UIView: 0x10980a780; frame = (0 0; 35.5 31); clipsToBounds = YES; layer = <CALayer: 0x10980a840>>,
 <UIView: 0x10980b340; frame = (0 0; 51 31); layer = <CALayer: 0x10980b400>>,
 <UIImageView: 0x10980ad40; frame = (7 -6; 57 43.5); opaque = NO; userInteractionEnabled = NO; layer = <CALayer: 0x10980ae70>>
 )
 
 */

- (UIView *)thumbView
{
	// If already found once, return it early.
	if ( _thumbView != nil ) return _thumbView;
	
	// Find thumb view.
	NSArray *subviews = [[self valueForKeyPath:@"_control"] subviews];
	
	// Find and return the first image view (assuming there's only one).
	for ( UIView *view in subviews ) {
		if ( [view isKindOfClass:[UIImageView class]] ) {
			self.thumbView = view;
			return self.thumbView;
		}
	}
	
	// Could not find the thumb view.
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

#warning The thumb view is actually the image view.
#warning The shadows should stretch on active state of thumb.
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
