//
//  Bonushero.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import <Box2D/Box2D.h>

#import "Bonushero.h"
#import "Bullet.h"
#import "Babyboo.h"
#import "Level.h"
#import "Joystick.h"
#import "HUD.h"
#import "RBSoundEngine.h"

// Box settings
#define	kJumpImpulseBox (5.0f)
#define kMoveForceBox (5.0f)
#define kAnchorpointBoxRight ccp(0.3, 0.3)
#define kAnchorpointBoxLeft ccp(0.45, 0.3)

// Circle settings
#define	kJumpImpulseCircle (5.5f)
#define kMoveForceCircle (5.0f)
#define kAnchorpointCircle ccp(0.45, 0.15)

#define kMaxSpeed (6.5f)

#define kSpriteWidth 30
#define kSpriteHeight 70

@implementation Bonushero

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Joystick

- (void)readJoystick {
	CGPoint v = CGPointMake(1, 0);
	[self move:v];
	
	if ([joystick_ isButtonPressed:BUTTON_A]) {
		[self jump];
	}
	
	if ([joystick_ isButtonPressed:BUTTON_B]) {
		[self fire];
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Movement

- (void)moveWhenCircle:(CGPoint)direction {
	if ((elapsedTime_ - lastTimeForceApplied_) > kPhysicsHeroForceInterval) {
		// default force for 4-way joystick
		b2Vec2 f = b2Vec2_zero;
		
		// using 2-way joystick ?
		if (controlDirection_ == kControlDirection2Way) {
			if (direction.x < 0) {
				f = b2Vec2(-moveForce_, 0);
			}
			else if (direction.x > 0) {
				f = b2Vec2(moveForce_, 0);
			}
		}
		else if (controlDirection_ == kControlDirection4Way) {
			f = b2Vec2(direction.x * moveForce_, direction.y * moveForce_);
		}
		
		b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
		body_->ApplyForce(f, p);				
		
		lastTimeForceApplied_ = elapsedTime_;
		
		[self updateFrames:ccp(f.x, f.y)];
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Push/Jump effect

- (void)applyImpulse:(b2Vec2)aImpulse {
	b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));

	aImpulse.x = 0;
	if (aImpulse.y > 5.5) {
		aImpulse.y = 5.5;
	}
	
	CCLOG(@"Impulse: %f, %f", aImpulse.x, aImpulse.y);
	body_->ApplyLinearImpulse(aImpulse, p);
}

// -----------------------------------------------------------------------------

- (void)push {
	BOOL touchingGround = NO;
	
	b2Vec2 impulse = b2Vec2_zero;
	
	// Jump code taken from HeroRound
	if (contactPointCount_ > 0) {
		b2Vec2 normal = b2Vec2_zero;
		int foundContacts = 0;
		
		touchingGround = YES;
		float currentNormalY=0.3f;
		
		for (int i=0; i<kMaxContactPoints && foundContacts < contactPointCount_;i++) {
			ContactPoint* point = contactPoints_ + i;
			if (point->otherFixture) {
				foundContacts++;

				if (point->normal.y > currentNormalY) {
					normal = point->normal;
					currentNormalY = point->normal.y;
				}
			}
		}

		//b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
		
		float impulseYFactor = 1;
		b2Vec2 vel = body_->GetLinearVelocity();
		
		if (vel.y > 0.5f) {
			impulseYFactor = vel.y / 40;
		}
		
		impulse = jumpImpulse_ * impulseYFactor * normal;
		[self applyImpulse:impulse];
	}
	
	if (!touchingGround) {
		b2Vec2 vel = body_->GetLinearVelocity();
		
		if (vel.y > 0) {
			//b2Vec2 p = body_->GetWorldPoint(b2Vec2(0.0f, 0.0f));
			
			float impY = jumpImpulse_ * vel.y/200;
			impulse = b2Vec2(0, impY);
			[self applyImpulse:impulse];
		}
	}

	[[RBSoundEngine sharedEngine] playEffect:@"jump.wav"];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Rolling

- (void)rollInAnimationComplete:(ccTime)dt {
	jumpImpulse_ = kJumpImpulseCircle;
	moveForce_ = kMoveForceCircle;
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

	[self setAnimationState:kHeroStateDeath];
	[self die];
	[(Level *)game_ increaseLife:-1];
	[(Level *)game_ goalMissed];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Assigned baby will follow hero

- (void)assignBaby:(Babyboo *)aBaby {
	[super assignBaby:aBaby];
	[(Level *)game_ goalReached];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Game loop

- (void)onEnter {
	[super onEnter];
	
	[self toggleRoll];
}

// -----------------------------------------------------------------------------

- (void)update:(ccTime)dt {
	[super update:dt];
		
	// Limit speed
	b2Vec2 velocity = body_->GetLinearVelocity();
	if (fabs(velocity.x) > kMaxSpeed) {
		velocity.x -= 0.1;
		body_->SetLinearVelocity(velocity);
	}

	// Adjust jump impulse
	jumpImpulse_ = velocity.x * 100.0 * dt;

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
	
	b2Vec2 pos = body_->GetPosition();
	
	if ((velocity.x < 0.1) && (velocity.y < 0.1) && (pos.x > 5.0)) {
		[self toggleRoll];
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
	fd.restitution = 0.2f;
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

@end
