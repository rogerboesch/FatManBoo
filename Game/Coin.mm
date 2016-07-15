//
//  Coin.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "Level.h"
#import "GameConstants.h"
#import "Coin.h"

@implementation Coin

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Behavior

- (void) touchedByHero {
	[super touchedByHero];
	[(Level *)game_ increaseScoreWithNode:500 node:self];
	[(Level *)game_ takeCoin];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

- (id)initWithBody:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"coin-1.png"];
		[self setDisplayFrame:frame];

		// Rotation
		NSMutableArray *animationFrames = [NSMutableArray new];
		for (int i = 1; i <= 9; i++) {
			[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"coin-%d.png", i]]];
		}
		
		id animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
		id rep = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
		[self runAction:rep];
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
	fd.filter.groupIndex = -kCollisionFilterGroupIndexHero;
	
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
