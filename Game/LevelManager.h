//
//  LevelManager.h
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

// Number of chapter and levels in bundle
#define NUMBER_OF_CHAPTERS 3
#define NUMBER_OF_LEVELS_IN_CHAPTER 15

#define BONUS_MAXIMUM 2

@interface LevelManager : NSObject {
	int chapter_;
	int level_;
	int bonusLevel_;
}

// Get chapter and level
- (int)currentChapter;
- (int)currentLevel;
- (int)currentLevelNumber;

// Set current level
- (void)setLevel:(int)aLevel inChapter:(int)aChapter;

// Get/set highscore
- (int)highscoreOfLevel:(int)aLevel chapter:(int)aChapter;
- (int)currentHighscore;
- (void)setCurrentScore:(int)aScore;

// Get/Set bonus level
- (int)bonusOfLevel:(int)aLevel chapter:(int)aChapter;
- (int)currentBonusLevel;
- (void)setBonusLevel:(int)aBonusLevel;

// Get chapter number text
- (NSString *)currentLevelChapter;

// Chapter managmenet
- (void)unlockChapter:(int)aChapter;
- (void)unlockNextChapter;
- (BOOL)isChapterUnlocked:(int)aChapter;
	
// Level managmenet
- (void)unlockLevel:(int)aLevel chapter:(int)aChapter;
- (void)unlockNextLevel;
- (BOOL)isLevelUnlocked:(int)aLevel chapter:(int)aChapter;

// Test level
- (BOOL)isLastChapter;
- (BOOL)isLastLevelInChapter;

// Level attributes (must go later to file
- (CGRect)boundsOfLevel;

// Reset scores and locks
- (void)reset;

// Dump level manager
- (void)dump;

// Get level manager
+ (LevelManager *)sharedManager;

@end
