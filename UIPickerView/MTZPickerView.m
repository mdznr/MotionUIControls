//
//  MTZPickerView.m
//  MotionUIControls
//
//  Created by Matt Zanchelli on 3/17/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZPickerView.h"

@interface MTZPickerView ()

@end


@implementation MTZPickerView

#pragma mark - Creating & Deallocating

- (instancetype)init
{
	self = [super init];
	if ( self ) {
		[self _MTZPickerView_setUp];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		[self _MTZPickerView_setUp];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self _MTZPickerView_setUp];
    }
    return self;
}

- (void)_MTZPickerView_setUp
{
	
}


#pragma mark - Properties




#pragma mark - Motion Effects




#pragma mark - Key Value Observing




@end
