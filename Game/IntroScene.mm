//
//  IntroScene.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "IntroScene.h"
#import "MenuScene.h"
#import "GameConfiguration+Extension.h"
#import "RBSoundEngine.h"

@implementation IntroScene

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Action

- (void) animationComplete:(ccTime)dt {
	// Play background music
	//[[RBSoundEngine sharedEngine] playMusic:@"music-menu.wav" loop:YES];

	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1.0f scene:[MenuScene scene]]];
}

// -----------------------------------------------------------------------------

- (void) wait4animation:(ccTime)dt {
	[self unschedule:@selector(wait4animation:)];

	logo_.visible = YES;
	id scal1 = [CCScaleTo actionWithDuration:0.2 scale:1.5];
	id scal2 = [CCScaleTo actionWithDuration:0.2 scale:0.7];
	id scal3 = [CCScaleTo actionWithDuration:0.2 scale:1.0];
	id sleep = [CCDelayTime actionWithDuration:2.0];
	id fnc = [CCCallFuncND actionWithTarget:self selector:@selector(animationComplete:) data:nil];
	id seq = [CCSequence actions:scal1, scal2, scal3, sleep, fnc, nil];
	[logo_ runAction:seq];
}

// -----------------------------------------------------------------------------

- (void)showAnimation:(id)sender {
	[self unschedule:@selector(showAnimation:)];

	CGSize size = [[CCDirector sharedDirector] winSize];

	int y = size.height/2.0-60;
	
	//CCParticleGalaxy *system = [[CCParticleGalaxy alloc] init];
	CCParticleFire *system = [[CCParticleFire alloc] init];
	system.position = CGPointMake(-100, y);
	[self addChild:system];
	[system release];

	id action = [CCMoveBy actionWithDuration:1.0 position:CGPointMake(size.width *2, 0)];
	[system runAction:action];

	logo_ = [CCSprite spriteWithFile:@"artandbits.png"];
	logo_.position =CGPointMake(size.width/2.0, size.height/2.0);
	logo_.visible = NO;
	logo_.scale = 0.0;
	[self addChild:logo_];

	[self schedule:@selector(wait4animation:) interval:0.4];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

+ (id)scene {
	CCScene *s = [CCScene node];
	id node = [IntroScene node];
	[s addChild:node];

	[[GameConfiguration sharedConfiguration] loadConfiguration];

	return s;
}

// -----------------------------------------------------------------------------

- (id)init {
	if ((self=[super init])) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];

		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"Default-568h@2x.png"];
        background.scale = 0.5;
		background.rotation = 90;
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background];
		
		[self schedule:@selector(animationComplete:) interval:2.0];
	}

	return self;
}

// -----------------------------------------------------------------------------

@end
