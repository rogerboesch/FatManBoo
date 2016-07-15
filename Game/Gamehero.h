//
//  Gamehero.h
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "Hero.h"

typedef enum {
	kHeroStateUnknown = 0,
	kHeroStateIdle,
	kHeroStateWalkLeft,
	kHeroStateWalkRight,
	kHeroStateDeath,
	kHeroStateDance,
	kHeroStateHammer,
	kHeroStateRollIn,
	kHeroStateRollOut,
} HeroState;

@class Babyboo;

@interface Gamehero : Hero {
	BOOL facingRight_;
	BOOL initialWalkDone_;
	BOOL died_;
	
	struct timeval lastJump_;
	struct timeval lastFire_;
	struct timeval lastRoll_;
	struct timeval lastHammer_;
	struct timeval lastSpeedup_;
	
	BOOL antiGravityForce_;
	BOOL touchingGround_;
	
	int numberOfHammers_;
	
	HeroState state_;
	CCAction *currentAction_;
	CCAction *newAction_;
	CCAction *walkLeftAction_;
	CCAction *walkRightAction_;
	CCAction *idleAction_;
	CCAction *deathAction_;
	CCAction *danceAction_;
	CCAction *rollInAction_;
	CCAction *rollOutAction_;
	CCAction *hammerAction_;
	
	CCParticleSystem *particleSystem_;
	
	Babyboo *baby_;
	CCSprite *rope_;
	float speed_;
	float jumpFactor_;
	BOOL flying_;

	int power_;
	int numberOfBullets_;
}

// Check if is currently flying
- (BOOL)isFlying;
- (void)setFlying:(BOOL)aFlag;

// Shoot behavior
- (float)speed;
- (float)angle;

// Assign baby
- (void)assignBaby:(Babyboo *)aBaby;
- (BOOL)hasBaby;

// Bullet handling
- (int)numberOfBullets;
- (void)increaseNumberOfBullets:(int)aNumber;

// Hammer handling
- (int)numberOfHammers;
- (void)increaseNumberOfHammers:(int)aNumber;

// Set hero's animation
- (void)setAnimationState:(HeroState)aState;
- (void)setIdle;

// Move to direction;
- (void)move:(CGPoint)direction;

// Move to position
- (void)moveTo:(CGPoint)aPosition;

// Jump
- (void)jump;
- (void)jumpWithFactor:(float)aFactor;

// Push
- (void)push;

// Speed up
- (void)applySpeedUp:(CGPoint)aSpeed;

// Other actions
- (void)toggleRoll;
- (void)hammer;

// Checks state
- (BOOL)isRolling;
- (BOOL)isLeftFaced;

// Die
- (void)die;

// Particle system support
- (id)startParticleSystem:(NSString *)aName;
- (void)stopParticleSystem;

@end
