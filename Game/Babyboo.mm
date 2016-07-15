//
//  Babyboo.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import <Box2D/Box2D.h>

#import "Babyboo.h"
#import "Gamehero.h"
#import "GameConstants.h"
#import "RBSoundEngine.h"
#import "Level.h"
#import "LevelManager.h"

#define SPRITE_FRAME_NAME @"head-01.png"

#define kSpriteWidth 30
#define kSpriteHeight 50

@implementation Babyboo

@synthesize follows = follows_;

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
#pragma mark Animations

- (void)setIdle {
	[self stopAllActions];
	
	// Create new action
	// Animation
	NSMutableArray *animationFrames = [NSMutableArray array];
	for (int i = 5; i >= 4; i--) {
		[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"head-%02d.png", i]]];
	}		
	id animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.2f];
	id action = [CCAnimate actionWithAnimation:animation];
	id seq = [CCSequence actions:action, [CCDelayTime actionWithDuration:0.4], action, [CCDelayTime actionWithDuration:0.5], action, [CCDelayTime actionWithDuration:0.9], nil];
	[self runAction:[CCRepeatForever actionWithAction:seq]];
}

// -----------------------------------------------------------------------------

- (void)animate {	
	[self stopAllActions];
	
	// Create new action
	// Animation
	NSMutableArray *animationFrames = [NSMutableArray array];
	for (int i = 1; i <= 7; i++) {
		[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"head-%02d.png", i]]];
	}	
	
	id animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
	//id complete = [CCCallFuncND actionWithTarget:self selector:@selector(changeFace:) data:nil];
	
	id seq = [CCSequence actions:[CCAnimate actionWithAnimation:animation], nil];
	[self runAction:[CCRepeatForever actionWithAction:seq]];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Touched by Hero

- (void)touchedByHero {
	[self animate];
	
	if (!follows_) {
		[[RBSoundEngine sharedEngine] playEffect:@"pickup.wav"];
		[[RBSoundEngine sharedEngine] playEffect:@"laught.wav"];
		[(Level *)game_ increaseScoreWithNode:1000 node:self];
		
		CCLOG(@"Baby %@ touched %@", self, game_.hero);
		[(Gamehero *)game_.hero assignBaby:self];
		
		// Delete reference
		body_->SetUserData(NULL);
		remove_ = YES;
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Change direction

- (void)changeFace:(ccTime)dt {
	self.flipX = !self.flipX;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Repositioning

- (void)setPosition:(CGPoint)aPosition {
	[super setPosition:aPosition];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Main loop

- (void)update:(ccTime)dt {
	if (remove_) {
		[game_ removeB2Body:body_];
		remove_ = NO;
	}	
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialization

- (id)init {
	if ((self = [super init])) {
	}
	
	return self;
}

// -----------------------------------------------------------------------------

- (id)initWithBody:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"head-01.png"];
		[self setDisplayFrame:frame];
		self.anchorPoint = ccp(0.38, 0.4);

		reportContacts_ = BN_CONTACT_PRESOLVE;

		[self destroyAllFixturesFromBody:body];
		
		CGSize mySize = CGSizeMake(kSpriteWidth/kPhysicsPTMRatio, kSpriteHeight/kPhysicsPTMRatio);
		
		b2Vec2 vertices[4];
		vertices[0].Set(0, -mySize.height);				// bottom-left
		vertices[1].Set(mySize.width, -mySize.height);	// bottom-right
		vertices[2].Set(mySize.width, 0);				// top-right
		vertices[3].Set(0, 0);							// top-left
		
		b2PolygonShape shape;
		shape.Set(vertices, 4);

		int chapter = [[LevelManager sharedManager] currentChapter];
		if (chapter == 1) {
			b2FixtureDef fd;
			fd.shape = &shape;
			fd.isSensor = true;	
			body->CreateFixture(&fd);
			
			body->SetFixedRotation(true);
			body->SetType(b2_staticBody);
		}
		else {
			b2FixtureDef fd;
			fd.density = 0.01;
			fd.shape = &shape;
			fd.isSensor = false;	
			fd.filter.groupIndex = -kCollisionFilterGroupIndexHero;
			body->CreateFixture(&fd);
			
			body->SetFixedRotation(true);
			body->SetType(b2_dynamicBody);
		}		
		
		// Animation
		NSMutableArray *animationFrames = [NSMutableArray array];
		for (int i = 1; i <= 7; i++) {
			[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"head-%02d.png", i]]];
		}	

		id animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
		id complete = [CCCallFuncND actionWithTarget:self selector:@selector(changeFace:) data:nil];

		id seq = [CCSequence actions:[CCAnimate actionWithAnimation:animation], complete, nil];
		[self runAction:[CCRepeatForever actionWithAction:seq]];
		
		[self scheduleUpdate];
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end
