//
//  MTZDatePicker.m
//  MotionUIControls
//
//  Created by Matt Zanchelli on 3/17/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZDatePicker.h"

@interface MTZDatePicker ()

@end


@implementation MTZDatePicker

#pragma mark - Creating & Deallocating

- (instancetype)init
{
	self = [super init];
	if ( self ) {
		[self _MTZDatePicker_setUp];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		[self _MTZDatePicker_setUp];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self _MTZDatePicker_setUp];
    }
    return self;
}

- (void)_MTZDatePicker_setUp
{
	[self setUpMotionEffects];
}

- (void)setUpMotionEffects
{
	// Horizontal motion
	UIInterpolatingMotionEffect *horizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontal.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-10, 0, 0)];
	horizontal.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation( 10, 0, 0)];
	[self addMotionEffect:horizontal];
	
	// Vertical motion
	UIInterpolatingMotionEffect *vertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.transform" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	vertical.minimumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -10, 0)];
	vertical.maximumRelativeValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0,  10, 0)];
	[self addMotionEffect:vertical];
}


#pragma mark - Properties




#pragma mark - Motion Effects




#pragma mark - Key Value Observing




@end
