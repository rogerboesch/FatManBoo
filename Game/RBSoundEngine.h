//
//  RBSoundEngine.h
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "SimpleAudioEngine.h"

@interface RBSoundEngine : NSObject {
}

// Play music
- (void)playMusic:(NSString *)aMusicName loop:(BOOL)aFlag;
- (void)stopMusic;

// Play effects
- (void)playEffect:(NSString *)aSoundName;
- (ALuint)playLoopedEffect:(NSString *)aSoundName;

// Vibrate
- (void)vibrate;

// Preload necc. sounds
- (void)preload;

+ (RBSoundEngine *)sharedEngine;

@end