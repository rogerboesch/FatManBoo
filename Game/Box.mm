//
//  Box.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import <Box2D/Box2D.h>

#import "Box.h"
#import "Level.h"
#import "RBSoundEngine.h"
#import "GameConstants.h"

#define kSpriteWidth 40
#define kSpriteHeight 40

@implementation Box

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Set parameters

- (void)setParameters:(NSDictionary *)params {
	[super setParameters:params];
	
	NSString *myArg = [params objectForKey:@"static"];
	if (myArg) {
		if ([myArg isEqualToString:@"yes"]) {
			body_->SetType(b2_staticBody);
		}
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialization

- (id)initWithBody:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"box-wood.png"];
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