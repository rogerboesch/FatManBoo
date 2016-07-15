//
//  GameConfiguration+Extension.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//
//  Holds the game configuration, like:
//  - control type: Pad or accelerometer
//  - Joystic: 4-way or 2-way
//  - Buttons: 1 or 2 buttons
//  - Gravity: Default gravity for the level
//  - ShowPhyics: Show Box2D frame's

#import "GameConfiguration+Extension.h"

BOOL showPhysics = NO;
BOOL playAudio = NO;

@implementation GameConfiguration (Extension)

// -----------------------------------------------------------------------------

- (void)setShowPhysics:(BOOL)aFlag {
	showPhysics = aFlag;
}

// -----------------------------------------------------------------------------

- (BOOL)showPhysics {
	return showPhysics;
}

// -----------------------------------------------------------------------------

- (void)setPlayAudio:(BOOL)aFlag {
	playAudio = aFlag;
	[self saveConfiguration];
}

// -----------------------------------------------------------------------------

- (BOOL)playAudio {
	return playAudio;
}

// -----------------------------------------------------------------------------

- (void)loadConfiguration {
	NSString *myKey = [NSString stringWithFormat:@"firstStartup"];
	NSNumber *myNumber = [[NSUserDefaults standardUserDefaults] objectForKey:myKey];
	if (myNumber == nil) {
		// This happens only the first time
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"firstStartup"];	
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"playAudio"];	
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	myKey = [NSString stringWithFormat:@"playAudio"];
	myNumber = [[NSUserDefaults standardUserDefaults] objectForKey:myKey];
	if (myNumber == nil) {
		playAudio = NO;
		return;
	}
	
	if ([myNumber intValue] == 1) {
		playAudio = YES;
	}
}

// -----------------------------------------------------------------------------

- (void)saveConfiguration {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:playAudio] forKey:@"playAudio"];	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

// -----------------------------------------------------------------------------

@end
