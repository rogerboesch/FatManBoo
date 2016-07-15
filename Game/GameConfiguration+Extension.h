//
//  GameConfiguration+Extension.h
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "GameConfiguration.h"

@interface GameConfiguration (Extension)

@property (nonatomic,readwrite) BOOL showPhysics;
@property (nonatomic,readwrite) BOOL playAudio;

- (void)loadConfiguration;
- (void)saveConfiguration;

@end
