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

/// The shadow view.
@property (strong, nonatomic) UIImageView *shadowView;

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
	_shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
	_shadowView.center = self.thumbView.center;
	
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

static NSString *thumbViewKeyPath = @"_thumbViewNeue";

- (UIView *)thumbView
{
	return (UIView *) [self valueForKeyPath:thumbViewKeyPath];
}


#pragma mark - Motion Effects

#ifdef THUMB_VIEW_PARALLAX
static int thumbViewParallaxAbsoluteMax = 40;
#endif

- (void)setUpThumbViewMotionEffects
{
#ifdef THUMB_VIEW_PARALLAX
	// Horizontal motion
	UIInterpolatingMotionEffect *horizontal = [[UIInterpolatingMotionEffect alloc]
			 initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
//	horizontal.minimumRelativeValue = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(-thumbViewParallaxAbsoluteMax, 0)];
//	horizontal.maximumRelativeValue = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(thumbViewParallaxAbsoluteMax, 0)];
	horizontal.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-thumbViewParallaxAbsoluteMax, 0, 0)];
	horizontal.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(thumbViewParallaxAbsoluteMax, 0, 0)];
	[self.thumbView addMotionEffect:horizontal];
	
	// Vertical motion
	UIInterpolatingMotionEffect *vertical = [[UIInterpolatingMotionEffect alloc]
			 initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
//	vertical.minimumRelativeValue = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(0, -thumbViewParallaxAbsoluteMax)];
//	vertical.maximumRelativeValue = [NSValue valueWithCGAffineTransform:CGAffineTransformMakeTranslation(0, thumbViewParallaxAbsoluteMax)];
	vertical.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -thumbViewParallaxAbsoluteMax, 0)];
	vertical.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, thumbViewParallaxAbsoluteMax, 0)];
	[self.thumbView addMotionEffect:vertical];
	
	UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
	group.motionEffects = @[horizontal, vertical];
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
