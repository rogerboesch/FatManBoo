//
//  HelpScene.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "HelpScene.h"
#import "LevelChooseScene.h"
#import "GameConfiguration+Extension.h"
#import "RBSoundEngine.h"
#import "Level.h"
#import "SlidingMenuGrid.h"

#ifndef MAC_VERSION
#import "AppDelegate.h"
#endif

@implementation HelpScene

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Actions

- (void)buttonPlay:(id)sender {
	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[Level scene]]];
}

// -----------------------------------------------------------------------------

- (void)buttonBack:(id)sender {
	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[LevelChooseScene scene]]];
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
#pragma mark Show help panel and text

- (void)showPageWithIndex:(int)aNumber {
	switch (aNumber) {
		case 0:
			[helpText_ setString:RBLocalizedString(@"HelpString1")];
			break;
		case 1:
			[helpText_ setString:RBLocalizedString(@"HelpString2")];
			break;
		case 2:
			[helpText_ setString:RBLocalizedString(@"HelpString3")];
			break;
	}
	
	id scaleTo = [CCScaleTo actionWithDuration:0.3f scale:1.5f];
	id scaleBack = [CCScaleTo actionWithDuration:0.3f scale:1];
	id seq = [CCSequence actions:scaleTo, scaleBack, nil];
	[helpText_ runAction:seq];
}

// -----------------------------------------------------------------------------

- (void)pressItem:(id)Sender {}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

+ (id)scene {
	CCScene *s = [CCScene node];
	id node = [HelpScene node];
	[s addChild:node];
	
	return s;
}

// -----------------------------------------------------------------------------

- (id)init {
	if ((self=[super init])) {
		CGSize size = [[CCDirector sharedDirector] winSize];

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

		NSMutableArray* allItems = [NSMutableArray arrayWithCapacity:5];
		for (int i = 1; i <= 3; ++i) {
			NSString* helpImage = [NSString stringWithFormat:@"help-%d.png", i];
			
			CCSprite* sprite = [CCSprite spriteWithFile:helpImage];
			CCSprite* selectedSprite = [CCSprite spriteWithFile:helpImage];
  			CCMenuItemSprite* item =[CCMenuItemSprite itemWithNormalSprite:sprite selectedSprite:selectedSprite target:self selector:@selector(pressItem:)];
			[allItems addObject:item];
		}
		
		SlidingMenuGrid* menuGrid = [SlidingMenuGrid menuWithArray:allItems cols:1 rows:1 position:CGPointMake(240, 190) padding:CGPointMake(0, 0) verticalPages:false];
		[self addChild:menuGrid];
		menuGrid.delegate = self;
		menuGrid.bSwipeOnlyOnMenu = true;

		sprite = [CCSprite spriteWithSpriteFrameName:@"info-panel.png"];
		sprite.anchorPoint = ccp(0.5, 0);
		sprite.position = ccp(size.width/2.0, 10);
		[self addChild:sprite z:20];
		
        helpText_ = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(260, 40) hAlignment:kCCTextAlignmentCenter fontName:@"Helvetica" fontSize:16];
		helpText_.color = ccBLACK;
		helpText_.anchorPoint = ccp(0.5, 0.5);
		helpText_.position = ccp(size.width/2.0, 43);
		[self addChild:helpText_ z:21];
		
		[self showPageWithIndex:0];
		
		// Play
		CCMenuItem *item = [CCMenuItemImage itemWithNormalImage:@"btn-play-normal.png" selectedImage:@"btn-play-selected.png" target:self selector:@selector(buttonPlay:)];
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu z:100];
		[menu setPosition:ccp(size.width-40, 40)];	
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end
