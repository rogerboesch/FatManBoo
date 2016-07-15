//
//  ArrowJoystick.m
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "ArrowJoystick.h"

@implementation ArrowJoystick

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Button access

- (BOOL)isPadEnabled {
	return YES;
}

// -----------------------------------------------------------------------------

- (void)setPadEnabled:(BOOL)enabled {}
- (void)setPadPosition:(CGPoint)pos {}
- (void)setButton:(unsigned int)buttonNumber enabled:(BOOL)enabled {}
- (void)setPosition:(CGPoint)position forButton:(unsigned int)buttonNumber {}

// -----------------------------------------------------------------------------

- (CGPoint)getCurrentNormalizedVelocity {
	CGPoint	ret = CGPointZero;
	
	if (buttons_[JOYSTICK_CAR_LEFT].isPressed_) {
		ret.x = -1;
	}
	else if (buttons_[JOYSTICK_CAR_RIGHT].isPressed_) {
		ret.x = 1;
	}
	
	return ret;
}

// -----------------------------------------------------------------------------

- (CGPoint)getCurrentVelocity {
	return [self getCurrentNormalizedVelocity];
}

// -----------------------------------------------------------------------------

- (CGPoint)getCurrentDegreeVelocity {
	return CGPointZero;
}

// -----------------------------------------------------------------------------

- (BOOL)isButtonPressed:(unsigned int)buttonNumber {
	return buttons_[buttonNumber].isPressed_;
}

// -----------------------------------------------------------------------------

- (BOOL)isButtonEnabled:(unsigned int)buttonNumber {
	return buttons_[buttonNumber].enabled_;
}

// -----------------------------------------------------------------------------

#ifdef MAC_VERSION

- (BOOL)ccMouseDown:(NSEvent*)event {
	CGPoint touchLocation = [event locationInWindow];

	// button ?
	for (int i = 0; i < JOYSTICK_CAR_MAX;i++) {
		if ( buttons_[i].enabled_ && CGRectContainsPoint(buttons_[i].bounds_ , touchLocation)) {
			buttons_[i].isPressed_ = YES;
			buttons_[i].eventNumber_ = [event eventNumber];
			buttons_[i].sprite_.color = (ccColor3B) {255,0,255};
			
			return YES;
		}
	}
	
	return NO;
}

// -----------------------------------------------------------------------------

- (BOOL)ccMouseUp:(NSEvent*)event {
	for (int i = 0; i < JOYSTICK_CAR_MAX; i++) {
		if ([event eventNumber] == buttons_[i].eventNumber_ ) {
			buttons_[i].eventNumber_ = 0;
			buttons_[i].isPressed_ = NO;
			buttons_[i].sprite_.color = (ccColor3B) {255,255,255};
			
			return YES;
		}
	}

	return NO;
}

// -----------------------------------------------------------------------------

- (BOOL)ccMouseDragged:(NSEvent *)event {	
	return YES;
}

#else

#pragma mark -
#pragma mark Touch delegate

- (void)registerWithTouchDispatcher {
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:10 swallowsTouches:YES];
}

// -----------------------------------------------------------------------------

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	
	// button ?
	for (int i = 0; i < JOYSTICK_CAR_MAX;i++) {
		if ( buttons_[i].enabled_ && CGRectContainsPoint(buttons_[i].bounds_ , location)) {
			buttons_[i].isPressed_ = YES;
			buttons_[i].touch_ = touch;
			buttons_[i].sprite_.color = (ccColor3B) {255,0,255};

			return YES;
		}
	}
	
	return NO;
}

// -----------------------------------------------------------------------------

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	for (int i = 0; i < JOYSTICK_CAR_MAX; i++) {
		if (touch == buttons_[i].touch_ ) {
			buttons_[i].touch_ = nil;
			buttons_[i].isPressed_ = NO;
			buttons_[i].sprite_.color = (ccColor3B) {255,255,255};
			
			return;
		}
	}
}

// -----------------------------------------------------------------------------

- (void)ccTouchCancelled:(UITouch*)touch withEvent:(UIEvent*)event {
	[self ccTouchEnded:touch withEvent:event];
}

#endif
// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

+ (id)joystick {
	return [[[self alloc] init] autorelease];
}

// -----------------------------------------------------------------------------

- (id)init {
	if ((self = [super init])) {
#ifdef MAC_VERSION
		self.isMouseEnabled = YES;
#else
		self.isTouchEnabled = YES;
#endif		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		for( int i=0; i < JOYSTICK_CAR_MAX; i++) {
			NSString *buttonName;
			CGPoint pos;
			
			switch (i) {
				case JOYSTICK_CAR_LEFT:
					buttonName = @"arrow_left.png";
					pos = ccp(winSize.width/2-100, 40);
					break;

				case JOYSTICK_CAR_RIGHT:
					buttonName = @"arrow_right.png";
					pos = ccp(winSize.width/2+100, 40);
					break;
					
				case BUTTON_A:
					buttonName = @"arrow_up.png";
					pos = ccp(winSize.width-42, 40);
					break;
				
				default:
					NSAssert(NO, @"should not happen");
					break;
			}
						
			if (i != BUTTON_A) {
				buttons_[i].sprite_ = [CCSprite spriteWithFile:buttonName];
				CGSize s = [buttons_[i].sprite_ contentSize];
				buttons_[i].sprite_.position = pos;
				
				[self addChild:buttons_[i].sprite_ z:10];
				
				// all buttons are enabled by default
				buttons_[i].enabled_ = YES;
				buttons_[i].isPressed_ = NO;
#ifdef MAC_VERSION
				buttons_[i].eventNumber_ = 0;
#else
				buttons_[i].touch_ = nil;
#endif
				buttons_[i].bounds_ = CGRectMake( pos.x - s.width/2, pos.y - s.height/2, s.width, s.height);
			}
		}		
	}
	return self;
}

// -----------------------------------------------------------------------------

- (void) dealloc {
	[super dealloc];
}

// -----------------------------------------------------------------------------

@end
