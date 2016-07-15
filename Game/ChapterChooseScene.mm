//
//  ChapterChooseScene.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "ChapterChooseScene.h"
#import "MenuScene.h"
#import "LevelManager.h"
#import "LevelChooseScene.h"
#import "RBSoundEngine.h"

#define kSpriteWidth 137

@implementation ChapterChooseScene

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Actions

- (void)backPressed:(id)sender {
	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MenuScene scene]]];
}

// -----------------------------------------------------------------------------

- (void)choosePressed:(CCMenuItem *)item {
	CCLOG(@"Pressed: %@", item);
	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
	[[LevelManager sharedManager] setLevel:1 inChapter:item.tag];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[LevelChooseScene scene]]];
}

// -----------------------------------------------------------------------------

- (void)addHammerAnimation:(CGPoint)aPosition {
	// Baby animation
	CCSprite *hero = [CCSprite spriteWithSpriteFrameName:@"hammer-01.png"];
    hero.scale = 0.7;
	hero.position = aPosition;
	[self addChild:hero z:24];

	// Animation
	NSMutableArray *spriteFrames = [NSMutableArray array];
	for (int i = 1; i <= 7; i++) {
		[spriteFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"hammer-%02d.png", i]]];
	}
	
	id animation = [CCAnimation animationWithSpriteFrames:spriteFrames delay:0.1f];
	id animate = [CCAnimate actionWithAnimation:animation];
	id sleep = [CCAnimate actionWithDuration:2.0];
	id action = [CCSequence actions:animate, sleep, nil];
	[hero runAction:[CCRepeatForever actionWithAction:action]];
}

// -----------------------------------------------------------------------------

- (void)addBabyAnimation:(CGPoint)aPosition {
	// Baby animation
	CCSprite *baby = [CCSprite spriteWithSpriteFrameName:@"head-01.png"];
	baby.position = aPosition;
	[self addChild:baby z:24];
	
	// Animation
	NSMutableArray *spriteFrames = [NSMutableArray array];
	for (int i = 1; i <= 7; i++) {
		[spriteFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"head-%02d.png", i]]];
	}
	
	id animation = [CCAnimation animationWithSpriteFrames:spriteFrames delay:0.1f];
	id action = [CCAnimate actionWithAnimation:animation];
	[baby runAction:[CCRepeatForever actionWithAction:action]];
}

// -----------------------------------------------------------------------------

- (void)addCloudAnimation:(CGPoint)aPosition {
	// Baby animation
	CCSprite *cloud = [CCSprite spriteWithSpriteFrameName:@"cloud.png"];
	cloud.scale = 0.5;
	cloud.position = aPosition;
	[self addChild:cloud z:24];	
	
	// Animation
	id action1 = [CCMoveBy actionWithDuration:2.0 position:ccp(-10, 0)];
	id action2 = [CCMoveBy actionWithDuration:4.0 position:ccp(20, 0)];
	id action3 = [CCMoveBy actionWithDuration:2.0 position:ccp(-10, 0)];
	id seq = [CCSequence actions:action1, action2, action3, nil];
	[cloud runAction:[CCRepeatForever actionWithAction:seq]];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialization

+ (id)scene {
	CCScene *s = [CCScene node];
	id node = [ChapterChooseScene node];
	[s addChild:node];
	
	return s;
}

// -----------------------------------------------------------------------------

- (void)initChapters {
	CGSize size = [[CCDirector sharedDirector] winSize];
	int y = size.height / 3 * 2;
	int space = (size.width - (NUMBER_OF_CHAPTERS * kSpriteWidth)) / (NUMBER_OF_CHAPTERS + 1);
	int x = space + kSpriteWidth/2.0;
	for (int i = 1; i <= NUMBER_OF_CHAPTERS; i++) {
		
		BOOL enabled = [[LevelManager sharedManager] isChapterUnlocked:i];
		
		if (enabled) {
			CCMenuItem *item = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"world-%d-unlocked.png", i] selectedImage:[NSString stringWithFormat:@"world-%d-unlocked.png", i] target:self selector:@selector(choosePressed:)];
			item.anchorPoint = ccp(0.5, 0.5);
			item.tag = i;
			CCMenu *menu = [CCMenu menuWithItems:item, nil];
			menu.anchorPoint = ccp(0,0);
			menu.position = ccp(x, y);
			[self addChild:menu z:23];
			
			switch (i) {
				case 1:
					[self addBabyAnimation:ccp(x+5, y+64)];
					break;
				case 2:
					[self addCloudAnimation:ccp(x+5, y+64)];
					break;
				case 3:
					[self addHammerAnimation:ccp(x+5, y+44)];
					break;
			}
		}
		else {
			CCSprite *sprite = [CCSprite spriteWithFile:@"world-locked.png"];
			sprite.position = ccp(x, y);
			[self addChild:sprite z:23];
		}
		
		CCLOG(@"Pos: %d" , x);
		x += space + kSpriteWidth;
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

- (id)init {
	if ((self = [super init])) {
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
		CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"bush-bot-left.png"];
		sprite.anchorPoint = ccp(0, 0);
		sprite.position = ccp(0, 30);
		[self addChild:sprite z:3];
		
		// Ground
		int numberOfGround = self.contentSize.width / 480 + 5;
		for (int i = 0; i <= numberOfGround; i++) {
			CCSprite *ground = [CCSprite spriteWithFile:@"chapter1-ground.png"];
			ground.anchorPoint = ccp(0,0);
			ground.position = ccp(i*479.0, -50);
			[self addChild:ground z:20];
		}
		
		// Bubbles
		sprite = [CCSprite spriteWithSpriteFrameName:@"bubble-right.png"];
		sprite.anchorPoint = ccp(0, 0);
		sprite.position = ccp(0, 0);
		sprite.flipX = YES;
		[self addChild:sprite z:21];
		sprite = [CCSprite spriteWithSpriteFrameName:@"bubble-left.png"];
		sprite.anchorPoint = ccp(1, 0);
		sprite.position = ccp(size.width, 0);
		sprite.flipX = YES;
		[self addChild:sprite z:21];
		
		id action1 = [CCLiquid actionWithWaves:80 amplitude:2 grid:ccg(20,15) duration:200];
		id seq = [CCSequence actions:action1, [CCStopGrid action], nil];
		[background runAction:seq];

		// Back button
		CCMenuItem *item = [CCMenuItemImage itemWithNormalImage:@"btn-back-normal.png" selectedImage:@"btn-back-selected.png" target:self selector:@selector(backPressed:)];
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[menu setPosition:ccp(37, 37)];
		[self addChild:menu z:22];

		spritesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:20];		
		[self addChild:spritesBatchNode_ z:0];
		
		// Init chapters
		[self initChapters];
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end
