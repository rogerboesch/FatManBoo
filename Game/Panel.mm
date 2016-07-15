//
//  Panel.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "Panel.h"
#import "GameNode.h"
#import "Level.h"
#import "MenuScene.h"
#import "LevelChooseScene.h"
#import "LevelManager.h"
#import "GameConfiguration+Extension.h"
#import "RBSoundEngine.h"

@implementation Panel

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Panel modi

- (void)activatePanelState:(PanelState)aState oldScore:(int)aOldScore newScore:(int)aNewScore {
	panelState_ = aState;
	[levelLabel_ setString:[NSString stringWithFormat:@"Level %@", [[LevelManager sharedManager] currentLevelChapter]]];

	CGSize s = [[CCDirector sharedDirector] winSize];

	switch (panelState_) {
		case kPanelStatePause:
			[titleLabel_ setString:@"- PAUSED -"];
			[scoreLabel_ setString:[NSString stringWithFormat:@"SCORE: %05d", aNewScore]];
			nextMenu_.visible = NO;
			playMenu_.visible = YES;
			break;
			
		case kPanelStateWinBonus:
			[titleLabel_ setString:@"GREAT - TOP SCORE!"];
			[scoreLabel_ setString:[NSString stringWithFormat:@"SCORE: %05d", aNewScore]];
			nextMenu_.visible = YES;
			playMenu_.visible = NO;

			{
				CCParticleSystem *system = [[CCParticleExplosion alloc] init];
				system.position = ccp(s.width/2.0, s.height/2.0);
				[self addChild:system];
				[[RBSoundEngine sharedEngine] playEffect:@"bonusreached.wav"];
			}
			break;

		case kPanelStateWin:
			[titleLabel_ setString:@"CONGRATULATION!"];
			[scoreLabel_ setString:[NSString stringWithFormat:@"SCORE: %05d", aNewScore]];
			nextMenu_.visible = YES;
			playMenu_.visible = NO;
			
			if ([[LevelManager sharedManager] currentLevel] == 15) {
				CCParticleSystem *system = [[CCParticleExplosion alloc] init];
				system.position = ccp(s.width/2.0, s.height/2.0);
				[self addChild:system];
				
				[[RBSoundEngine sharedEngine] playEffect:@"bonusreached.wav"];
			}
			break;
			
		case kPanelStateLoose:
			[titleLabel_ setString:@"UUPS, TRY AGAIN!"];
			[scoreLabel_ setString:[NSString stringWithFormat:@"SCORE: %05d", aNewScore]];
			nextMenu_.visible = YES;
			playMenu_.visible = NO;
			break;
			
		case kPanelStateInactive:
			CCLOG(@"Deactivate panel");
			return;
	}

	// Test if next level is available
	int chapter = [[LevelManager sharedManager] currentChapter];
	int level = [[LevelManager sharedManager] currentLevel];

	if ([[LevelManager sharedManager] isLastLevelInChapter]) {
		nextMenu_.visible = NO;
	}
	else {
		int nextLevel = level + 1;
		BOOL enabled = [[LevelManager sharedManager] isLevelUnlocked:nextLevel chapter:chapter];
		nextMenu_.visible = enabled;
	}
	
	self.position = ccp((s.width-480.0)/2.0, (s.height-320.0)/2.0);
	self.visible = YES;
}

// -----------------------------------------------------------------------------

- (void)closePanel {
	self.position = ccp(0, -1000);
	self.visible = NO;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Actions

- (void)nextPressed:(id)sender {
	if (panelState_ == kPanelStateInactive) {
		return;
	}

	// Enable preview
	[Level enablePreview:YES];

	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
	int chapter = [[LevelManager sharedManager] currentChapter];
	int level = [[LevelManager sharedManager] currentLevel];
	
	[[LevelManager sharedManager] setLevel:level+1 inChapter:chapter];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1 scene:[Level scene]]];	
}

// -----------------------------------------------------------------------------

- (void)restartPressed:(id)sender {
	if (panelState_ == kPanelStateInactive) {
		return;
	}
	
	// Disable preview
	[Level enablePreview:NO];

	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1 scene:[Level scene]]];
}

// -----------------------------------------------------------------------------

- (void)menuPressed:(id)sender {
	if (panelState_ == kPanelStateInactive) {
		return;
	}
	
	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
	//[[RBSoundEngine sharedEngine] playMusic:@"music-menu.wav" loop:YES];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1 scene:[LevelChooseScene scene]]];
}

// -----------------------------------------------------------------------------

- (void)playPressed:(id)sender {
	if (panelState_ == kPanelStateInactive) {
		return;
	}
	
	if ((panelState_ == kPanelStateWin) || (panelState_ == kPanelStateWinBonus)) {		
		[self nextPressed:sender];
		return;
	}
	
	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
	[game_ performSelector:@selector(menuPressed)];
}

// -----------------------------------------------------------------------------

- (void)buttonAudio:(CCMenuItemImage *)item {
	if (panelState_ == kPanelStateInactive) {
		return;
	}

	if ([[GameConfiguration sharedConfiguration] playAudio]) {
		[[GameConfiguration sharedConfiguration] setPlayAudio:NO];
		[item unselected];
		
		[[RBSoundEngine sharedEngine] stopMusic];
	}
	else {
		[[GameConfiguration sharedConfiguration] setPlayAudio:YES];
		[item selected];
		
		int level = [[LevelManager sharedManager] currentLevel];
		if (level == 15) {
			[[RBSoundEngine sharedEngine] playMusic:@"1-bonuslevel.wav" loop:YES];
		}
		else {
			[[RBSoundEngine sharedEngine] playMusic:@"1-level.mp3" loop:YES];
		}	
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialization

- (id)initWithGameNode:(GameNode *)aGame {
	if ((self = [super init])) {
#ifndef MAC_VERSION
		self.isTouchEnabled = YES;
#endif
		game_ = aGame;
		//CGSize s = [[CCDirector sharedDirector] winSize];
		
		// Background is same for both
		CCSprite *background = [CCSprite spriteWithFile:@"panel.png"];
		background.anchorPoint = ccp(0,0);
		[self addChild:background z:0];
		
		// Title Label
		titleLabel_ = [CCLabelTTF labelWithString:@"- PAUSED -" fontName:@"Marker Felt" fontSize:24];
		titleLabel_.color = ccBLACK;
		[self addChild:titleLabel_ z:1];
		[titleLabel_ setPosition:ccp(240.0, 240.0)];
		
		// Level Label
		levelLabel_ = [CCLabelTTF labelWithString:@"0-0" fontName:@"Marker Felt" fontSize:20];
		levelLabel_.color = ccBLACK;
		[self addChild:levelLabel_ z:1];
		[levelLabel_ setPosition:ccp(240.0, 210.0)];
		
		// Score label
		scoreLabel_ = [CCLabelTTF labelWithString:@"SCORE: 00000" fontName:@"Marker Felt" fontSize:20];
		scoreLabel_.color = ccBLACK;
		[self addChild:scoreLabel_ z:1];
		[scoreLabel_ setPosition:ccp(240.0, 95.0)];
		
		// Restart button
		CCMenuItem *item = [CCMenuItemImage itemWithNormalImage:@"btn-restart-normal.png" selectedImage:@"btn-restart-selected.png" target:self selector:@selector(restartPressed:)];
		item.tag = 2110;
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[menu setPosition:ccp(140.0, 160.0)];
		[self addChild:menu z:1];
		
		// Play button
		item = [CCMenuItemImage itemWithNormalImage:@"btn-play-normal.png" selectedImage:@"btn-play-selected.png" target:self selector:@selector(playPressed:)];
		playMenu_ = [CCMenu menuWithItems:item, nil];
		[playMenu_ setPosition:ccp(240.0, 160.0)];
		[self addChild:playMenu_ z:1];
		
		// Next button
		item = [CCMenuItemImage itemWithNormalImage:@"btn-next-normal.png" selectedImage:@"btn-next-selected.png" target:self selector:@selector(nextPressed:)];
		nextMenu_ = [CCMenu menuWithItems:item, nil];
		[nextMenu_ setPosition:ccp(240.0, 160.0)];
		[self addChild:nextMenu_ z:1];
		
		// Menu button
		item = [CCMenuItemImage itemWithNormalImage:@"btn-menu-normal.png" selectedImage:@"btn-menu-selected.png" target:self selector:@selector(menuPressed:)];
		menu = [CCMenu menuWithItems:item, nil];
		[menu setPosition:ccp(340.0, 160.0)];
		[self addChild:menu z:1];
		
		// Audio Button
		item = [CCMenuItemImage itemWithNormalImage:@"btn-audio-off.png" selectedImage:@"btn-audio-on.png" target:self selector:@selector(buttonAudio:)];
		menu = [CCMenu menuWithItems:item, nil];
		item.anchorPoint = ccp(0, 0);
		[self addChild:menu z:1];
		[menu setPosition:ccp(350.0, 70.0)];
		
		// Set image
		if ([[GameConfiguration sharedConfiguration] playAudio]) {
			[item selected];
		}
		else {
			[item unselected];
		}
		
		panelState_ = kPanelStateInactive;
		
		[self closePanel];
	}
	
	return self;
}

// -----------------------------------------------------------------------------

+ (id)panelWithGameNode:(GameNode *)aGame {
	return [[[self alloc] initWithGameNode:aGame] autorelease];
}

// -----------------------------------------------------------------------------

- (void) dealloc {
	[super dealloc];
}

// -----------------------------------------------------------------------------

@end
