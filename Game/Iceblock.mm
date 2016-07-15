//
//  Iceblock.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import <Box2D/Box2D.h>

#import "Iceblock.h"
#import "Level.h"
#import "Gamehero.h"
#import "RBSoundEngine.h"
#import "GameConstants.h"

#define kSpriteWidth 40
#define kSpriteHeight 40

@implementation Iceblock

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Collision handling

- (void)preSolveContact:(b2Contact*)contact  manifold:(const b2Manifold*)oldManifold {
	b2WorldManifold worldManifold;
	contact->GetWorldManifold(&worldManifold);
	b2Fixture *fixtureA = contact->GetFixtureA();
	b2Fixture *fixtureB = contact->GetFixtureB();
	NSAssert( fixtureA != fixtureB, @"preSolveContact: BOX2D bug");
	
	b2Body *bodyA = fixtureA->GetBody();
	b2Body *bodyB = fixtureB->GetBody();
	NSAssert( bodyA != bodyB, @"preSolveContact: BOX2D bug");
	
	BodyNode *dataA = (BodyNode*) bodyA->GetUserData();
	BodyNode *dataB = (BodyNode*) bodyB->GetUserData();
	
	// Check if the other fixture is the hero
	Class p1 = [Gamehero class];
	if ([dataA isKindOfClass:p1] || [dataB isKindOfClass:p1] ) {
		contact->SetEnabled(false);
		[self touchedByHero];
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Behavior

- (void)timerComplete:(id)sender {
	[game_ removeB2Body:body_];
	[(Level *)game_ increaseScoreWithNode:100 node:self];
	[[RBSoundEngine sharedEngine] playEffect:@"glass.wav"];
}

// -----------------------------------------------------------------------------

- (void)touchedByHero {
	if (touched_) {
		return;
	}

	touched_ = YES;

	id action = [CCDelayTime actionWithDuration:0.05];
	id fnc = [CCCallFuncND actionWithTarget:self selector:@selector(timerComplete:) data:nil];
	id seq = [CCSequence actions:action, fnc, nil];
	
	[self runAction:seq];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialization

- (id)initWithBody:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"box-ice.png"];
		[self setDisplayFrame:frame];
		
		self.anchorPoint = ccp(0.0, 1.0);
		
		reportContacts_ = BN_CONTACT_PRESOLVE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		isTouchable_ = NO;
		
		[self destroyAllFixturesFromBody:body];
		
		CGSize mySize = CGSizeMake(kSpriteWidth/kPhysicsPTMRatio, kSpriteHeight/kPhysicsPTMRatio);
		
		b2Vec2 vertices[4];
		vertices[0].Set(0, -mySize.height);				// bottom-left
		vertices[1].Set(mySize.width, -mySize.height);	// bottom-right
		vertices[2].Set(mySize.width, 0);				// top-right
		vertices[3].Set(0, 0);							// top-left
		
		b2PolygonShape shape;
		shape.Set(vertices, 4);
		
		b2FixtureDef fd;
		fd.density = 0.1;
		fd.friction = 0.0f;
		fd.restitution = 0.0;
		fd.shape = &shape;
		fd.isSensor = false;	
		body->CreateFixture(&fd);
		
		body->SetFixedRotation(true);
		body->SetType(b2_dynamicBody);
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end