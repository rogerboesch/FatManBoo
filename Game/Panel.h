//
//  Panel.h
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "cocos2d.h"

typedef enum {
	kPanelStateInactive = 0,
	kPanelStatePause,
	kPanelStateWin,
	kPanelStateWinBonus,
	kPanelStateLoose
} PanelState;

@class GameNode;

@interface Panel : CCLayer {
	GameNode *game_;
	
	CCLabelTTF *scoreLabel_;
	CCLabelTTF *titleLabel_;
	CCLabelTTF *levelLabel_;
	CCMenu *nextMenu_;
	CCMenu *playMenu_;
	CCMenu *audioOn_;
	CCMenu *audioOff_;
	
	int oldScore_;
	int newScore_;
	PanelState panelState_;
}

// Show pause controls
- (void)activatePanelState:(PanelState)aState oldScore:(int)aOldScore newScore:(int)aNewScore;
- (void)closePanel;

// Creates and initializes a panel
+ (id)panelWithGameNode:(GameNode *)aGame;

@end
