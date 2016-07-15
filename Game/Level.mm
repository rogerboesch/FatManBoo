//
//  Level.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "GameDelegate.h"
#import "Level.h"
#import "Box2dDebugDrawNode.h"
#import "Hero.h"
#import "Ropebridge.h"
#import "HUD.h"
#import "Panel.h"
#import "BodyNode.h"
#import "GameConfiguration+Extension.h"
#import "Gamehero.h"
#import "LevelManager.h"
#import "Cloud.h"
#import "Balloons.h"
#import "Panel.h"
#import "RBSoundEngine.h"

#ifndef MAC_VERSION
#import "AppDelegate.h"
#endif

static BOOL levelPreviewActive = NO;

@interface Level (Private)
- (void)looseGame;
@end

@implementation Level

@synthesize parallax = parallax_;
@synthesize levelState = levelState_;
@synthesize panel = panel_;

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Point system

- (void)animationComplete:(CCSprite *)sender {
	[sender removeFromParentAndCleanup:YES];
}

// -----------------------------------------------------------------------------

- (void)createMarkerWithSprite:(NSString *)aFrameName position:(CGPoint)aPosition {
	CCSprite *marker = [CCSprite spriteWithSpriteFrameName:aFrameName];
	[spritesBatchNode_ addChild:marker];
	marker.position = aPosition;
	marker.anchorPoint = ccp(0.25, 0.5);
	id scal = [CCScaleTo actionWithDuration:1.0 scale:0.0];
	id fnc = [CCCallFuncND actionWithTarget:self selector:@selector(animationComplete:) data:marker];
	id seq = [CCSequence actions:scal, fnc, nil];
	
	[marker runAction:seq];
}

// -----------------------------------------------------------------------------

- (void)increaseScoreWithNode:(int)score node:(BodyNode *)aNode {
	[super increaseScore:score*2];
	
	if (score == 100) {
		[self createMarkerWithSprite:@"score-100.png" position:aNode.position];
	}
	else if (score == 500) {
		if (level_ == 15) {
			[self createMarkerWithSprite:@"score-100.png" position:aNode.position];
		}
		else {
			[self createMarkerWithSprite:@"score-500.png" position:aNode.position];
		}
	}
	else if (score == 1000) {
		[self createMarkerWithSprite:@"score-1000.png" position:aNode.position];
	}
}


// -----------------------------------------------------------------------------

- (void)increaseLife:(int)lives {
	if (gameState_ != kGameStatePlaying) {
		return;
	}
	
	lives_ += lives;
	[hud_ onUpdateLives:lives_];
	
	if (lives < 0 && lives_ == 0) {
		gameState_ = kGameStateGameOver;
		[hero_ onGameOver:NO];
		[self looseGame];
	}
}

// -----------------------------------------------------------------------------

- (void)increaseScore:(int)score {
	if (gameState_ != kGameStatePlaying) {
		return;
	}
	
	[super increaseScore:score];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Hero actions

- (void)followHero:(ccTime)dt {
	[self stopAllActions];
	CGRect rect = [self contentRect];
	id action = [CCFollow actionWithTarget:hero_ worldBoundary:rect];
	[self runAction:action];

	[previewButton_ stopAllActions];
	[previewButton_ removeFromParentAndCleanup:YES];
	previewButton_ = nil;
	[previewInfo_ removeFromParentAndCleanup:YES];
	previewInfo_ = nil;
	
	[hud_ showHUD];
	levelState_ = kLevelStatePlay;
}

// -----------------------------------------------------------------------------

- (void)nextHero {
	Gamehero *myHero = (Gamehero *)[spritesBatchNode_ getChildByTag:2110];
	if (myHero != nil) {
		CCLOG(@"Next hero: %@", myHero);
		
		[self stopAllActions];
		myHero.joystick = hero_.joystick;
		hero_.joystick = nil;
		hero_ = myHero;		
		[self followHero:0];
		[myHero moveTo:startPosition_];
	
		[hud_ showJoystick];
	}
}

// -----------------------------------------------------------------------------

- (void)countHeros:(ccTime)dt {
	[self stopAllActions];
	
	for (BodyNode *node in [spritesBatchNode_ children]) {
		if (node.tag == 2110) {
			[self increaseScoreWithNode:1000 node:node];
			[[RBSoundEngine sharedEngine] playEffect:@"pickup.wav"];
			node.tag = 0;
			
			id delayAction = [CCDelayTime actionWithDuration:0.75];
			id actionComplete = [CCCallFuncND actionWithTarget:self selector:@selector(countHeros:) data:nil];
			id sequence = [CCSequence actions:delayAction, actionComplete, nil];
			[self runAction:sequence];
			
			return;
		}
	}
	
	// Call end
	id delayAction = [CCDelayTime actionWithDuration:1.0];
	id actionComplete = [CCCallFuncND actionWithTarget:self selector:@selector(winGame:) data:nil];
	id sequence = [CCSequence actions:delayAction, actionComplete, nil];
	[self runAction:sequence];
}

// -----------------------------------------------------------------------------

- (void)startFlying {
	[(Gamehero *)hero_ setFlying:YES];
	[hud_ hideJoystick];
}

// -----------------------------------------------------------------------------

- (void)stopFlying {
	if ([(Gamehero *)hero_ isFlying]) {
		[(Gamehero *)hero_ setFlying:NO];
		[(Gamehero *)hero_ toggleRoll];
		[hud_ showJoystick];
	}
}

// -----------------------------------------------------------------------------

- (void)takeCoin {
	if (gameState_ != kGameStatePlaying) {
		return;
	}
	
	numberOfCoinsTaken_++;
	CCLOG(@"Number of coins: %d", numberOfCoinsTaken_);
}

// -----------------------------------------------------------------------------

- (void)unlockNext {
	if ([[LevelManager sharedManager] isLastLevelInChapter]) {
		if ([[LevelManager sharedManager] isLastChapter]) {
			// Wow all level solved
			CCLOG(@"All levels in all chapters solved (A scene with more games and or levels must be shown");
		}
		else {
			// Test all levels of this chapter
			BOOL allSolved = YES;
			for (int i = 1; i < NUMBER_OF_LEVELS_IN_CHAPTER; i++) {
				int bonus = [[LevelManager sharedManager] bonusOfLevel:i chapter:chapter_];
				if (bonus < BONUS_MAXIMUM) {
					allSolved = NO;
				}
			}

			if (allSolved) {
				[[LevelManager sharedManager] unlockNextChapter];
			}
		}
	}
	else {
		// Unblock anyway, it's handles in level manager
		[[LevelManager sharedManager] unlockNextLevel];
	}
	
	[[LevelManager sharedManager] dump];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Goal

- (void)winGame:(ccTime)dt {	
	// Save points to level manager
	[[LevelManager sharedManager] setCurrentScore:score_];
	
	// Test and set bonus
	int bonus = 0;
	if (lives_ == kInitialLives) {
		bonus++;
	}
	else if (level_ == 15) {
		if (lives_ == 1) {
			bonus++;
		}
	}
	
	if (numberOfCoins_ == numberOfCoinsTaken_) {
		bonus++;
	}
	[[LevelManager sharedManager] setBonusLevel:bonus];

	// Unlock next game
	[self unlockNext];
	
	[hud_ hideHUD];
	
	gameState_ = kGameStateGameOver;
	if (bonus < BONUS_MAXIMUM) {
		[panel_ activatePanelState:kPanelStateWin oldScore:score_ newScore:score_];
	}
	else {
		[panel_ activatePanelState:kPanelStateWinBonus oldScore:score_ newScore:score_];
	}

#ifndef MAC_VERSION
	// Save also score to game center
	GameDelegate *appDelegate = (GameDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate reportScore:score_ forCategory:LEADERBOARD_DEFAULT];
#endif
}

// -----------------------------------------------------------------------------

- (void)looseGame {
	gameState_ = kGameStateGameOver;
	[hud_ hideHUD];
	[panel_ activatePanelState:kPanelStateLoose oldScore:score_ newScore:score_];
}

// -----------------------------------------------------------------------------

- (void)goalMissed {
	if (gameState_ != kGameStatePlaying) {
		return;
	}
	
	CCLOG(@"Goal missed");
	[self createMarkerWithSprite:@"uups.png" position:hero_.position];
}

// -----------------------------------------------------------------------------

- (void)goalReached {
	CCLOG(@"Goal reached");
	[self stopAllActions];

	gameState_ = kGameStateGameOver;

	[self createMarkerWithSprite:@"yeah.png" position:hero_.position];

	if (level_ == 15) {
		[self winGame:0];
		return;
	}
	
	for (BodyNode *node in [spritesBatchNode_ children]) {
		if (node.tag == 2110) {
			id delayAction = [CCDelayTime actionWithDuration:0.75];
			id moveActionBack = [CCMoveTo actionWithDuration:3 position:CGPointZero];
			id easeBack = [CCEaseInOut actionWithAction:moveActionBack rate:2];
			id actionComplete = [CCCallFuncND actionWithTarget:self selector:@selector(countHeros:) data:nil];
			id sequence = [CCSequence actions:delayAction, easeBack, actionComplete, nil];
			[self runAction:sequence];

			return;
		}
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Preview behavior

- (void)showPreview {
	if (!levelPreviewActive) {
		levelState_ = kLevelStatePlay;
		hud_.visible = YES;
		return;
	}
	
	[self stopAllActions];
	levelState_ = kLevelStatePreview;
	
	CGSize s = [[CCDirector sharedDirector] winSize];

	previewInfo_ = [CCSprite spriteWithSpriteFrameName:@"watchlevel.png"];
	[parallax_ addChild:previewInfo_ z:30 parallaxRatio:ccp(0.0f, 0.0f) positionOffset:ccp(s.width/2.0, s.height-35.0f)];
	previewButton_ = [CCSprite spriteWithSpriteFrameName:@"pause-small.png"];
	[parallax_ addChild:previewButton_ z:30 parallaxRatio:ccp(0.0f, 0.0f) positionOffset:ccp(s.width/2.0+79, s.height-35.0f)];

	id action = [CCBlink actionWithDuration:10.0 blinks:10];
	[previewButton_ runAction:action];
	
	CGPoint endPoint = CGPointMake(-720, 0);
	CGPoint startPoint = CGPointMake(720, -35);

	// Mac version
#ifdef MAC_VERSION
	startPoint = CGPointMake(720, 0);
#endif

	// iPad version
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		startPoint = CGPointMake(720, 0);
	}
	
	if (chapter_ == 2) {
		startPoint = CGPointMake(720, 0);
	}
	
	id delayAction = [CCDelayTime actionWithDuration:0.75];
	id moveActionRight = [CCMoveBy actionWithDuration:4.0 position:endPoint];
	id moveActionBack = [CCMoveBy actionWithDuration:4.0 position:startPoint];
	id easeRight = [CCEaseInOut actionWithAction:moveActionRight rate:2];
	id easeBack = [CCEaseInOut actionWithAction:moveActionBack rate:2];
	id actionComplete = [CCCallFuncND actionWithTarget:self selector:@selector(followHero:) data:nil];
	id sequence = [CCSequence actions:delayAction, easeRight, delayAction, easeBack, actionComplete, nil];
	[self runAction:sequence];

	[hud_ hideHUD];
}

// -----------------------------------------------------------------------------

- (void)cancelPreview {
	if (levelState_ != kLevelStatePreview) {
		return;
	}

	[self stopAllActions];
	[self followHero:0];
}

// -----------------------------------------------------------------------------

+ (void)enablePreview:(BOOL)aFlag {
	levelPreviewActive = aFlag;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Menu button pressed

- (void)menuPressed {
	if (levelState_ == kLevelStatePlay) {
		[hud_ hideHUD];
		[panel_ activatePanelState:kPanelStatePause oldScore:score_ newScore:score_];

		levelState_ = kLevelStatePause;
		gameState_ = kGameStatePaused;
	}
	else {
		[panel_ closePanel];
		[hud_ showHUD];

		levelState_ = kLevelStatePlay;
		gameState_ = kGameStatePlaying;
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Tile map utilities

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / tileMap_.tileSize.width;
    int y = ((tileMap_.mapSize.height * tileMap_.tileSize.height) - position.y) / tileMap_.tileSize.height;
	
    return ccp(x, y);
}

// -----------------------------------------------------------------------------

- (unsigned int)tileGIDForPosition:(CGPoint)position {
	CGPoint pos = [self tileCoordForPosition:position];
	
	CCTMXLayer *layer = [tileMap_ layerNamed:@"Cave"];
	return [layer tileGIDAt:pos];
}

// -----------------------------------------------------------------------------

- (unsigned int)tileGIDForCoordinate:(CGPoint)coordinate {
	CCTMXLayer *layer = [tileMap_ layerNamed:@"Cave"];
	return [layer tileGIDAt:coordinate];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Hero assignment

- (void)setHero:(Hero *)aHero {
	if (hero_ == nil) {
		CCLOG(@"Hero assigned: %@", aHero);
		hero_ = aHero;
		startPosition_ = hero_.position;
	}
	else {
		CCLOG(@"Hero not assigned: %@", aHero);
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Game objects

- (void)createBackground1 {
	CCSprite *background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"chapter%d-background.png", chapter_]];
	background.anchorPoint = ccp(0,0);
	
	// Mac version
#ifdef MAC_VERSION
	background.scale = 2.0;
#endif
	
	// iPad version
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		background.scale = 2.0;
	}
	
	if (level_ == 15) {
		[parallax_ addChild:background z:-10 parallaxRatio:ccp(0.0f, 0.0f) positionOffset:ccp(0, 0)];
	}
	else {
		[parallax_ addChild:background z:-10 parallaxRatio:ccp(0.0f, 0.0f) positionOffset:ccp(0, 0)];
	}
}

// -----------------------------------------------------------------------------

- (void)createBackground2 {
    if (chapter_ == 2) {
        return;
    }
    
    NSString *name = [NSString stringWithFormat:@"chapter%d-mountains.png", chapter_];
	CCSprite *background = [CCSprite spriteWithFile:name];
	background.anchorPoint = ccp(0,0);
	
	// Mac version
#ifdef MAC_VERSION
	background.scale = 2.0;
#endif
	
	// iPad version
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		background.scale = 2.0;
	}

	if (RANDOM(0, 1)) {
		RBDebug(@"Flip mountains");
		background.flipX = YES;
	}

	if (level_ == 15) {
		[parallax_ addChild:background z:-10 parallaxRatio:ccp(0.03f, 0.3f) positionOffset:ccp(0, 0)];
	}
	else {
		[parallax_ addChild:background z:-10 parallaxRatio:ccp(0.3f, 0.3f) positionOffset:ccp(0, 0)];
	}
}

// -----------------------------------------------------------------------------

- (void)createBackground3 {
	CCSprite *background2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"chapter%d-background2.png", chapter_]];
	background2.anchorPoint = ccp(0,0);
	
	// Mac version
#ifdef MAC_VERSION
	background2.scale = 1.5;
#endif
	
	// iPad version
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		background2.scale = 1.5;
	}

	if (RANDOM(0, 1)) {
		RBDebug(@"Flip background 2");
		background2.flipX = YES;
	}
	
	if (level_ == 15) {
		[parallax_ addChild:background2 z:-10 parallaxRatio:ccp(0.04f, 0.3f) positionOffset:ccp(0, 0)];
	}
	else {
		[parallax_ addChild:background2 z:-10 parallaxRatio:ccp(0.4f, 0.3f) positionOffset:ccp(0, 0)];
	}
}

// -----------------------------------------------------------------------------

- (void)createBackground {
	[self createBackground1];
	[self createBackground2];
	[self createBackground3];
}

// -----------------------------------------------------------------------------

- (void)createClouds {
	int level = [[LevelManager sharedManager] currentLevelNumber];
	if (level < 5) {
		return;
	}
	
	int baseOffset = 290.0;
	if (chapter_ == 2) {
		baseOffset = 0;
	}
	
	for (int x = 0; x < contentSize_.width; x += 300) {		
		CCSprite* cloud = [CCSprite spriteWithSpriteFrameName:@"cloud.png"];

		RBDebug1(@">>> %f", CCRANDOM_MINUS1_1());
		
		if (RANDOM(0, 1)) {
			RBDebug(@"Flip cloud");
			cloud.flipX = YES;
		}
		
		float xOffset = CCRANDOM_0_1() * 40;
		float yOffset = CCRANDOM_0_1() * 90;
		[parallax_ addChild:cloud z:8 parallaxRatio:ccp(0.6, 0.8) positionOffset:ccp(x+xOffset, baseOffset+yOffset)];
	}	
}

// -----------------------------------------------------------------------------

- (void)createFloatingIslands {
	int level = [[LevelManager sharedManager] currentLevel];
	if (level < 10) {
		return;
	}
	
	for (int x = 0; x < contentSize_.width; x += 300) {
		if (RANDOM(0, 1) && x > 0) {
			int islandno = RANDOM(1, 2);
			CCSprite* island = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"island-%d.png", islandno]];

			if (RANDOM(0, 1)) {
				RBDebug(@"Flip island");
				island.flipX = YES;
			}
			
			float xOffset = CCRANDOM_0_1() * 40;
			float yOffset = CCRANDOM_0_1() * 90;
			[parallax_ addChild:island z:6 parallaxRatio:ccp(0.5, 0.8) positionOffset:ccp(x+xOffset, 320+yOffset)];
		}
	}	
}

// -----------------------------------------------------------------------------

- (void)createPlants {
	if (chapter_ > 1) {
		return;
	}

	// Fill width of screen with ground images 
	int numberOfGround = self.contentSize.width / 480 + 5;
	for (int i = 0; i <= numberOfGround; i++) {
		CCSprite *grass = [CCSprite spriteWithFile:@"grass.png"];
		
		if (RANDOM(0, 1)) {
			RBDebug(@"Flip grass");
			grass.flipX = YES;
		}

		[parallax_ addChild:grass z:6 parallaxRatio:ccp(0.8, 0.8) positionOffset:ccp(i*479.0, 65)];
	}
}

// -----------------------------------------------------------------------------

- (void)createFloor {
	if (chapter_ > 1) {
		return;
	}
	
	// Fill width of screen with ground images 
	int numberOfGround = self.contentSize.width / 480 + 5;
	for (int i = 0; i <= numberOfGround; i++) {
		CCSprite *ground = [CCSprite spriteWithFile:[NSString stringWithFormat:@"chapter%d-ground.png", chapter_]];
		ground.anchorPoint = ccp(0,0);
		[parallax_ addChild:ground z:20 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:ccp(i*479.0, -83)];
	}
}

// -----------------------------------------------------------------------------

- (void)createBalloon:(CGPoint)aPosition speedY:(float)speedY heart:(BOOL)aHeart {
	Ballon *balloon = [[Ballon alloc] initWithPosition:aPosition game:self speedY:speedY heart:aHeart];
	[self addBodyNode:balloon z:100];
}

// -----------------------------------------------------------------------------

- (void)createBalloons {
	for (int x = 0; x < contentSize_.width; x += 300) {		
		float xOffset = CCRANDOM_0_1() * 40;
		float yOffset = CCRANDOM_0_1() * 40;
		float speed = CCRANDOM_0_1() + 0.5;

		[self createBalloon:ccp(x+xOffset, yOffset) speedY:speed heart:NO];
	}	
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Particle system and explosions

- (id)createParticleSystem:(NSString *)aName {
	CCParticleSystem *system = nil;
	if ([aName isEqualToString:@"fire"]) {
		system = [[CCParticleFire alloc] init];
	}
	else if ([aName isEqualToString:@"smoke"]) {
		system = [[CCParticleSmoke alloc] init];
	}
	else if ([aName isEqualToString:@"explosion"]) {
		system = [[CCParticleExplosion alloc] init];
	}
	else if ([aName isEqualToString:@"meteor"]) {
		system = [[CCParticleMeteor alloc] init];
	}
	else if ([aName isEqualToString:@"portal"]) {
		system = [[CCParticleGalaxy alloc] init];
	}
	
	if (system != nil) {
		[self addChild:system z:100 tag:1];
		CCLOG(@"Particle system created: %@", aName);
	}
	else {
		CCLOG(@"Unknown particle system: %@", aName);
	}
	
	return system;
}

// -----------------------------------------------------------------------------

- (void)explosionComplete:(CCSprite *)aSprite {
	[aSprite stopAllActions];
	[aSprite removeFromParentAndCleanup:YES];
}

// -----------------------------------------------------------------------------

- (void)createExplosion:(BodyNode *)aNode {
	CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"explosion-1.png"];
	sprite.position = aNode.position;
	[spritesBatchNode_ addChild:sprite z:15];
	
	NSMutableArray *animationFrames = [NSMutableArray new];
	for (int i = 1; i <= 4; i++) {
		[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"explosion-%d.png", i]]];
	}
	
	id animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
	id animAction = [CCAnimate actionWithAnimation:animation];
	id actionComplete = [CCCallFuncND actionWithTarget:self selector:@selector(explosionComplete:) data:sprite];
	id seq = [CCSequence actions:animAction, actionComplete, nil];
	[sprite runAction:seq];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Bonus info

- (void)bonusInfoComplete:(CCSprite *)aSprite {
	[aSprite stopAllActions];
	[aSprite removeFromParentAndCleanup:YES];
}

// -----------------------------------------------------------------------------

- (void)showBonusInfo {
	CGSize s = [[CCDirector sharedDirector] winSize];

	CCSprite *info = [CCSprite spriteWithSpriteFrameName:@"bonuslevel.png"];
	info.position = ccp(s.width/2.0, 80);
	[hud_ addChild:info z:20];

	id fad = [CCFadeOut actionWithDuration:8.0];
	id fnc = [CCCallFuncND actionWithTarget:self selector:@selector(bonusInfoComplete:) data:info];
	id seq = [CCSequence actions:fad, fnc, nil];
	
	[info runAction:seq];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Bomb prototype

- (void)launchBomb:(CGPoint)pos explosion:(BOOL)explosion force:(float)force {
	BOOL doSuction = !explosion;	// Very cool looking implosion effect instead of explosion.
	float maxDistance = 2;			// In your head don't forget this number is low because we're multiplying it by 32 pixels;
	int maxForce = force;			// Maximum force
	
	for (b2Body* b = world_->GetBodyList(); b; b = b->GetNext()) {
		b2Vec2 b2TouchPosition = b2Vec2(pos.x/kPhysicsPTMRatio, pos.y/kPhysicsPTMRatio);
		b2Vec2 b2BodyPosition = b2Vec2(b->GetPosition().x, b->GetPosition().y);
		
		float distance;
		float strength;
		float force;
		float angle;
		
		// To go towards the press, all we really change is the atanf function, and swap which goes first to reverse the angle
		if (doSuction) {
			// Get the distance, and cap it
			distance = b2Distance(b2BodyPosition, b2TouchPosition);
			if (distance > maxDistance) {
				distance = maxDistance - 0.01;
			}
			
			// Get the strength
			//strength = distance / maxDistance; // Uncomment and reverse these two. and ones further away will get more force instead of less
			strength = (maxDistance - distance) / maxDistance; // This makes it so that the closer something is - the stronger, instead of further
			force  = strength * maxForce;
			
			// Get the angle
			angle = atan2f(b2TouchPosition.y - b2BodyPosition.y, b2TouchPosition.x - b2BodyPosition.x);

			// Apply an impulse to the body, using the angle
			b->ApplyLinearImpulse(b2Vec2(cosf(angle) * force, sinf(angle) * force), b->GetPosition());
		}
		else {
			distance = b2Distance(b2BodyPosition, b2TouchPosition);
			if (distance > maxDistance) {
				distance = maxDistance - 0.01;
			}
			
			// Normally if distance is max distance, it'll have the most strength, this makes it so the opposite is true - closer = stronger
			// This makes it so that the closer something is - the stronger, instead of further
			strength = (maxDistance - distance) / maxDistance;
			force = strength * maxForce;
			angle = atan2f(b2BodyPosition.y - b2TouchPosition.y, b2BodyPosition.x - b2TouchPosition.x);

			// Apply an impulse to the body, using the angle
			b->ApplyLinearImpulse(b2Vec2(cosf(angle) * force, sinf(angle) * force), b->GetPosition());
		}
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Create scene graph

- (void)onEnter {
	[super onEnter];
	
	// Play background music
    [[RBSoundEngine sharedEngine] playMusic:@"1-level.mp3" loop:YES];
}

// -----------------------------------------------------------------------------

- (void)onEnterTransitionDidFinish {
	[super onEnterTransitionDidFinish];

	CCLOG(@"Total number of coins: %d", numberOfCoins_);
	
	int level = [[LevelManager sharedManager] currentLevel];
	if (level == 15) {
		[hud_ showHUD];
		[hud_ hideJoystick];
		levelState_ = kLevelStatePlay;
		[self showBonusInfo];
		
		[self createBalloons];
	}
	else {
		[self showPreview];
	}	
}

// -----------------------------------------------------------------------------

- (void)initGraphics {	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
	
	parallax_ = [CCParallaxNode node];
	
	level_ = [[LevelManager sharedManager] currentLevel];
	chapter_ = [[LevelManager sharedManager] currentChapter];
	
	// Background
	[self createBackground];
	
	// Tile map
	int number = [[LevelManager sharedManager] currentLevelNumber];
	tileMap_ = [CCTMXTiledMap tiledMapWithTMXFile:[NSString stringWithFormat:@"level-%d.tmx", number]];
	[parallax_ addChild:tileMap_ z:8 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];

	// Sprite map
	spritesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:20];		
	invisibleBatchNode_ = [CCSpriteBatchNode batchNodeWithTexture:nil capacity:10];
	invisibleBatchNode_.visible = NO;	
	[parallax_ addChild:spritesBatchNode_ z:7 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	[parallax_ addChild:invisibleBatchNode_ z:10 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];	

	// Set content size
	[self setContentSize:[tileMap_ contentSize]];
			
	// Add objects
	[self createFloor];
	[self createFloatingIslands];
	[self createClouds];
	[self createPlants];
	
	// Debug physics
	if ([[GameConfiguration sharedConfiguration] showPhysics]) {
		Box2dDebugDrawNode *b2node = [Box2dDebugDrawNode nodeWithWorld:world_];	
		[parallax_ addChild:b2node z:11 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	}
	
	// Add parallax
	[self addChild:parallax_];
	
	CCLOG(@"Level size: %.0f x %.0f px", self.contentSize.width, self.contentSize.height);
	
	// Set initial lives
	lives_ = kInitialLives;
	
	if (level_ == 15) {
		lives_ = 1;
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark SVG support

- (CGRect)contentRect {
	return CGRectMake(0, 0, contentSize_.width, contentSize_.height);
}

// -----------------------------------------------------------------------------

- (NSString*) SVGFileName {
	int number = [[LevelManager sharedManager] currentLevelNumber];
	return [NSString stringWithFormat:@"level-%d.svg", number];
}

// -----------------------------------------------------------------------------

- (void)addBodyNode:(BodyNode*)node z:(int)zOrder {
	CCLOG(@"Add object %@ to z %d", node, zOrder);
	
	NSString* name = NSStringFromClass([node class]);
	if ([name isEqualToString:@"Coin"]) {
		numberOfCoins_++;
	}
	
	if ([node isKindOfClass:[Cloud class]]) {
		zOrder = 100;
	}
		 
	switch (node.preferredParent) {
		case BN_PREFERRED_PARENT_SPRITES_PNG:
			[spritesBatchNode_ addChild:node z:zOrder];
			break;
						
		case BN_PREFERRED_PARENT_IGNORE:
			[invisibleBatchNode_ addChild:node z:zOrder];
			break;
			
		default:
			CCLOG(@"Unknown body class or parent mode: %@", [node class]);
			break;
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

+ (id)scene {
	CCScene *scene = [CCScene node];
	GameNode *game = [self node];
	
	// HUD
	HUD *hud = [HUD HUDWithGameNode:game];
	hud.visible = NO;
	[scene addChild:hud z:10];
	game.hud = hud;
	
	// Panel
	Panel *panel = [Panel panelWithGameNode:game];
	[scene addChild:panel z:11];
	((Level *)game).panel = panel;
	panel.visible = NO;
	[scene addChild: game];
	
	return scene;
}

// -----------------------------------------------------------------------------

- (void)dealloc {
	[super dealloc];
}

// -----------------------------------------------------------------------------

@end