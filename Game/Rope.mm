//
//  Rope.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//
//  Used in this app as rope
//

#import "Rope.h"
#import "GameNode.h"

@implementation Rope

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

- (id)initWithBody:(b2Body*)aBody game:(GameNode*)aGame {
	if ((self = [super initWithBody:aBody game:aGame])) {
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spike-ball.png"];
		[self setDisplayFrame:frame];
		
		[self destroyAllFixturesFromBody:body_];
		
		b2World *world = [game_ world];
		
		b2PolygonShape polyShape;
		polyShape.SetAsBox(10 /kPhysicsPTMRatio, 3 / kPhysicsPTMRatio);
		
		b2FixtureDef fd;
		fd.shape = &polyShape;
		fd.density = 20.0f;
		fd.friction = 0.2f;
		
		b2RevoluteJointDef jd;
		jd.collideConnected = false;
		
		b2Vec2 pos = body_->GetPosition();
		
		b2BodyDef bd;
		bd.position = pos;
		b2Body *roof = world->CreateBody(&bd);
		
		b2Body* prevBody = roof;
		const int numberOfLinks = 20;
		
		for (int32 i = 0; i < numberOfLinks; ++i) {
			b2BodyDef bd;
			bd.type = b2_dynamicBody;
			bd.position.Set(pos.x + (i+1)*0.4f, pos.y);
			b2Body* newBody = world->CreateBody(&bd);
			newBody->CreateFixture(&fd);
			
			b2Vec2 anchor( pos.x + i*0.4f + 0.2f, pos.y);
			jd.Initialize(prevBody, newBody, anchor);
			world->CreateJoint(&jd);
			
			prevBody = newBody;
			
			BodyNode *bodyNode = [[BodyNode alloc] initWithBody:newBody game:game_];
			bodyNode.preferredParent = BN_PREFERRED_PARENT_SPRITES_PNG;
			
			frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"rope-h.png"];
			[bodyNode setDisplayFrame:frame];
			
			[game_ addBodyNode:bodyNode z:0];
			[bodyNode release];
			newBody->SetUserData(bodyNode);	
		}
		
		b2CircleShape circleShape;
		circleShape.m_radius = 10 / kPhysicsPTMRatio;
		fd.shape = &circleShape;
		fd.density = 20;
		fd.friction = 0.2f;
		body_->CreateFixture(&fd);
		body_->SetTransform(b2Vec2( pos.x + (numberOfLinks+1) * 0.4f, pos.y), 0 );
		body_->SetType(b2_dynamicBody);
		
		b2Vec2 anchor( pos.x + numberOfLinks*0.4f + 0.2f, pos.y);
		jd.Initialize(prevBody, body_, anchor);
		world->CreateJoint(&jd);		
	}
	
	return self;
}

- (id)initWithBodyOld:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spike-ball.png"];
		[self setDisplayFrame:frame];
		self.visible = NO;

		[self destroyAllFixturesFromBody:body];
		
		b2World *world = [game world];
		
		b2PolygonShape polyShape;
		polyShape.SetAsBox(3 /kPhysicsPTMRatio, 10 / kPhysicsPTMRatio);
		
		b2FixtureDef fd;
		fd.shape = &polyShape;
		fd.density = 100.0f;
		fd.friction = 0.2f;
		fd.isSensor = false;
		b2RevoluteJointDef jd;
		jd.collideConnected = false;

		b2Vec2 pos = body->GetPosition();

		// Roof chain attach point
		b2BodyDef bd;
		bd.position = pos;
		b2Body *roof = world->CreateBody(&bd);
		b2Body* prevBody = roof;
		
		// Create links
		const int numberOfLinks = 8;
		for (int32 i = 0; i < numberOfLinks; ++i) {
			b2BodyDef bd;
			bd.type = b2_dynamicBody;
			bd.position.Set(pos.x, pos.y - ((i+1)*0.4f));
			b2Body* newBody = world->CreateBody(&bd);
			newBody->CreateFixture(&fd);
			
			b2Vec2 anchor(pos.x, pos.y - (i*0.4f + 0.2f));
			jd.Initialize(prevBody, newBody, anchor);
			world->CreateJoint(&jd);
			
			prevBody = newBody;
			
			BodyNode *bodyNode = [[BodyNode alloc] initWithBody:newBody game:game];
			bodyNode.preferredParent = BN_PREFERRED_PARENT_SPRITES_PNG;
			
			frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"rope.png"];
			[bodyNode setDisplayFrame:frame];

			[game addBodyNode:bodyNode z:0];
			[bodyNode release];
			newBody->SetUserData(bodyNode);	
		}
	}
	
	return self;
}

// -----------------------------------------------------------------------------

- (id)initWithBody:(b2Body*)body game:(GameNode*)game numberOfLinks:(int)aNumber {
	if ((self = [super initWithBody:body game:game])) {
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"spike-ball.png"];
		[self setDisplayFrame:frame];
		self.visible = NO;
		
		[self destroyAllFixturesFromBody:body];
		
		b2World *world = [game world];
		
		b2PolygonShape polyShape;
		polyShape.SetAsBox(3 /kPhysicsPTMRatio, 10 / kPhysicsPTMRatio);
		
		b2FixtureDef fd;
		fd.shape = &polyShape;
		fd.density = 100.0f;
		fd.friction = 0.2f;
		fd.isSensor = true;
		b2RevoluteJointDef jd;
		jd.collideConnected = false;
		
		b2Vec2 pos = body->GetPosition();
		pos.y = pos.y + 0.5;
		
		// Roof chain attach point
		b2BodyDef bd;
		bd.position = pos;
		b2Body *roof = world->CreateBody(&bd);
		b2Body* prevBody = roof;
		
		numberOfLinks_ = aNumber;
		
		// Create links
		for (int32 i = 0; i < numberOfLinks_; ++i) {
			b2BodyDef bd;
			bd.type = b2_dynamicBody;
			bd.position.Set(pos.x, pos.y - ((i+1) * 0.4f));
			b2Body* newBody = world->CreateBody(&bd);
			newBody->CreateFixture(&fd);
			
			b2Vec2 anchor(pos.x, pos.y - (i*0.4f + 0.2f));
			jd.Initialize(prevBody, newBody, anchor);
			world->CreateJoint(&jd);
			
			prevBody = newBody;
			
			BodyNode *bodyNode = [[BodyNode alloc] initWithBody:newBody game:game];
			bodyNode.preferredParent = BN_PREFERRED_PARENT_SPRITES_PNG;
			
			frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"rope.png"];
			[bodyNode setDisplayFrame:frame];
			
			[game addBodyNode:bodyNode z:-2];
			[bodyNode release];
			newBody->SetUserData(bodyNode);	
		}
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end
