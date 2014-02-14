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

@end


@implementation MTZSlider

#pragma mark - Creating & Deallocating

- (instancetype)init
{
	self = [super init];
	if ( self ) {
		[self _MTZSlider_setup];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		[self _MTZSlider_setup];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self ) {
		[self _MTZSlider_setup];
	}
	return self;
}

- (void)_MTZSlider_setup
{
	// Begin observing thumb view.
	[self performSelector:@selector(setUpThumbViewMotionEffects) withObject:nil afterDelay:DBL_MIN];
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

- (UIView *)thumbView
{
	return (UIView *) [self valueForKeyPath:@"_thumbViewNeue"];
}


#pragma mark - Motion Effects

#ifdef THUMB_VIEW_PARALLAX
static int thumbViewParallaxAbsoluteMax = 4;
#endif

- (void)setUpThumbViewMotionEffects
{
#ifdef THUMB_VIEW_PARALLAX
	// Horizontal motion
	UIInterpolatingMotionEffect *horizontal =
		[[UIInterpolatingMotionEffect alloc]
			 initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontal.minimumRelativeValue = @(-thumbViewParallaxAbsoluteMax);
	horizontal.maximumRelativeValue = @(thumbViewParallaxAbsoluteMax);
	[self.thumbView addMotionEffect:horizontal];
	
	// Vertical motion
	UIInterpolatingMotionEffect *vertical =
		[[UIInterpolatingMotionEffect alloc]
			 initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	vertical.minimumRelativeValue = @(-thumbViewParallaxAbsoluteMax);
	vertical.maximumRelativeValue = @(thumbViewParallaxAbsoluteMax);
	[self.thumbView addMotionEffect:vertical];
#endif
	
//	[self observeThumbViewFrame];
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

- (void)thumbViewFrameChanged
{
	NSLog(@"%@", NSStringFromCGRect(self.thumbView.frame));
}

@end
