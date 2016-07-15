//
//  Gamehero.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import <Box2D/Box2D.h>

#import "Gamehero.h"
#import "Bullet.h"
#import "Babyboo.h"
#import "Level.h"
#import "Joystick.h"
#import "HUD.h"
#import "RBSoundEngine.h"

#define	kJumpImpulseBox (5.0f)
#define	kJumpImpulseCircle (14.0f)
#define kMoveForceBox (5.0f)
#define kMoveForceCircle (0.5f)

#define kFireFrequency (0.2f)
#define kRollFrequency (0.5f)
#define kHammerFrequency (0.5f)
#define kSpeedUpFrequency (0.5f)
#define kJumpFrequency (0.5)

#define kNumberOfFrames 10

#define kSpriteWidth 30
#define kSpriteHeight 70

#define kNumberOfInitialBullets 6
#define kNumberOfInitialHammers 15

#define kAnchorpointBoxRight ccp(0.3, 0.3)
#define kAnchorpointBoxLeft ccp(0.45, 0.3)
#define kAnchorpointCircle ccp(0.45, 0.15)

#define kGround 1.8
#define kMiniumJumpFactor 0.05

@interface Gamehero (Private)
- (void)createBoxBody;
- (void)createCircleBody;
- (void)die;
@end

@implementation Gamehero

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Check flying state

- (BOOL)isFlying {
	return flying_;
}

// -----------------------------------------------------------------------------

- (void)setFlying:(BOOL)aFlag {
	flying_ = aFlag;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Hero switching

- (void)nextHero:(ccTime)dt {
	[game_ removeB2Body:body_];

	[self stopAllActions];
	[(Level *)game_ nextHero];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Shoot behavior

- (float)speed {
	return speed_;
}

// -----------------------------------------------------------------------------

- (float)angleFor360:(float)aAngle {
	int test = (int)aAngle / 360;
	aAngle = aAngle - test * 360.0;
	
	return aAngle;
}
// -----------------------------------------------------------------------------

- (float)angle {
	return [self angleFor360:rope_.rotation];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Rope handling

- (void)rotateRope:(ccTime)dt {
	float rot = rope_.rotation;
	rot += 180*speed_*dt;
	rope_.rotation = rot;
	
	speed_ += 0.0025;
	if (speed_ >= 5.0) {
		speed_ = 5.0;
	}
	
	return;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Assigned baby will follow hero

- (void)assignBaby:(Babyboo *)aBaby {
	CCLOG(@"Hero %@ assigned to baby %@", self, aBaby);

	baby_ = aBaby;
	baby_.follows = YES;
}

// -----------------------------------------------------------------------------

- (BOOL)hasBaby {
	if (baby_) {
		return YES;
	}
	
	return NO;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark End of animation, ready to reset frame

- (void)animationComplete:(ccTime)dt {
	if (newAction_ != nil) {
		CCLOG(@"Animation complete,run action: %@", newAction_);
		
		[self stopAction:currentAction_];
		[self runAction:newAction_];
		currentAction_ = newAction_;
		newAction_ = nil;
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Hammer

- (void)destroyHammerNodes {
}

// -----------------------------------------------------------------------------

- (BOOL)canHammer {
	return NO;
}

// -----------------------------------------------------------------------------

- (void)hammerAnimationComplete:(ccTime)dt {
	// Test if there is a collide node which we can hammer away
	[self destroyHammerNodes];
	[self setAnimationState:kHeroStateIdle];
	
	numberOfHammers_--;
}

// -----------------------------------------------------------------------------

- (void)hammer {
	if (![self canHammer]) {
		CCLOG(@"Cant hammer here");
		return;
	}
	
	struct timeval now;
	gettimeofday(&now, NULL);	
	ccTime dt = (now.tv_sec - lastHammer_.tv_sec) + (now.tv_usec - lastHammer_.tv_usec) / 1000000.0f;
	if (dt > kHammerFrequency) {			
		lastHammer_ = now;
		[self setAnimationState:kHeroStateHammer];
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Rolling

- (void)rollInAnimationComplete:(ccTime)dt {
	jumpImpulse_ = kJumpImpulseCircle;
	moveForce_ = kMoveForceCircle;
	float impulse = jumpImpulse_ * jumpFactor_;
	if (self.flipX) {
		b2Vec2 p1 = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
		body_->ApplyLinearImpulse(b2Vec2(-1*(impulse/2.0), impulse), p1);
	}
	else {
		b2Vec2 p1 = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
		body_->ApplyLinearImpulse(b2Vec2(impulse/2.0, impulse), p1);
	}

	[[RBSoundEngine sharedEngine] playEffect:@"jump.wav"];
	[(Level *)game_ startFlying];
}

// -----------------------------------------------------------------------------

- (void)rollOutAnimationComplete:(ccTime)dt {
	body_->SetTransform(body_->GetPosition(), 0);
	body_->SetFixedRotation(true);
	body_->ResetMassData();
	
	jumpImpulse_ = kJumpImpulseBox;
	moveForce_ = kMoveForceBox;
	
	state_ = kHeroStateUnknown;
	currentAction_ = nil;
	
	if (!flying_) {
		return;
	}
	
	if (baby_ == nil) {
		[self die];
	}
	else {
		[self setAnimationState:kHeroStateDance];
		[[RBSoundEngine sharedEngine] playEffect:@"pickup.wav"];
		[(Level *)game_ increaseScoreWithNode:1000 node:self];
		
		[(Level *)game_ goalReached];
	}
}

// -----------------------------------------------------------------------------

- (void)toggleRoll {
	if (state_ != kHeroStateRollIn && state_ != kHeroStateRollOut) {
		[self createCircleBody];
		[self stopAction:currentAction_];
		[self runAction:rollInAction_];
		currentAction_ = rollInAction_;
		state_ = kHeroStateRollIn;
		[baby_ setVisible:NO];
	}
	else {
		if (state_ == kHeroStateRollIn) {
			[self createBoxBody];
			[self stopAction:currentAction_];
			[self runAction:rollOutAction_];
			currentAction_ = rollOutAction_;
			state_ = kHeroStateRollOut;
		}
		else {
			[self createCircleBody];
			[self stopAction:currentAction_];
			[self runAction:rollInAction_];
			currentAction_ = rollInAction_;
			state_ = kHeroStateRollIn;
			[baby_ setVisible:NO];
		}
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Animation states

- (void)initActions {
	currentAction_ = nil;
	newAction_ = nil;
	NSMutableArray *animationFrames = [NSMutableArray array];
	
	// Idle
	[animationFrames removeAllObjects];
	[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"walk2-%02d.png", 4]]];
	[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"walk1-%02d.png", 4]]];
	[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"walk2-%02d.png", 4]]];
	for (int i = 1; i <= 20; i++) {
		[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"walk1-%02d.png", 4]]];
	}
	
	CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
	idleAction_ = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
	[idleAction_ retain];
	
	// Right walk
	[animationFrames removeAllObjects];
	for (int i = 1; i <= 10; i++) {
		[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"walk1-%02d.png", i]]];
	}	
	animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
	id actionComplete = [CCCallFuncND actionWithTarget:self selector:@selector(animationComplete:) data:nil];
	walkRightAction_ = [CCRepeatForever actionWithAction:[CCSequence actions:[CCAnimate actionWithAnimation:animation], actionComplete, nil]];
	[walkRightAction_ retain];
	
	// Left walk
	[animationFrames removeAllObjects];
	for (int i = 10; i >= 1; i--) {
		[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"walk1-%02d.png", i]]];
	}
	animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
	walkLeftAction_ = [CCRepeatForever actionWithAction:[CCSequence actions:[CCAnimate actionWithAnimation:animation], actionComplete, nil]];
	[walkLeftAction_ retain];
	
	// Death
	[animationFrames removeAllObjects];
	for (int i = 1; i <= 15; i++) {
		[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"death-%02d.png", i]]];
	}	
	animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
	deathAction_ = [CCAnimate actionWithAnimation:animation];
	[deathAction_ retain];
	
	// Hammer
	[animationFrames removeAllObjects];
	for (int i = 1; i <= 9; i++) {
		[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"hammer-%02d.png", i]]];
	}	
	animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
	actionComplete = [CCCallFuncND actionWithTarget:self selector:@selector(hammerAnimationComplete:) data:nil];
	hammerAction_ = [CCSequence actions:[CCAnimate actionWithAnimation:animation], actionComplete, nil];
	[hammerAction_ retain];
	
	// Dance
	[animationFrames removeAllObjects];
	for (int i = 4; i <= 9; i++) {
		[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"death-%02d.png", i]]];
	}
	for (int i = 9; i >= 4; i--) {
		[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"death-%02d.png", i]]];
	}
	animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
	danceAction_ = [CCRepeatForever actionWithAction:[CCSequence actions:[CCAnimate actionWithAnimation:animation], actionComplete, nil]];
	[danceAction_ retain];
	
	// Roll in animation
	[animationFrames removeAllObjects];
	for (int i = 1; i <= 7; i++) {
		[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"roll-%02d.png", i]]];
	}	
	animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
	actionComplete = [CCCallFuncND actionWithTarget:self selector:@selector(rollInAnimationComplete:) data:nil];
	rollInAction_ = [CCSequence actions:[CCAnimate actionWithAnimation:animation], actionComplete, nil];
	[rollInAction_ retain];
	
	// Roll out animation
	[animationFrames removeAllObjects];
	for (int i = 8; i <= 14; i++) {
		[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"roll-%02d.png", i]]];
	}	
	animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
	actionComplete = [CCCallFuncND actionWithTarget:self selector:@selector(rollOutAnimationComplete:) data:nil];
	rollOutAction_ = [CCSequence actions:[CCAnimate actionWithAnimation:animation], actionComplete, nil];
	[rollOutAction_ retain];
}

// -----------------------------------------------------------------------------

- (void)setAnimationState:(HeroState)aState {
	if (state_ == aState) {
		return;
	}
	
	if (state_ >= kHeroStateRollIn) {
		//CCLOG(@"Roll action is active");
		return;
	}
	
	CCLOG(@"Set action: %d", aState);
	state_ = aState;
	
	switch (aState) {
		case kHeroStateIdle:
			newAction_ = idleAction_;
			[baby_ setIdle];
			break;
		case kHeroStateWalkLeft:
			[self setFlipX:YES];
			[baby_ setFlipX:YES];
			self.anchorPoint = kAnchorpointBoxLeft;
			[self stopAction:currentAction_];
			currentAction_ = walkLeftAction_;
			newAction_ = nil;
			[self runAction:currentAction_];
			[baby_ animate];
			break;
		case kHeroStateWalkRight:
			[self setFlipX:NO];
			[baby_ setFlipX:NO];
			self.anchorPoint = kAnchorpointBoxRight;
			[self stopAction:currentAction_];
			currentAction_ = walkRightAction_;
			newAction_ = nil;
			[self runAction:currentAction_];
			[baby_ animate];
			break;
		case kHeroStateDeath:
			[[RBSoundEngine sharedEngine] playEffect:@"enemy-touched.wav"];
			[self stopAction:currentAction_];
			currentAction_ = deathAction_;
			newAction_ = nil;
			[self runAction:currentAction_];
			[baby_ setIdle];
			break;
		case kHeroStateHammer:
			[self stopAction:currentAction_];
			currentAction_ = hammerAction_;
			newAction_ = nil;
			[self runAction:currentAction_];
			[baby_ setIdle];
			break;
		case kHeroStateDance:
			[self stopAction:currentAction_];
			currentAction_ = danceAction_;
			newAction_ = nil;
			[self runAction:currentAction_];
			[baby_ animate];
			break;
		case kHeroStateRollIn:
			[self stopAction:currentAction_];
			currentAction_ = rollInAction_;
			newAction_ = nil;
			[self runAction:currentAction_];
			[baby_ setIdle];
			break;
		case kHeroStateRollOut:
			[self stopAction:currentAction_];
			currentAction_ = rollOutAction_;
			newAction_ = nil;
			[self runAction:currentAction_];
			[baby_ setIdle];
			break;
			
		default:
			CCLOG(@"Unknown action state: %d", aState);
			return;
	}
}

// -----------------------------------------------------------------------------

- (BOOL)isRolling {
	if (state_ == kHeroStateRollIn) {
		return YES;
	}
	
	return NO;
}

// -----------------------------------------------------------------------------

- (BOOL)isLeftFaced {
	return self.flipX;
}

// -----------------------------------------------------------------------------

- (void)setIdle {
	currentAction_ = idleAction_;
	state_ = kHeroStateIdle;
	[self runAction:currentAction_];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Bullet counts

- (int)numberOfBullets {
	return numberOfBullets_;
}

// -----------------------------------------------------------------------------

- (void)increaseNumberOfBullets:(int)aNumber {
	numberOfBullets_ += aNumber;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Hammer counts

- (int)numberOfHammers {
	return numberOfHammers_;
}

// -----------------------------------------------------------------------------

- (void)increaseNumberOfHammers:(int)aNumber {
	numberOfHammers_ += aNumber;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Actions

- (void)moveWhenCircle:(CGPoint)direction {
	if (state_ != kHeroStateRollIn) {
		return;
	}
	
	if (fabs(direction.x) == 0) {
		return;
	}
	
	b2Vec2 velocity = body_->GetLinearVelocity();
	velocity.x = velocity.x + moveForce_ * direction.x;
	body_->SetLinearVelocity(velocity);
}

// -----------------------------------------------------------------------------

- (void)move:(CGPoint)direction {
	if (state_ == kHeroStateRollIn) {
		[self moveWhenCircle:direction];
		return;
	}
	
	b2Vec2 velocity = body_->GetLinearVelocity();
	velocity.x = moveForce_ * direction.x;
	
	if (direction.y > 0.4f && isTouchingLadder_) {
		antiGravityForce_ = YES;
	}
	
	if (antiGravityForce_) {
		velocity.y = moveForce_ * direction.y;
		velocity.x = direction.x;
	}
	else {
		velocity.x = moveForce_ * direction.x;
	}
	
	body_->SetLinearVelocity(velocity);
	
	if (direction.x != 0) {
		facingRight_ = (direction.x > 0);
		initialWalkDone_ = YES;
	}
	
	// Set correct animation
	if (direction.x == 0) {
		[self setAnimationState:kHeroStateIdle];
	}
	else if (direction.x > 0) {
		[self setAnimationState:kHeroStateWalkRight];
	}
	else {
		[self setAnimationState:kHeroStateWalkLeft];
	}
}

// -----------------------------------------------------------------------------

- (void)moveTo:(CGPoint)aPosition {
	// Position the sprite
	b2Vec2 bPos;
	bPos.x = aPosition.x / kPhysicsPTMRatio;
	bPos.y = aPosition.y / kPhysicsPTMRatio;
	body_->SetTransform(bPos, 0);
	self.position = aPosition;
	
	b2Vec2 velocity = body_->GetLinearVelocity();
	velocity.x = moveForce_ * 1.0;
	body_->SetLinearVelocity(velocity);	
}

// -----------------------------------------------------------------------------

- (void)jumpWithFactor:(float)aFactor {
	CCLOG(@"Vector jump: %f", aFactor);
	if (aFactor < kMiniumJumpFactor) {
		return;
	}
	
	// Initial jump is also ok
	initialWalkDone_ = YES;
	
	jumpFactor_ = aFactor;
	struct timeval now;
	gettimeofday(&now, NULL);	
	ccTime dt = (now.tv_sec - lastJump_.tv_sec) + (now.tv_usec - lastJump_.tv_usec) / 1000000.0f;
	if (dt > kJumpFrequency) {			
		[self toggleRoll];
		
		lastJump_ = now;
	}
}

// -----------------------------------------------------------------------------

- (void)jump {
	touchingGround_ = NO;
	
	if (contactPointCount_ > 0) {
		int foundContacts = 0;
		
		for (int i = 0; i < kMaxContactPoints && foundContacts < contactPointCount_; i++) {
			ContactPoint* point = contactPoints_ + i;
			
			if (point->otherFixture && !point->otherFixture->IsSensor()) {
				foundContacts++;
				
				if (point->normal.y > 0.5f) {
					touchingGround_ = YES;
					
					b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
					
					float impulseYFactor = 1;
					b2Vec2 vel = body_->GetLinearVelocity();
					if (vel.y > 0) {
						impulseYFactor = vel.y / 40;
					}
					
					//
					// TIP:
					// The impulse always is "up". To simulate a more realistic
					// jump, see HeroRound.mm, since it uses the normal, but it this realism is not
					// needed in Mario-like games
					//
					body_->ApplyLinearImpulse(b2Vec2(0, jumpImpulse_ * impulseYFactor), p);
					break;
				}
			}
		}
	}
	
	if (!touchingGround_) {
		b2Vec2 vel = body_->GetLinearVelocity();
		
		if (vel.y > 0) {
			b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
			float impY = jumpImpulse_ * vel.y / 160.0f;
			body_->ApplyLinearImpulse(b2Vec2(0, impY), p);
		}
	}
	
	[baby_ animate];
}

// -----------------------------------------------------------------------------

- (void)roll {
	struct timeval now;
	gettimeofday(&now, NULL);	
	ccTime dt = (now.tv_sec - lastRoll_.tv_sec) + (now.tv_usec - lastRoll_.tv_usec) / 1000000.0f;
	if (dt > kRollFrequency) {			
		lastRoll_ = now;
		[self toggleRoll];
	}
}

// -----------------------------------------------------------------------------

- (void)applySpeedUp:(CGPoint)aSpeed {
	if (state_ == kHeroStateDeath) {
		return;
	}
	
	struct timeval now;
	gettimeofday(&now, NULL);	
	ccTime dt = (now.tv_sec - lastSpeedup_.tv_sec) + (now.tv_usec - lastSpeedup_.tv_usec) / 1000000.0f;
	if (dt > kSpeedUpFrequency) {			
		b2Vec2 force = b2Vec2_zero;
		force = b2Vec2(moveForce_*aSpeed.x, moveForce_*aSpeed.y);
		
		b2Vec2 velocity = body_->GetLinearVelocity();
		force.x *= (velocity.x * aSpeed.x);
		force.y *= (velocity.y * aSpeed.y);
		
		b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
		body_->ApplyForce(force, p);				
		
		lastTimeForceApplied_ = elapsedTime_;
		lastSpeedup_ = now;
		CCLOG(@"Apply speedup: %f, %f", force.x, force.y);
	}
}

// -----------------------------------------------------------------------------

- (void)push {}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Particle system suppport

- (id)startParticleSystem:(NSString *)aName {
	return nil;
}

// -----------------------------------------------------------------------------

- (void)stopParticleSystem {
	[particleSystem_ stopSystem];
	[particleSystem_ removeFromParentAndCleanup:YES];
	[particleSystem_ release];
	particleSystem_ = nil;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Positioning

- (void)setPosition:(CGPoint)aPosition {
	[super setPosition:aPosition];
	
	if (particleSystem_ != nil) {
		[particleSystem_ setPosition:aPosition];
	}
	if (baby_ != nil) {		
		aPosition.y += 15.0;
		
		if ([self isLeftFaced]) {
			aPosition.x += 25.0;
		}
		else {
			aPosition.x += 3.0;
		}
		baby_.position = aPosition;
	}
}

// -----------------------------------------------------------------------------

- (void)die {
	CCLOG(@"Will die");
	
	died_ = YES;
	
	self.tag = 0;
	[self setAnimationState:kHeroStateDeath];
	[(Level *)game_ increaseLife:-1];
	[(Level *)game_ goalMissed];
	
	id delayAction = [CCDelayTime actionWithDuration:2.0];
	id actionComplete = [CCCallFuncND actionWithTarget:self selector:@selector(nextHero:) data:nil];
	id sequence = [CCSequence actions:delayAction, actionComplete, nil];
	[self runAction:sequence];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Game handling

- (void)onGameOver:(BOOL)winner {
	body_->SetLinearVelocity(b2Vec2(0,0));
	
	if (winner) {
		[self setAnimationState:kHeroStateDance];
	}
	else {
		[self setAnimationState:kHeroStateDeath];
	}
}

// -----------------------------------------------------------------------------

- (void)onEnter {
	[super onEnter];
	
	[self setIdle];
}

// -----------------------------------------------------------------------------

- (void)update:(ccTime)dt {
	[super update:dt];

	if (!isTouchingLadder_ || touchingGround_) {
		antiGravityForce_ = NO;
	}
	
	// If the Hero is touching a ladder, then apply an anti-gravity force
	if (antiGravityForce_) {
		// anti-gravity force
		b2Vec2 gravity = world_->GetGravity();
		b2Vec2 p = body_->GetLocalCenter();
		body_->ApplyForce( -body_->GetMass()*gravity, p);		
	}	
	
	// All other actions happen after initial walk
	if (!initialWalkDone_) {
		return;
	}

	// Unroll when no x speed
	if ((state_ == kHeroStateRollIn) && flying_) {
		b2Vec2 velocity = body_->GetLinearVelocity();
		
		if ((velocity.x < 0.3) && (velocity.y < 0.3) && flying_) {
			CCLOG(@"Too slow: %f, %f", velocity.x, velocity.y);
			[self toggleRoll];
		}
	}
	
	// Die when not roll and fall
	if (!died_) {
		if ((state_ == kHeroStateWalkLeft) || (state_ == kHeroStateWalkRight) || (state_ == kHeroStateIdle)) {
			b2Vec2 velocity = body_->GetLinearVelocity();
			if (velocity.y < 0) {
				if (fabs(velocity.y) > 0.5) {
					CCLOG(@"Negative velocity: %f", velocity.y);
					[self die];
				}
			}
		}
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Not used

- (void)blinkHero {}

// -----------------------------------------------------------------------------

- (void)beginContactWithBody:(b2Body *)aBody {
	if (died_) {
		return;
	}
	
	// Check if there is a sprite behind, if not its a box2d element
	if (aBody->GetUserData() == nil) {
		[[RBSoundEngine sharedEngine] playEffect:@"hero-touched.wav"];
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Initializing

- (void)createBoxBody {
	self.anchorPoint = kAnchorpointBoxRight;
	
	[self destroyAllFixturesFromBody:body_];
	
	float height = (kSpriteHeight / kPhysicsPTMRatio)/2;
	float width = (kSpriteWidth / kPhysicsPTMRatio);		
	b2Vec2 vertices[4];
	vertices[0].Set(0,-height);		// bottom-left
	vertices[1].Set(width,-height);	// bottom-right
	vertices[2].Set(width,height);	// top-right
	vertices[3].Set(0,height);		// top-left
	
	b2PolygonShape shape;
	shape.Set(vertices, 4);
	
	b2FixtureDef fd;
	fd.friction = 0.0f;
	fd.density = 1.0f;
	fd.restitution = 0.0f;

	fd.shape = &shape;		
	fd.filter.groupIndex = -kCollisionFilterGroupIndexHero;
	body_->CreateFixture(&fd);
	
	body_->SetFixedRotation(true);
	body_->SetType(b2_dynamicBody);
	body_->SetTransform(body_->GetPosition(), 0);
	body_->SetAngularVelocity(0);
	body_->SetLinearVelocity(b2Vec2_zero);
	[self setRotation:0.0];
}

// -----------------------------------------------------------------------------

- (void)createCircleBody {
	self.anchorPoint = kAnchorpointCircle;
	
	[self destroyAllFixturesFromBody:body_];
	
	b2CircleShape shape;
	shape.m_radius = 0.5f;	
	
	b2FixtureDef fd;
	fd.density = 1.0f;
	fd.friction = 0.2f;
	fd.restitution = 0.8f;
	fd.shape = &shape;
	body_->CreateFixture(&fd);
	
	body_->SetFixedRotation(false);
	body_->SetType(b2_dynamicBody);
	body_->SetTransform(body_->GetPosition(), 0);
	body_->SetAngularVelocity(0);
	body_->SetLinearVelocity(b2Vec2_zero);
	[self setRotation:0.0];
}

// -----------------------------------------------------------------------------

- (id)initWithBody:(b2Body*)body game:(GameNode*)aGame {
	if ((self = [super initWithBody:body game:aGame])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"walk1-01.png"];
		[self setDisplayFrame:frame];
		
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;

		[self createBoxBody];
		
		jumpImpulse_ = kJumpImpulseBox;
		moveForce_ = kMoveForceBox;
		
		state_ = kHeroStateUnknown;
		facingRight_ = YES;
		gettimeofday( &lastFire_, NULL);	
		
		antiGravityForce_ = NO;
		touchingGround_ = NO;
		numberOfBullets_ = kNumberOfInitialBullets;
		numberOfHammers_ = kNumberOfInitialHammers;
		
		self.isTouchable = NO;
		self.tag = 2110;
		
		[self initActions];		
	}
	
	return self;
}

// -----------------------------------------------------------------------------

- (void)dealloc {
	[deathAction_ release];
	[idleAction_ release];
	[walkLeftAction_ release];
	[walkRightAction_ release];
	[danceAction_ release];
	[rollInAction_ release];
	[rollOutAction_ release];
	[hammerAction_ release];
	
	[super dealloc];
}

// -----------------------------------------------------------------------------

@end
