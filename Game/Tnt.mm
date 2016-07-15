//
//  Tnt.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import <Box2D/Box2D.h>

#import "Tnt.h"
#import "Level.h"
#import "RBSoundEngine.h"
#import "GameConstants.h"

#define kSpriteWidth 40
#define kSpriteHeight 40

@implementation Tnt

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Positioning

- (void)setPosition:(CGPoint)aPosition {
	[super setPosition:aPosition];
	if (particleSystem_ != nil) {
		[particleSystem_ setPosition:aPosition];
	}
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
#pragma mark Behavior

- (void)timerComplete:(id)sender {
	[game_ removeB2Body:body_];
	[(Level *)game_ createExplosion:self];
	[[RBSoundEngine sharedEngine] playEffect:@"explosion.wav"];
	[(Level *)game_ increaseScoreWithNode:100 node:self];

	if (implosion_) {
		[(Level *)game_ launchBomb:self.position explosion:NO force:force_];
	}	
}

// -----------------------------------------------------------------------------

- (void)touchedByHero {
	if (touched_) {
		return;
	}
	
	touched_ = YES;
	
	id action = [CCDelayTime actionWithDuration:0.5];
	id fnc = [CCCallFuncND actionWithTarget:self selector:@selector(timerComplete:) data:nil];
	id seq = [CCSequence actions:action, fnc, nil];
	
	[self runAction:seq];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Parameter handling

- (void)setParameters:(NSDictionary *)params {
	[super setParameters:params];
	
	implosion_ = NO;
	force_ = 0.0;
	NSString *myFlag = [params objectForKey:@"implosion"];
	if (myFlag) {
		if ([myFlag isEqualToString:@"yes"]) {
			implosion_ = YES;
		}
	}

	NSString *myNumber = [params objectForKey:@"force"];
	if (myNumber) {
		force_ = [myNumber floatValue];
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialization

- (id)initWithBody:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"box-tnt.png"];
		[self setDisplayFrame:frame];
		
		self.anchorPoint = ccp(0.0, 1.0);
		
		reportContacts_ = BN_CONTACT_NONE;
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
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end