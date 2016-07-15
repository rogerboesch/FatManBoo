//
//  Ropebridge.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import <Box2d/Box2D.h>

#import "Ropebridge.h"
#import "GameNode.h"

@implementation Ropebridge

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Create the chain

- (void)removeEndBody {
	[game_ removeB2Body:body_];
}

// -----------------------------------------------------------------------------

- (void)createChain {
	b2World *world = [game_ world];
	
	// destroy previously created fixtures
	[self destroyAllFixturesFromBody:body_];
	
	b2PolygonShape polyShape;
	polyShape.SetAsBox(10 / kPhysicsPTMRatio, 3 / kPhysicsPTMRatio);
	
	b2FixtureDef fd;
	fd.shape = &polyShape;
	fd.density = 20.0f;
	fd.friction = 0.2f;
	
	b2RevoluteJointDef jd;
	jd.collideConnected = true;
	
	// obtain initial position
	b2Vec2 pos = body_->GetPosition();
	
	// Roof: Chain attach point
	b2BodyDef bd;
	bd.position = pos;
	b2Body *roof = world->CreateBody(&bd);
	
	b2Body* prevBody = roof;
	
	float posY = pos.y;
	for (int32 i = 0; i < numberOfLinks_; ++i) {
		b2BodyDef bd;
		bd.type = b2_dynamicBody;
		bd.position.Set(pos.x + (i+1)*0.5f, posY);
		b2Body* newBody = world->CreateBody(&bd);
		newBody->CreateFixture(&fd);
		
		b2Vec2 anchor(pos.x + i*0.5f + 0.0f, posY);
		jd.Initialize(prevBody, newBody, anchor);
		world->CreateJoint(&jd);
		
		prevBody = newBody;
		
		BodyNode *bodyNode = [[BodyNode alloc] initWithBody:newBody game:game_];
		bodyNode.preferredParent = BN_PREFERRED_PARENT_SPRITES_PNG;
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"rope-h.png"];
		[bodyNode setDisplayFrame:frame];
		
		[game_ addBodyNode:bodyNode z:0];
		[bodyNode release];
		newBody->SetUserData(bodyNode);	
	}
	
	// End body
	b2CircleShape circleShape;
	circleShape.m_radius = 1 / kPhysicsPTMRatio; 
	fd.shape = &circleShape;
	fd.density = 2000000;
	fd.friction = 0.2f;
	body_->CreateFixture(&fd);
	body_->SetTransform( b2Vec2( pos.x + (numberOfLinks_) * 0.5f, posY), 0 );
	body_->SetType(b2_dynamicBody);
	
	b2Vec2 anchor(pos.x + (numberOfLinks_) * 0.5f, posY);
	jd.Initialize(prevBody, body_, anchor);
	world->CreateJoint(&jd);		
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Parameter parsing

- (void)setParameters:(NSDictionary *)params {
	[super setParameters:params];
	
	NSString *myLinks = [params objectForKey:@"links"];
	if (myLinks) {
		numberOfLinks_ = [myLinks intValue];
	}

	if (numberOfLinks_ < 3) {
		numberOfLinks_ = 3;
	}
	CCLOG(@"Number of chain links: %d", numberOfLinks_);
	
	[self createChain];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

- (id)initWithBody:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {	
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spike-ball.png"];
		[self setDisplayFrame:frame];
		self.visible = NO;
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end
