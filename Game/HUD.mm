//
//  HUD.mm
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//
//  HUD: Head Up Display
//  - Display score
//  - Display highscore
//  - Display the menu button
//

#import "HUD.h"
#import "GameConfiguration.h"
#import "ArrowJoystick.h"
#import "GameNode.h"
#import "Level.h"
#import "Gamehero.h"
#import "MenuScene.h"
#import "LevelManager.h"
#import "RBSoundEngine.h"

#define kHeightOfProgressBar 149.0
#define kMaximumPressTime 5.0
#define kMaximumDrag 200

@implementation HUD

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Actions

- (void)buttonMenu:(id)sender {
	[[RBSoundEngine sharedEngine] playEffect:@"button.wav"];
	[(Level *)game_ menuPressed];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark HUD activation

- (void)showHUD {
	self.visible = YES;
	self.position = ccp(0, 0);
}

// -----------------------------------------------------------------------------

- (void)hideHUD {
	self.visible = NO;
	self.position = ccp(0, -1000);
}

// -----------------------------------------------------------------------------

- (void)showJoystick {
	joystick_.visible = YES;
	joystick_.position = ccp(0, 0);
}

// -----------------------------------------------------------------------------

- (void)hideJoystick {
	joystick_.visible = NO;
	joystick_.position = ccp(0, -1000);
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark HUD info

- (void)onUpdateScore:(int)newScore {
	[score_ setString: [NSString stringWithFormat:@"%05d", newScore]];
	[score_ stopAllActions];
	id scaleTo = [CCScaleTo actionWithDuration:0.1f scale:1.2f];
	id scaleBack = [CCScaleTo actionWithDuration:0.1f scale:1];
	id seq = [CCSequence actions:scaleTo, scaleBack, nil];
	[score_ runAction:seq];
}

// -----------------------------------------------------------------------------

- (void)onUpdateLives:(int)newLives {
	[lives_ setString: [NSString stringWithFormat:@"%d", newLives]];
	[lives_ stopAllActions];
	id scaleTo = [CCScaleTo actionWithDuration:0.1f scale:1.2f];
	id scaleBack = [CCScaleTo actionWithDuration:0.1f scale:1];
	id seq = [CCSequence actions:scaleTo, scaleBack, nil];
	[lives_ runAction:seq];
}

// -----------------------------------------------------------------------------

- (void)onUpdateDepth:(int)newDepth {
}

// -----------------------------------------------------------------------------

- (void)onUpdateBullets:(int)newBullets {
}

// -----------------------------------------------------------------------------

- (void)displayMessage:(NSString*)message {}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Press handler

- (void)updateProgress:(ccTime)dt {
	progressTime_ += dt;
	
	if (progressTime_ >= kMaximumPressTime) {
		progressTime_ = 0;
	}
	
	float height = kHeightOfProgressBar * progressTime_ / kMaximumPressTime; 
	
	CGRect rect = [progressBar_ textureRect];
	rect.size.height = height;
	[progressBar_ setTextureRect:rect];
	
	int percent = 100 * progressTime_ / kMaximumPressTime; 
	[progress_ setString:[NSString stringWithFormat:@"%03d", percent]];
}

// -----------------------------------------------------------------------------

- (void)updateProgressBar {
	int y = abs(endPos_.y - startPos_.y);
	if (y > kMaximumDrag) {
		y = kMaximumDrag;
	}
	
	float height = kHeightOfProgressBar * y / kMaximumDrag; 
	
	CGRect rect = [progressBar_ textureRect];
	rect.size.height = height;
	[progressBar_ setTextureRect:rect];
	
	int percent = 100 * y / kMaximumDrag; 
	[progress_ setString:[NSString stringWithFormat:@"%03d", percent]];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark User interaction handling

- (BOOL)screenTouchBegin:(CGPoint)aPoint {
	// Do not in preview mode
	if ([(Level*)game_ levelState] == kLevelStatePreview) {
		[(Level*)game_ cancelPreview];
		return YES;
	}
	
	// Do nothing during flight
	if ([(Gamehero*)game_.hero isFlying]) {
		return YES;
	}
	
	// Test y coordinate (limit area for touch)
	if (aPoint.y > maxTouchHeight_) {
		return NO;
	}
	
	// Level 15 (Bonus level) is special
	if (level_ == 15) {
		[(Gamehero *)game_.hero push];
		return YES;
	}
	
	// Test y coordinate (limit area for touch)
	if (aPoint.y < 75) {
		return NO;
	}
		
	progressTime_ = 0;
	progressBar_.visible = YES;
	progressBack_.visible = YES;
	progress_.visible = YES;
	
	if (useDragging_) {
		startPos_ = aPoint;
		endPos_ = aPoint;
		dragging_ = YES;
		
		[self updateProgressBar];
	}
	else {
		[self schedule:@selector(updateProgress:)];
	}
	
	return YES;
}

// -----------------------------------------------------------------------------

- (void)screenTouchEnd:(CGPoint)aPoint {
	// Level 15 (Bonus level) is special
	if (level_ == 15) {
		return;
	}

	progressBar_.visible = NO;
	progress_.visible = NO;
	progressBack_.visible = NO;	
	
	if (dragging_) {
		endPos_ = aPoint;

		int y = abs(endPos_.y - startPos_.y);
		if (y > kMaximumDrag) {
			y = kMaximumDrag;
		}
		
		float factor = 1.0 * y / kMaximumDrag; 
		[(Gamehero*)game_.hero jumpWithFactor:factor];
		
		dragging_ = NO;
		startPos_ = ccp(0, 0);
		endPos_ = ccp(0, 0);
	}
	else {
		[self unschedule:@selector(updateProgress:)];

		if (progressTime_ < 0.1) {
			return;
		}
		
		float factor = 1.0 * progressTime_ / kMaximumPressTime; 
		
		[(Gamehero*)game_.hero jumpWithFactor:factor];
		progressTime_ = 0;
	}	
}

// -----------------------------------------------------------------------------

- (void)screenTouchMoved:(CGPoint)aPoint {
	if (dragging_) {
		endPos_ = aPoint;
		[self updateProgressBar];
	}
}

// -----------------------------------------------------------------------------

- (void)screenTouchCancelled:(CGPoint)aPoint {
	// Level 15 (Bonus level) is special
	if (level_ == 15) {
		return;
	}

	if (dragging_) {
		dragging_ = NO;
		startPos_ = ccp(0, 0);
		endPos_ = ccp(0, 0);
	}
	else {
		[self unschedule:@selector(updateProgress:)];
		progressTime_ = 0;
	}

	progressBar_.visible = NO;
	progress_.visible = NO;
	progressBack_.visible = NO;
}

// -----------------------------------------------------------------------------

#ifdef MAC_VERSION

#pragma mark -
#pragma mark Mouse down

- (BOOL)ccMouseDown:(NSEvent*)event {
	CGPoint touchLocation = [event locationInWindow];
	return [self screenTouchBegin:touchLocation];
}

// -----------------------------------------------------------------------------

- (BOOL)ccMouseUp:(NSEvent*)event {
	CGPoint touchLocation = [event locationInWindow];
	[self screenTouchEnd:touchLocation];
	
	return NO;
}

// -----------------------------------------------------------------------------

- (BOOL)ccMouseDragged:(NSEvent *)event {	
	CGPoint touchLocation = [event locationInWindow];
	[self screenTouchMoved:touchLocation];

	return YES;
}

#else

#pragma mark -
#pragma mark Touch Handling (Remove for final game)

- (void)registerWithTouchDispatcher {
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:100 swallowsTouches:YES];
}

// -----------------------------------------------------------------------------

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];

	return [self screenTouchBegin:touchLocation];
}

// -----------------------------------------------------------------------------

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];

	[self screenTouchEnd:touchLocation];
}

// -----------------------------------------------------------------------------

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];

	[self screenTouchCancelled:touchLocation];
}

// -----------------------------------------------------------------------------

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];

	[self screenTouchMoved:touchLocation];
}

#endif

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Object management

+ (id)HUDWithGameNode:(GameNode*)game {
	return [[[self alloc] initWithGameNode:game] autorelease];
}

// -----------------------------------------------------------------------------

- (id)initWithGameNode:(GameNode*)aGame {
	if ((self = [super init])) {
#ifndef MAC_VERSION
		self.isTouchEnabled = YES;
#else
		self.isMouseEnabled = YES;
#endif
		game_ = aGame;
		level_ = [[LevelManager sharedManager] currentLevel];
		
		CGSize s = [[CCDirector sharedDirector] winSize];

		maxTouchHeight_ = s.height - 40;

		joystick_ = [ArrowJoystick joystick];
		[joystick_ setPadEnabled: YES];
		[joystick_ setPadPosition:ccp(74, 74)];
		[joystick_ setPosition:ccp(s.width-42, 40) forButton:BUTTON_A];
		[self addChild:joystick_];
	
		[[game_ hero] setJoystick:joystick_];		
				
		// Menu Button
		CCMenuItem *itemPause = [CCMenuItemImage itemWithNormalImage:@"btn-pause-normal.png" selectedImage:@"btn-pause-selected.png" target:self selector:@selector(buttonMenu:)];
		CCMenu *menu = [CCMenu menuWithItems:itemPause, nil];
		[self addChild:menu z:1];
		[menu setPosition:ccp(25,s.height-25)];
		
		// Level No
		NSString *info = [NSString stringWithFormat:@"%d", [[LevelManager sharedManager] currentLevelNumber]];
		levelno_ = [[CCLabelAtlas labelWithString:info charMapFile:@"number_fonts_small.png" itemWidth:16 itemHeight:24 startCharMap:'0'] retain];
		[self addChild:levelno_ z:1];
		[levelno_ setPosition:ccp(60, s.height-30.0f)];
		
		// Score Points
		score_ = [[CCLabelAtlas labelWithString:@"00000" charMapFile:@"number_fonts_small.png" itemWidth:16 itemHeight:24 startCharMap:'0'] retain];
		[self addChild:score_ z:1];
		[score_ setPosition:ccp(s.width-90, s.height-30.0f)];
		
		// Live sprite
		CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"small-heart.png"];
		[self addChild:sprite z:1];
		[sprite setPosition:ccp(s.width/2.0-13, s.height-19.0f)];

		// Lives
		lives_ = [[CCLabelAtlas labelWithString:@"0x" charMapFile:@"number_fonts_small.png" itemWidth:16 itemHeight:24 startCharMap:'0'] retain];
		[self addChild:lives_ z:1];
		[lives_ setPosition:ccp(s.width/2.0, s.height-30.0f)];

		if ([[LevelManager sharedManager] currentLevel] == 15) {
			[lives_ setString: [NSString stringWithFormat:@"%d", 1]];
		}
		else {
			[lives_ setString: [NSString stringWithFormat:@"%d", kInitialLives]];
		}

		CCDirector *director = [CCDirector sharedDirector];
        CGSize size = [director winSize];
        
		// Progress Points
		progress_ = [[CCLabelAtlas labelWithString:@"000" charMapFile:@"number_fonts_small.png" itemWidth:16 itemHeight:24 startCharMap:'0'] retain];
		[self addChild:progress_ z:1];
		progress_.position = ccp(size.width-80, 320-125);
		progress_.visible = NO;
		
		// Progress bar
		progressBack_ = [CCSprite spriteWithFile:@"progressback.png"];
		progressBack_.anchorPoint = ccp(0,0);
		progressBack_.position = ccp(size.width-25, 320-191);
		progressBack_.visible = NO;
		[self addChild:progressBack_];
		
		progressBar_ = [CCSprite spriteWithFile:@"progressbar.png"];
		progressBar_.anchorPoint = ccp(0,0);
		progressBar_.position = ccp(size.width-25, 320-190);
		progressBar_.visible = NO;
		[self addChild:progressBar_];
		
		[self showHUD];
		
		useDragging_ = YES;
	}
	
	return self;
}

// -----------------------------------------------------------------------------

- (void)dealloc {
	[super dealloc];
}

// -----------------------------------------------------------------------------

@end
