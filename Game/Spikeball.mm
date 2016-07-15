//
//  Spikeball.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import <Box2D/Box2D.h>

#import "Spikeball.h"
#import "Level.h"
#import "Gamehero.h"
#import "RBSoundEngine.h"
#import "GameConstants.h"

#define kSpriteWidth 40
#define kSpriteHeight 40

@implementation Spikeball

@synthesize lifeTime = lifeTime_;

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Life timer

- (void)dieTimer:(id)sender {
	[self unschedule:@selector(dieTimer:)];

	CCLOG(@"Spikeball dies: %@", self);
	[game_ removeB2Body:body_];
}

// -----------------------------------------------------------------------------

- (void)setLifeTime:(int)aNumber {
	[self schedule:@selector(dieTimer:) interval:aNumber];	
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Behavior

- (void)timerComplete:(id)sender {
	[(Gamehero *)(game_.hero) die];
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
#pragma mark Auto creation

- (void)autoCreateTube:(ccTime)dt {
	Spikeball *spike = [[Spikeball alloc] initWithPosition:startPosition_ game:game_];
	[(Level *)game_ addBodyNode:spike z:9];
	spike.lifeTime = autorepeat_;
}

// -----------------------------------------------------------------------------

- (void)startAutoRepeat:(float)aInterval {
	if (aInterval > 0) {
		autorepeat_ = aInterval;
		CCLOG(@"Start autorepeat %@", self);
		[self schedule:@selector(autoCreateTube:) interval:autorepeat_];
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Parameter handling

- (void)setParameters:(NSDictionary *)params {
	[super setParameters:params];
	
	autorepeat_ = 0;
	NSString *myNumber = [params objectForKey:@"autorepeat"];
	if (myNumber) {
		[self startAutoRepeat:[myNumber intValue]];
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialization

- (id)initWithPosition:(b2Vec2)position game:(GameNode*)game {	
	b2CircleShape shape;
	shape.m_radius = 0.25;
	b2FixtureDef fd;
	fd.density = 0.1;
	fd.restitution = 0.1;
	fd.shape = &shape;
	
	b2BodyDef bd;
	bd.type = b2_dynamicBody;
	bd.position = position;
	
	body_ = [game world]->CreateBody(&bd);
	body_->CreateFixture(&fd);
	body_->SetFixedRotation(false);
	
	if ((self = [self initWithBody:body_ game:game])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spike-ball.png"];
		[self setDisplayFrame:frame];
	}
	
	return self;
}

// -----------------------------------------------------------------------------

- (id)initWithBody:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spike-ball.png"];
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
		fd.restitution = 0.1;
		fd.shape = &shape;
		fd.isSensor = false;	
		body->CreateFixture(&fd);
		
		body->SetFixedRotation(true);
		body->SetType(b2_dynamicBody);

		startPosition_ = body->GetPosition();
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end