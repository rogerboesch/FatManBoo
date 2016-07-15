//
//  MenuScene.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "MenuScene.h"
#import "MenuHero.h"
#import "GameDelegate.h"
#import "ChapterChooseScene.h"
#import "GameConfiguration+Extension.h"
#import "RBSoundEngine.h"

#ifndef MAC_VERSION
#import "AppDelegate.h"
#endif

@implementation MenuScene

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark When tranistion is done

- (void)onEnterTransitionDidFinish {
	[super onEnterTransitionDidFinish];

#ifndef MAC_VERSION
	GameDelegate *appDelegate = (GameDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate authenticateLocalPlayer];
#endif
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Actions

- (void)buttonPlay:(id)sender {
	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[ChapterChooseScene scene]]];
}

// -----------------------------------------------------------------------------

- (void)buttonLeaderboard:(id)sender {
	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
#ifndef MAC_VERSION
	GameDelegate *appDelegate = (GameDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate showLeaderboard];
#endif
}

// -----------------------------------------------------------------------------

- (void)buttonAchievments:(id)sender {
	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
#ifndef MAC_VERSION
	GameDelegate *appDelegate = (GameDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate showAchievements];
#endif
}

// -----------------------------------------------------------------------------

- (void)buttonAudio:(CCMenuItemImage *)item {
	if ([[GameConfiguration sharedConfiguration] playAudio]) {
		[[GameConfiguration sharedConfiguration] setPlayAudio:NO];
		[item unselected];
		
		// Stop background music
		[[RBSoundEngine sharedEngine] stopMusic];
	}
	else {
		[[GameConfiguration sharedConfiguration] setPlayAudio:YES];
		[item selected];
		
		// Play background music
		//[[RBSoundEngine sharedEngine] playMusic:@"music-menu.wav" loop:YES];
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Wind animation

- (void)windAnimation:(CCSprite *)aSprite {
	id action1 = [CCLiquid actionWithWaves:80 amplitude:2 grid:ccg(20,15) duration:200];
	id seq = [CCSequence actions:action1, [CCStopGrid action], nil];
	[aSprite runAction:seq];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

+ (id)scene {
	CCScene *s = [CCScene node];
	id node = [MenuScene node];
	[s addChild:node];
	
	return s;
}

// -----------------------------------------------------------------------------

- (id)init {
	if ((self=[super init])) {
		CGSize size = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu.plist"];

		CCSprite *background = nil;

#ifdef MAC_VERSION
		background = [CCSprite spriteWithFile:@"menu-background-big.png"];
#else
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			background = [CCSprite spriteWithFile:@"menu-background-big.png"];
		}
		else {
			background = [CCSprite spriteWithFile:@"menu-background.png"];
		}
#endif
		
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background z:0];
		[self windAnimation:background];
		
		// Menu elements
		CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"bush-top-left.png"];
		sprite.anchorPoint = ccp(0, 1.0);
		sprite.position = ccp(0, size.height);
		[self addChild:sprite z:1];
		
		sprite = [CCSprite spriteWithSpriteFrameName:@"bush-top-right.png"];
		sprite.anchorPoint = ccp(1.0, 1.0);
		sprite.position = ccp(size.width, size.height);
		[self addChild:sprite z:1];

		sprite = [CCSprite spriteWithSpriteFrameName:@"bush-bot-left.png"];
		sprite.anchorPoint = ccp(0, 0);
		sprite.position = ccp(0, 50);
		[self addChild:sprite z:3];
		
		sprite = [CCSprite spriteWithSpriteFrameName:@"big-stone.png"];
		sprite.anchorPoint = ccp(0.5, 0);
		sprite.position = ccp(size.width/2.0, 50);
		[self addChild:sprite z:3];
		
		sprite = [CCSprite spriteWithSpriteFrameName:@"fatman-logo.png"];
		sprite.anchorPoint = ccp(0.5, 0);
		sprite.position = ccp(size.width/2.0, 50);
		[self addChild:sprite z:4];
		
		// Ground
		int numberOfGround = self.contentSize.width / 480 + 5;
		for (int i = 0; i <= numberOfGround; i++) {
			CCSprite *ground = [CCSprite spriteWithFile:@"chapter1-ground.png"];
			ground.anchorPoint = ccp(0,0);
			ground.position = ccp(i*479.0, -50);
			[self addChild:ground z:20];
		}

		// Bubbles
		sprite = [CCSprite spriteWithSpriteFrameName:@"bubble-left.png"];
		sprite.anchorPoint = ccp(0, 0);
		sprite.position = ccp(0, 0);
		[self addChild:sprite z:21];
		sprite = [CCSprite spriteWithSpriteFrameName:@"bubble-right.png"];
		sprite.anchorPoint = ccp(1, 0);
		sprite.position = ccp(size.width, 0);
		[self addChild:sprite z:21];
		
		// Play
		CCMenuItem *item = [CCMenuItemImage itemWithNormalImage:@"btn-play-normal.png" selectedImage:@"btn-play-selected.png" target:self selector:@selector(buttonPlay:)];
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu z:21];
		[menu setPosition:ccp(size.width-47, 61)];
		
		// Leaderboard
#ifndef MAC_VERSION
		item = [CCMenuItemImage itemWithNormalImage:@"btn-leader-normal.png" selectedImage:@"btn-leader-selected.png" target:self selector:@selector(buttonLeaderboard:)];
		menu = [CCMenu menuWithItems:item, nil];
		item.anchorPoint = ccp(0, 0);
		[self addChild:menu z:21];
		[menu setPosition:ccp(10, 10)];
#endif
		
		// Achievments
		//item = [CCMenuItemImage itemWithNormalImage:@"btn-achieve-normal.png" selectedImage:@"btn-achieve-selected.png" target:self selector:@selector(buttonAchievments:)];
		//menu = [CCMenu menuWithItems:item, nil];
		//item.anchorPoint = ccp(0, 0);
		//[self addChild:menu z:1];
		//[menu setPosition:ccp(60, 10)];
		
		// Audio on/off
		item = [CCMenuItemImage itemWithNormalImage:@"btn-audio-off.png" selectedImage:@"btn-audio-on.png" target:self selector:@selector(buttonAudio:)];
		menu = [CCMenu menuWithItems:item, nil];
		item.anchorPoint = ccp(0, 0);
		[self addChild:menu z:21];
		[menu setPosition:ccp(95, 95)];

		// Set image
		if ([[GameConfiguration sharedConfiguration] playAudio]) {
			[item selected];
		}
		else {
			[item unselected];
		}
		
		spritesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"menu.png" capacity:20];		
		[self addChild:spritesBatchNode_ z:0];
		
		// Add menu hero
		MenuHero *hero = [[MenuHero alloc] init];
		hero.position = ccp(size.width/2.0-10, 160);
		[spritesBatchNode_ addChild:hero z:0];
		[hero release];
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end
