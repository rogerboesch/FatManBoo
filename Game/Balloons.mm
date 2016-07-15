//
//  Ballons.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "Level.h"
#import "GameConstants.h"
#import "Balloons.h"

@implementation Ballon


// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Main loop

- (void)update:(ccTime)dt {
	b2Vec2 gravity = world_->GetGravity();
	b2Vec2 p = body_->GetLocalCenter();
	body_->ApplyForce(-body_->GetMass()*gravity, p);
	
	elapsedTime_ += dt;
	if (elapsedTime_ > 100) {
		[game_ removeB2Body:body_];
	}	
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Hero management

- (void)touchedByHero {}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

- (id)initWithBody:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"balloon.png"];
		[self setDisplayFrame:frame];
		
		self.anchorPoint = ccp(0.0, 1.0);

		world_ = [game world];
	}
	
	return self;
}

// -----------------------------------------------------------------------------

- (id)initWithPosition:(CGPoint)aPosition game:(GameNode*)aGame speedY:(float)speedY heart:(BOOL)aHeart {
	world_ = [aGame world];

	b2CircleShape shape;
	shape.m_radius = 0.25;
	
	b2FixtureDef fd;
	fd.shape = &shape;
	fd.density = 100000.1f;
	fd.restitution = 0.05f;
	fd.isSensor = true;
	fd.filter.groupIndex = kCollisionFilterGroupIndexHero;

	b2BodyDef bd;
	bd.type = b2_dynamicBody;
	bd.position.x = aPosition.x / kPhysicsPTMRatio;
	bd.position.y = aPosition.y / kPhysicsPTMRatio;
	
	b2Body *body = [aGame world]->CreateBody(&bd);
	body->CreateFixture(&fd);

	body->SetLinearVelocity(b2Vec2(0.0, speedY));

	if ((self = [self initWithBody:body game:aGame])) {
		if (aHeart) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"balloonHeart.png"];
			[self setDisplayFrame:frame];

			if (RANDOM(0, 1)) {
				RBDebug(@"Flip balloon");
				self.flipX = YES;
			}
		}
		
		[self scheduleUpdateWithPriority:-10];
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end
