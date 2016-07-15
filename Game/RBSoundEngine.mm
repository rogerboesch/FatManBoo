//
//  RBSoundEngine.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "RBSoundEngine.h"
#import "SimpleAudioEngine.h"
#import "GameConfiguration+Extension.h"

static RBSoundEngine *_sharedSoundEngine;

@implementation RBSoundEngine

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Play music

- (void)playMusic:(NSString *)aMusicName loop:(BOOL)aFlag {
	if (![[GameConfiguration sharedConfiguration] playAudio]) {
		RBDebug(@"Muted. Music will not played");
		return;
	}

	RBDebug1(@"Play background music: %@", aMusicName);
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:aMusicName loop:aFlag];
}

// -----------------------------------------------------------------------------

- (void)stopMusic {
	RBDebug(@"Stop background music");
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Play effect

- (void)playEffect:(NSString *)aSoundName {
	if (![[GameConfiguration sharedConfiguration] playAudio]) {
		RBDebug1(@"Muted. Effect %@ will not played", aSoundName);
		return;
	}
	
	RBDebug1(@"Play sound effect: %@", aSoundName);
	[[SimpleAudioEngine sharedEngine] playEffect:aSoundName];
}

// -----------------------------------------------------------------------------

- (ALuint)playLoopedEffect:(NSString *)aSoundName {
	if (![[GameConfiguration sharedConfiguration] playAudio]) {
		RBDebug1(@"Muted. Looped effect %@ will not played", aSoundName);
		return CD_MUTE;
	}
	
	RBDebug1(@"Play looped sound effect not implemented: %@", aSoundName);
	return 0;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Vibrate

- (void)vibrate {
	if (![[GameConfiguration sharedConfiguration] playAudio]) {
		RBDebug(@"Muted. Vibration is not played");
		return;
	}

#ifndef MAC_VERSION
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Preload music and effects

- (void)preloadEffect:(NSString *)aSoundName {
	RBDebug1(@"Preload sound effect: %@", aSoundName);
	[[SimpleAudioEngine sharedEngine] preloadEffect:aSoundName];
}

// -----------------------------------------------------------------------------

- (void)preload {
	[self preloadEffect:@"explosion.wav"];
	[self preloadEffect:@"pickup.wav"];
	[self preloadEffect:@"jump.wav"];
	[self preloadEffect:@"glass.wav"];
	[self preloadEffect:@"button.caf"];
	[self preloadEffect:@"enemy-touched.wav"];
	[self preloadEffect:@"hero-touched.wav"];
	[self preloadEffect:@"laughter.wav"];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Singleton stuff

+ (RBSoundEngine *)sharedEngine {
	@synchronized([RBSoundEngine class]) {
		if (!_sharedSoundEngine)
			[[self alloc] init];
		return _sharedSoundEngine;
	}
	
	return nil;
}

// -----------------------------------------------------------------------------

+ (id)alloc {
	@synchronized([RBSoundEngine class]) {
		NSAssert(_sharedSoundEngine == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedSoundEngine = [super alloc];
		return _sharedSoundEngine;
	}
	
	return nil;
}

// -----------------------------------------------------------------------------

- (id)init {
	if ((self=[super init]) ) {
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end
