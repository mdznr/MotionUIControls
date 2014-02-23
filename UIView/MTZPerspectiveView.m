//
//  MTZPerspectiveView.m
//  MotionUIControls
//
//  Created by Matt Zanchelli on 2/16/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZPerspectiveView.h"

#define SHOULD_RASTERIZE

@implementation MTZPerspectiveView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self ) {
		[self __MTZPerspectiveView_setUp];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		[self __MTZPerspectiveView_setUp];
	}
	return self;
}

- (instancetype)init
{
	self = [super init];
	if ( self ) {
		[self __MTZPerspectiveView_setUp];
	}
	return self;
}

- (void)__MTZPerspectiveView_setUp
{
	// Default perspective type
	[self setPerspectiveType:MTZPerspectiveTypeDefault];
}

CATransform3D makeSkew(CGFloat x, CGFloat y)
{
	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = 1.0f / 2000;
	return CATransform3DRotate(transform, 60.0f * M_PI / 180.0f, x, y, 0);
}

- (void)setPerspectiveType:(MTZPerspectiveViewType)perspectiveType
{
	_perspectiveType = perspectiveType;
	
	// Clear out motion effects.
	self.motionEffects = nil;
	
	// Determine multiplier, or exit early.
	int multiplier = 0;
	if ( _perspectiveType == MTZPerspectiveTypeUser )  {
#ifdef SHOULD_RASTERIZE
		self.layer.shouldRasterize = YES;
#endif
		multiplier = -1;
	} else if ( _perspectiveType == MTZPerspectiveTypeDevice ) {
#ifdef SHOULD_RASTERIZE
		self.layer.shouldRasterize = YES;
#endif
		multiplier = 1;
	} else {
#ifdef SHOULD_RASTERIZE
		self.layer.shouldRasterize = NO;
#endif
		return;
	}
	
	// Horizontal motion
	UIInterpolatingMotionEffect *horizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontal.minimumRelativeValue = [NSValue valueWithCATransform3D:makeSkew(0,  1 * multiplier)];
	horizontal.maximumRelativeValue = [NSValue valueWithCATransform3D:makeSkew(0, -1 * multiplier)];
	[self addMotionEffect:horizontal];
	
	// Vertical motion
	UIInterpolatingMotionEffect *vertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	vertical.minimumRelativeValue = [NSValue valueWithCATransform3D:makeSkew(-1 * multiplier, 0)];
	vertical.maximumRelativeValue = [NSValue valueWithCATransform3D:makeSkew( 1 * multiplier, 0)];
	[self addMotionEffect:vertical];
}

@end
