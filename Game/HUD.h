//
//  HUD.h
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//


#define kInitialLives 3

@class ArrowJoystick;
@class GameNode;

@interface HUD : CCLayer {
	GameNode *game_;
	ArrowJoystick *joystick_;
	
	CCLabelAtlas *levelno_;
	CCLabelAtlas *score_;
	CCLabelAtlas *progress_;
	CCLabelAtlas *lives_;

	CCSprite *progressBack_;
	CCSprite *progressBar_;
	ccTime progressTime_;
	
	BOOL useDragging_;
	
	CGPoint startPos_;
	CGPoint endPos_;
	BOOL dragging_;
	
	int maxTouchHeight_;
	int level_;
}

+ (id)HUDWithGameNode:(GameNode*)game;
- (id)initWithGameNode:(GameNode*)game;

- (void)displayMessage:(NSString*)message;
- (void)onUpdateScore:(int)newScore;
- (void)onUpdateLives:(int)newLives;
- (void)onUpdateDepth:(int)newDepth;
- (void)onUpdateBullets:(int)newBullets;

- (void)showHUD;
- (void)hideHUD;

- (void)showJoystick;
- (void)hideJoystick;

@end
