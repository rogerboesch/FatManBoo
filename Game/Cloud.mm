//
//  Cloud.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "Level.h"
#import "GameConstants.h"
#import "Cloud.h"

@implementation Cloud

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Hero management

- (void)touchedByHero {}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

- (id)initWithBody:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"cloud-small.png"];
		[self setDisplayFrame:frame];

		self.anchorPoint = ccp(0.0, 1.0);
	}
	
	return self;
}

// -----------------------------------------------------------------------------

- (id)initWithPosition:(CGPoint)aPosition game:(GameNode*)aGame {
	b2CircleShape shape;
	shape.m_radius = 0.25;
	
	b2FixtureDef fd;
	fd.shape = &shape;
	fd.density = 20.0f;
	fd.restitution = 0.05f;
	fd.isSensor = true;
	fd.filter.groupIndex = kCollisionFilterGroupIndexHero;
	
	b2BodyDef bd;
	bd.type = b2_staticBody;
	bd.position.x = aPosition.x / kPhysicsPTMRatio;
	bd.position.y = aPosition.y / kPhysicsPTMRatio;
	
	b2Body *body = [aGame world]->CreateBody(&bd);
	body->CreateFixture(&fd);
	
	if ((self = [self initWithBody:body game:aGame])) {
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end
