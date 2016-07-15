//
//  Island.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//
//  Supported parameters:
//	-direction (string): "horizontal" is an horizontal movement. Else it will be a vertical movement
//  -duration (float): the duration of the movement
//  -translation (float): how many pixels does the platform move
//

#import <Box2d/Box2D.h>
#import "GameConstants.h"
#import "Island.h"

@implementation Island

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Game loop

- (void)onEnter {
	[super onEnter];
	goingForward_ = YES;
	
	float vel = (translationInPixels_ / duration_) /kPhysicsPTMRatio;

	if (direction_ == kPlatformDirectionHorizontal) {
		velocity_ = b2Vec2( vel, 0 );
		finalPosition_ = origPosition_ + b2Vec2(translationInPixels_/kPhysicsPTMRatio, 0);
	}
	else {
		velocity_ = b2Vec2( 0, vel );
		finalPosition_ = origPosition_ + b2Vec2(0, translationInPixels_/kPhysicsPTMRatio);
	}
	
	body_->SetLinearVelocity( velocity_ );
	[self schedule: @selector(updatePlatform:) interval:duration_];
}

// -----------------------------------------------------------------------------

- (void)updatePlatform:(ccTime)dt {
	//b2Vec2 currVel = body_->GetLinearVelocity();
	b2Vec2 destPos;

	if (goingForward_) {
		body_->SetTransform( finalPosition_, 0 );
		body_->SetLinearVelocity( -velocity_ );
		goingForward_ = NO;
	}
	else {
		body_->SetTransform( origPosition_, 0 );
		body_->SetLinearVelocity( velocity_ );
		goingForward_ = YES;
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialization

- (void)setParameters:(NSDictionary*)dict {
	[super setParameters:dict];
	
	NSString *dir = [dict objectForKey:@"direction"];
	if ([dir isEqualToString:@"horizontal"]) {
		direction_ = kPlatformDirectionHorizontal;
	}
	else { 
		direction_ = kPlatformDirectionVertical;
	}
	
	duration_ = (direction_ == kPlatformDirectionHorizontal ? 4 : 1.5f);
	translationInPixels_ = (direction_ == kPlatformDirectionHorizontal ? 250 : 150);
	
	NSString *dur = [dict objectForKey:@"duration"];
	if (dur) {
		duration_ = [dur floatValue];
	}
	
	NSString *trans = [dict objectForKey:@"translation"];
	if (trans) {
		translationInPixels_ = [trans floatValue];
	}
}

// -----------------------------------------------------------------------------

- (id)initWithBody:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"island-3.png"];
		[self setDisplayFrame:frame];
		
		// bodyNode properties
		reportContacts_ = BN_CONTACT_NONE;
		preferredParent_ = BN_PREFERRED_PARENT_SPRITES_PNG;
		isTouchable_ = NO;
		
		[self setAnchorPoint:ccp(0,1)];
		
		origPosition_ = body->GetPosition();
		body->SetType(b2_kinematicBody);
		
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end
