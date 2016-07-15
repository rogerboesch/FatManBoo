//
//  Smallisland.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import <Box2d/Box2D.h>
#import "Smallisland.h"

@implementation Smallisland

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialization

- (id)initWithBody:(b2Body*)body game:(GameNode*)game {
	if ((self = [super initWithBody:body game:game])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"island-4.png"];
		[self setDisplayFrame:frame];
	}
	
	return self;
}

// -----------------------------------------------------------------------------

@end
