//
//  Level.h
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "GameNode.h"

typedef enum {
	kLevelStatePreview,
	kLevelStatePlay,
	kLevelStatePause,
} LevelState;

@class BodyNode;
@class Panel;

@interface Level : GameNode {
	CCParallaxNode *parallax_;
	CCSpriteBatchNode *spritesBatchNode_;
	CCSpriteBatchNode *invisibleBatchNode_;
	CCTMXTiledMap *tileMap_;

	CCSprite *previewInfo_;
	CCSprite *previewButton_;	
	Panel *panel_;
	
	int numberOfCoins_;
	int numberOfCoinsTaken_;
	
	CGPoint startPosition_;
	
	LevelState levelState_;
	int level_;
	int chapter_;
}

@property (nonatomic, readonly) CCParallaxNode *parallax;
@property (nonatomic, readonly) LevelState levelState;
@property (nonatomic, assign) Panel *panel;

// Tile methods
- (CGPoint)tileCoordForPosition:(CGPoint)position;
- (unsigned int)tileGIDForPosition:(CGPoint)position;
- (unsigned int)tileGIDForCoordinate:(CGPoint)coordinate;

// Menu button
- (void)menuPressed;

// Preview
- (void)showPreview;
- (void)cancelPreview;
+ (void)enablePreview:(BOOL)aFlag;

// Behaviors
- (void)nextHero;
- (void)goalMissed;
- (void)goalReached;
- (void)startFlying;
- (void)stopFlying;
- (void)takeCoin;

// Increase score and show small number at hit position
- (void)increaseScoreWithNode:(int)score node:(BodyNode *)aNode;

// Create particle system
- (id)createParticleSystem:(NSString *)aName;

// Create en explosion
- (void)createExplosion:(BodyNode *)aNode;

// Physics effetcs
- (void)launchBomb:(CGPoint)pos explosion:(BOOL)explosion force:(float)force;

// Object creation
- (void)createBalloon:(CGPoint)aPosition speedY:(float)speedY heart:(BOOL)aHeart;
- (void)createBalloons;
	
@end
