//
//  MTZPerspectiveView.h
//  MotionUIControls
//
//  Created by Matt Zanchelli on 2/16/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Describes the level of contrast (perceived difference) between colors.
typedef NS_ENUM(NSInteger, MTZPerspectiveViewType) {
	/// Does not transform the view.
	MTZPerspectiveTypeDefault = 0,
	
	/// Transform the view to be perpendicular to the user's assumed perspective (against the motion of the device).
	/// @discussion This is useful when testing on device.
	MTZPerspectiveTypeUser,
	
	/// Transforms the view to tilt with the motion of the device.
	/// @discussion This is useful when mirroring the display for demonstration.
	MTZPerspectiveTypeDevice,
} NS_ENUM_AVAILABLE_IOS(7_0);

@interface MTZPerspectiveView : UIView

/// The type of perspective the view should be regarding perspective.
@property (nonatomic) MTZPerspectiveViewType perspectiveType;

@end
