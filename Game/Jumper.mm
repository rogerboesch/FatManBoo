//
//  Jumper.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import <Box2D/Box2D.h>

#import "GameNode.h"
#import "GameConstants.h"
#import "Jumper.h"
#import "Gamehero.h"

#define kSpriteWidth 59
#define kSpriteHeight 29

@implementation Jumper

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Behavior

- (void)touchedByHero {
	[(Gamehero *)game_.hero applySpeedUp:speedUp_];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Set parameters

- (void)setParameters:(NSDictionary *)params {
	[super setParameters:params];
	
	NSString *myArg = [params objectForKey:@"speedupX"];
	if (myArg) {
		speedUp_.x = [myArg floatValue];
	}
	
	myArg = [params objectForKey:@"speedupY"];
	if (myArg) {
		speedUp_.y = [myArg floatValue];
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

- (id)initWithBody:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mushroom-1.png"];
		[self setDisplayFrame:frame];
		
		self.anchorPoint = ccp(0.0, 0.9);
		
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
		fd.restitution = 1.0;
		fd.shape = &shape;
		fd.isSensor = false;	
		body->CreateFixture(&fd);
		
		body->SetFixedRotation(true);
		body->SetType(b2_staticBody);

		NSMutableArray *animationFrames = [NSMutableArray new];
		for (int i = 1; i <= 6; i++) {
			[animationFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"mushroom-%d.png", i]]];
		}
		
		id animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:0.1f];
		id rep = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
		[self runAction:rep];

		speedUp_ = CGPointMake(1, 0.5);
	}
	
	return self;
}

// -----------------------------------------------------------------------------

- (void)dealloc {
	[action_ release];
	[super dealloc];
}

// -----------------------------------------------------------------------------

@end
