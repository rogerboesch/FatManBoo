//
//  LevelChooseScene.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "LevelChooseScene.h"
#import "ChapterChooseScene.h"
#import "LevelManager.h"
#import "GameConfiguration+Extension.h"
#import "RBSoundEngine.h"
#import "Level.h"
#import "HelpScene.h"

#define kSpriteWidth 80
#define COLUMN_COUNT 5

@implementation LevelChooseScene

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Actions

- (void)backPressed:(id)sender {
	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[ChapterChooseScene scene]]];
}

// -----------------------------------------------------------------------------

- (void)choosePressed:(CCMenuItem *)item {
	CCLOG(@"Pressed: %@", item);

	// Stop background music
	[[RBSoundEngine sharedEngine] stopMusic];

	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
	
	// Activate level preview
	[Level enablePreview:YES];
	
	int chapter = [[LevelManager sharedManager] currentChapter];
	int level = item.tag;

	if (chapter == 1 && level == 1) {
		[[LevelManager sharedManager] setLevel:level inChapter:chapter];
		[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[HelpScene scene]]];
	}
	else {
		if (level == 15) {
			// De-Activate level preview in level 15 (bonus level)
			[Level enablePreview:NO];
		}
		
		[[LevelManager sharedManager] setLevel:level inChapter:chapter];
		[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[Level scene]]];
	}
}

// -----------------------------------------------------------------------------

- (void)lockedPressed:(CCMenuItem *)item {
	CCLOG(@"Locked pressed: %@", item);
}

// -----------------------------------------------------------------------------

- (void)scaleItemForDevices:(CCMenuItem *)aItem {	
#ifdef MAC_VERSION
	aItem.scale = 1.5;
#endif
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		aItem.scale = 1.5;
	}		
}

// -----------------------------------------------------------------------------

- (void)scaleSpriteForDevices:(CCSprite *)aSprite {	
#ifdef MAC_VERSION
	aSprite.scale = 1.5;
#endif
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		aSprite.scale = 1.5;
	}		
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialization

+ (id)scene {
	CCScene *s = [CCScene node];
	id node = [LevelChooseScene node];
	[s addChild:node];
	
	return s;
}

// -----------------------------------------------------------------------------

- (void)initLevels {
	[CCMenuItemFont setFontName:@"Marker Felt"];
	[CCMenuItemFont setFontSize:12];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	int space = (size.width - (COLUMN_COUNT * kSpriteWidth)) / (COLUMN_COUNT + 1);
	int vSpace = 2;
	int x = space + kSpriteWidth/2.0;
	int y = size.height - (size.height / 6.0);
	int columns = 1;

	
#ifdef MAC_VERSION
	vSpace = space;

#else
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		vSpace = space;
	}
	else {
		y = 275;
	}
#endif
	
	int chapter = [[LevelManager sharedManager] currentChapter];
	
	for (int i = 1; i <= NUMBER_OF_LEVELS_IN_CHAPTER; i++) {
		BOOL enabled = [[LevelManager sharedManager] isLevelUnlocked:i chapter:chapter];
		if (enabled) {
			int bonus = [[LevelManager sharedManager] bonusOfLevel:i chapter:chapter];

			if (i == NUMBER_OF_LEVELS_IN_CHAPTER) {
				if (bonus == BONUS_MAXIMUM) {
					CCMenuItem *item1 = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"%d-level15-bonus.png", chapter] selectedImage:[NSString stringWithFormat:@"%d-level15-bonus.png", chapter] target:self selector:@selector(choosePressed:)];
					item1.tag = i;
					CCMenu *menu = [CCMenu menuWithItems:item1, nil];
					menu.position = ccp(x, y);
					[self addChild:menu z:22];
					[self scaleItemForDevices:item1];
				}
				else {
					CCMenuItem *item1 = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"%d-level15-unlocked.png", chapter] selectedImage:[NSString stringWithFormat:@"%d-level15-unlocked.png", chapter] target:self selector:@selector(choosePressed:)];
					item1.tag = i;
					CCMenu *menu = [CCMenu menuWithItems:item1, nil];
					menu.position = ccp(x, y);
					[self addChild:menu z:22];
					[self scaleItemForDevices:item1];
				}
			}
			else {
				if (bonus == BONUS_MAXIMUM) {
					CCMenuItem *item1 = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"%d-level-bonus.png", chapter] selectedImage:[NSString stringWithFormat:@"%d-level-bonus.png", chapter] target:self selector:@selector(choosePressed:)];
					item1.tag = i;
					CCMenu *menu = [CCMenu menuWithItems:item1, nil];
					menu.position = ccp(x, y);
					[self addChild:menu z:22];
					[self scaleItemForDevices:item1];
				}
				else {
					CCMenuItem *item1 = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"%d-level-unlocked.png", chapter] selectedImage:[NSString stringWithFormat:@"%d-level-unlocked.png", chapter] target:self selector:@selector(choosePressed:)];
					item1.tag = i;
					CCMenu *menu = [CCMenu menuWithItems:item1, nil];
					menu.position = ccp(x, y);
					[self addChild:menu z:22];
					[self scaleItemForDevices:item1];
				}
			}
			
			// Points
			int points = [[LevelManager sharedManager] highscoreOfLevel:i chapter:chapter];
			if (points > 0) {
				CCLabelAtlas *info = [[CCLabelAtlas labelWithString:[NSString stringWithFormat:@"%04d", points] charMapFile:@"number_fonts_small.png" itemWidth:16 itemHeight:24 startCharMap:'0'] retain];
				info.anchorPoint = ccp(0.5, 0.5);
				[self addChild:info z:22];
				[info setPosition:ccp(x, y-20)];
			}
		}
		else {
			if (i == NUMBER_OF_LEVELS_IN_CHAPTER) {
				CCSprite *sprite = [CCSprite spriteWithFile:@"level-bonus-locked.png"];
				sprite.position = ccp(x, y);
				[self addChild:sprite z:22];
				[self scaleSpriteForDevices:sprite];
			}
			else {
				CCSprite *sprite = [CCSprite spriteWithFile:@"level-locked.png"];
				sprite.position = ccp(x, y);
				[self addChild:sprite z:22];
				[self scaleSpriteForDevices:sprite];
			}
		}
		
		if (columns == COLUMN_COUNT) {
			columns = 1;
			x = space + kSpriteWidth/2.0;
			y -= (vSpace + kSpriteWidth);
		}
		else {
			columns++;
			x += space + kSpriteWidth;
		}
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
		
		// Ground
		int numberOfGround = self.contentSize.width / 480 + 5;
		for (int i = 0; i <= numberOfGround; i++) {
			CCSprite *ground = [CCSprite spriteWithFile:@"chapter1-ground.png"];
			ground.anchorPoint = ccp(0,0);
			ground.position = ccp(i*479.0, -50);
			[self addChild:ground z:20];
		}
		
		// Bubbles
		CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"bubble-right.png"];
		sprite.anchorPoint = ccp(0, 0);
		sprite.position = ccp(0, 0);
		sprite.flipX = YES;
		[self addChild:sprite z:21];
		sprite = [CCSprite spriteWithSpriteFrameName:@"bubble-right.png"];
		sprite.anchorPoint = ccp(1, 0);
		sprite.position = ccp(size.width, 0);
		[self addChild:sprite z:21];
		
		id action1 = [CCLiquid actionWithWaves:80 amplitude:2 grid:ccg(20,15) duration:200];
		id seq = [CCSequence actions:action1, [CCStopGrid action], nil];
		[background runAction:seq];
		
		// Back button
		CCMenuItem *item = [CCMenuItemImage itemWithNormalImage:@"btn-back-normal.png" selectedImage:@"btn-back-selected.png" target:self selector:@selector(backPressed:)];
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[menu setPosition:ccp(37, 37)];
		[self addChild:menu z:22];
		
		if ([[LevelManager sharedManager] currentChapter] < 3) {
			[self initLevels];
		}
		else {
			sprite = [CCSprite spriteWithFile:@"coming-soon.png"];
			sprite.position = ccp(size.width/2.0, size.height/2.0);
			[self addChild:sprite z:22];
		}
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end
