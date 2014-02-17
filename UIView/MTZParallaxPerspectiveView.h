//
//  MTZParallaxPerspectiveView.h
//  MotionUIControls
//
//  Created by Matt Zanchelli on 2/16/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import <UIKit/UIKit.h>

#warning Should this be a subclass of `UIView` or `UIWindow`?

/// Describes the level of contrast (perceived difference) between colors.
typedef NS_ENUM(NSInteger, MTZParallaxPerspectiveViewType) {
	/// Transform the view to be perpendicular to the user's assumed perspective (against the motion of the device).
	/// @discussion This is useful when testing on device.
	MTZParallaxPerspectiveTypeUser,
	
	/// Transforms the view to tilt with the motion of the device.
	/// @discussion This is useful when mirroring the display for demonstration.
	MTZParallaxPerspectiveTypeDevice
} NS_ENUM_AVAILABLE_IOS(7_0);

@interface MTZParallaxPerspectiveView : UIView

@property (nonatomic) MTZParallaxPerspectiveViewType perspectiveType;

@end
