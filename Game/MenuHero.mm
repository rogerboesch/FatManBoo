//
//  MenuHero.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "MenuHero.h"

@implementation MenuHero

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

- (id)init {
	if ((self=[super init])) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"slimy-menu-1.png"];
		[self setDisplayFrame:frame];
		
		NSMutableArray *spriteFrames = [NSMutableArray array];
		
		// Idle
		for (int i = 1; i <= 5; i++) {
			[spriteFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"slimy-menu-%d.png", i]]];
		}
		
		CCAnimation *animation = [CCAnimation animationWithSpriteFrames:spriteFrames delay:0.1];
		id actionAnimate = [CCAnimate actionWithAnimation:animation];
		id actionTimer1 = [CCDelayTime actionWithDuration:1.0];
		id actionTimer2 = [CCDelayTime actionWithDuration:2.0];
		id actionTimer3 = [CCDelayTime actionWithDuration:3.0];
		id actionSeq = [CCSequence actions:actionAnimate, actionTimer3, actionAnimate, actionTimer1, actionAnimate, actionTimer2, nil];
		action_ = [CCRepeatForever actionWithAction:actionSeq];
		[action_ retain];
		
		[self runAction:action_];
	}
	
	return self;
}

// -----------------------------------------------------------------------------

- (void)dealloc {
	[action_ release];
	[super dealloc];
}

@end
