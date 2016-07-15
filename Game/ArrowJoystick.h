//
//  ArrowJoystick.h
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "JoystickProtocol.h"

enum {
	BUTTON_A,
	JOYSTICK_CAR_LEFT,
	JOYSTICK_CAR_RIGHT,
	JOYSTICK_CAR_MAX,
};

@interface ArrowJoystick : CCLayer <JoystickProtocol> {
	struct Button buttons_[JOYSTICK_CAR_MAX];
}

+ (id)joystick;

@end
