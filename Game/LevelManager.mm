//
//  LevelManager.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "LevelManager.h"
#import "cocos2d.h"

static LevelManager *_sharedLevelManager;

@implementation LevelManager

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Level managment

- (int)currentChapter {
	return chapter_;
}

// -----------------------------------------------------------------------------

- (int)currentLevel {
	return level_;
}

// -----------------------------------------------------------------------------

- (int)currentLevelNumber {
	int chapter = [[LevelManager sharedManager] currentChapter];
	int level = [[LevelManager sharedManager] currentLevel];
	int number = (chapter - 1) * NUMBER_OF_LEVELS_IN_CHAPTER + level;

	return number;
}

// -----------------------------------------------------------------------------

- (void)setLevel:(int)aLevel inChapter:(int)aChapter {	
	chapter_ = aChapter;
	NSString *myKey = [NSString stringWithFormat:@"currentchapter"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:aChapter] forKey:myKey];

	level_ = aLevel;
	myKey = [NSString stringWithFormat:@"currentlevel"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:aLevel] forKey:myKey];

	[[NSUserDefaults standardUserDefaults] synchronize];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Level locking

- (void)unlockChapter:(int)aChapter {
	NSString *myKey = [NSString stringWithFormat:@"chapterunlocked-%d", aChapter];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:myKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

// -----------------------------------------------------------------------------

- (void)unlockNextChapter {
	[self unlockChapter:chapter_+1];
	[self unlockLevel:1 chapter:chapter_+1];
}

// -----------------------------------------------------------------------------

- (BOOL)isChapterUnlocked:(int)aChapter {
	NSString *myKey = [NSString stringWithFormat:@"chapterunlocked-%d", aChapter];
	NSNumber *myNumber = [[NSUserDefaults standardUserDefaults] objectForKey:myKey];
	if (myNumber == nil) {
		return NO;
	}
	
	if ([myNumber intValue] == 1) {
		return YES;
	}
	
	return NO;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Level locking

- (void)unlockLevel:(int)aLevel chapter:(int)aChapter {
	NSString *myKey = [NSString stringWithFormat:@"levelunlocked-%d-%d", aChapter, aLevel];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:myKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

// -----------------------------------------------------------------------------

- (void)unlockNextLevel {
	[self unlockLevel:level_+1 chapter:chapter_];
}

// -----------------------------------------------------------------------------

- (BOOL)isLevelUnlocked:(int)aLevel chapter:(int)aChapter {
	NSString *myKey = [NSString stringWithFormat:@"levelunlocked-%d-%d", aChapter, aLevel];
	NSNumber *myNumber = [[NSUserDefaults standardUserDefaults] objectForKey:myKey];
	if (myNumber == nil) {
		return NO;
	}
	
	if ([myNumber intValue] == 1) {
		return YES;
	}
	
	return NO;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Highscore

- (int)highscoreOfLevel:(int)aLevel chapter:(int)aChapter {
	NSString *myKey = [NSString stringWithFormat:@"highscore-%d-%d", aChapter, aLevel];
	NSNumber *myNumber = [[NSUserDefaults standardUserDefaults] objectForKey:myKey];
	if (myNumber == nil) {
		return 0;
	}
	
	return [myNumber intValue];
}

// -----------------------------------------------------------------------------

- (int)currentHighscore {
	return [self highscoreOfLevel:level_ chapter:chapter_];
}

// -----------------------------------------------------------------------------

- (void)setCurrentScore:(int)aScore {
	int highscore = [self currentHighscore];
	if (aScore > highscore) {
		NSString *myKey = [NSString stringWithFormat:@"highscore-%d-%d", chapter_, level_];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:aScore] forKey:myKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Bonus level

- (int)bonusOfLevel:(int)aLevel chapter:(int)aChapter {
	NSString *myKey = [NSString stringWithFormat:@"bonuslevel-%d-%d", aChapter, aLevel];
	NSNumber *myNumber = [[NSUserDefaults standardUserDefaults] objectForKey:myKey];
	if (myNumber == nil) {
		return 0;
	}
	
	return [myNumber intValue];
}

// -----------------------------------------------------------------------------

- (int)currentBonusLevel {
	return [self bonusOfLevel:level_ chapter:chapter_];
}

// -----------------------------------------------------------------------------

- (void)setBonusLevel:(int)aBonusLevel {
	int bonusLevel = [self currentBonusLevel];
	if (aBonusLevel > bonusLevel) {
		NSString *myKey = [NSString stringWithFormat:@"bonuslevel-%d-%d", chapter_, level_];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:aBonusLevel] forKey:myKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Level text

- (NSString *)currentLevelChapter {
	return [NSString stringWithFormat:@"%d-%d", chapter_, level_];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Test level stage

- (BOOL)isLastChapter {
	if (chapter_ == NUMBER_OF_CHAPTERS) {
		return YES;
	}
	
	return NO;
}

// -----------------------------------------------------------------------------

- (BOOL)isLastLevelInChapter {
	if (level_ == NUMBER_OF_LEVELS_IN_CHAPTER) {
		return YES;
	}
	
	return NO;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Level bounds (deprecated, standard size used in Level.mm)

- (CGRect)boundsOfLevel {
	if ([self currentChapter] == 1) {
		switch ([self currentLevel]) {
			case 1:
				return CGRectMake(0, 0, 1968, 511);
			case 2:
				return CGRectMake(0, 0, 948, 511);
			case 3:
				return CGRectMake(0, 0, 1188, 511);
			case 4:
				return CGRectMake(0, 0, 1410, 628);
			case 5:
				return CGRectMake(0, 0, 1362, 628);
			case 6:
				return CGRectMake(0, 0, 1800, 1800);
			case 7:
				return CGRectMake(0, 0, 1360, 787);
			case 8:
				return CGRectMake(0, 0, 1360, 693);
			case 9:
				return CGRectMake(0, 0, 1720, 722);
			case 10:
				return CGRectMake(0, 0, 2160, 715);
			case 11:
				return CGRectMake(0, 0, 4800, 600);
		}
	}

	CCLOG(@"Level bounds NOT defined");
	return CGRectMake(0, 0, 1360, 600);	
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Reset

- (void)reset {
	// Reset all
	for (int chapter = 1; chapter <= NUMBER_OF_CHAPTERS; chapter++) {
		NSString *myKey = [NSString stringWithFormat:@"chapterunlocked-%d", chapter];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:myKey];
		
		for (int level = 1; level <= NUMBER_OF_LEVELS_IN_CHAPTER; level++) {
			NSString *myKey = [NSString stringWithFormat:@"levelunlocked-%d-%d", chapter, level];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:myKey];
			
			myKey = [NSString stringWithFormat:@"highscore-%d-%d", chapter, level];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:myKey];

			myKey = [NSString stringWithFormat:@"bonuslevel-%d-%d", chapter, level];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:myKey];
		}
	}	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// First chapter and level is always unlocked
	[self unlockChapter:1];
	[self unlockLevel:1 chapter:1];
	
	// Reset to first level in chapter 1
	[self setLevel:1 inChapter:1];
}

// -----------------------------------------------------------------------------

- (void)enableAll {
	for (int chapter = 1; chapter <= NUMBER_OF_CHAPTERS; chapter++) {
		NSString *myKey = [NSString stringWithFormat:@"chapterunlocked-%d", chapter];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:myKey];
		
		for (int level = 1; level <= NUMBER_OF_LEVELS_IN_CHAPTER; level++) {
			NSString *myKey = [NSString stringWithFormat:@"levelunlocked-%d-%d", chapter, level];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:myKey];

			myKey = [NSString stringWithFormat:@"bonuslevel-%d-%d", chapter, level];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:BONUS_MAXIMUM] forKey:myKey];
		}
	}	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

// -----------------------------------------------------------------------------

- (void)enableChapter:(int)aChapter {
	NSString *myKey = [NSString stringWithFormat:@"chapterunlocked-%d", aChapter];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:myKey];
		
	for (int level = 1; level < NUMBER_OF_LEVELS_IN_CHAPTER; level++) {
		NSString *myKey = [NSString stringWithFormat:@"levelunlocked-%d-%d", aChapter, level];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:myKey];
	}

	[[NSUserDefaults standardUserDefaults] synchronize];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Dump

- (void)dump {
	for (int chapter = 1; chapter <= NUMBER_OF_CHAPTERS; chapter++) {
		if (chapter_ == chapter) {
			printf(">");
		}
		printf("Chapter %d (Unlock:%d)\n", chapter, [self isChapterUnlocked:chapter]);
		
		for (int level = 1; level <= NUMBER_OF_LEVELS_IN_CHAPTER; level++) {
			if ((chapter_ == chapter) && (level_ == level)) {
				printf(">");
			}
			printf("-Level %d (Unlock:%d) = %d (Bonus: %d)\n", level, [self isLevelUnlocked:level chapter:chapter], [self highscoreOfLevel:level chapter:chapter], [self bonusOfLevel:level chapter:chapter]);
		}
		printf("\n");
	}
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Singleton stuff

+ (LevelManager *)sharedManager {
	@synchronized([LevelManager class]) {
		if (!_sharedLevelManager)
			[[self alloc] init];
		return _sharedLevelManager;
	}

	return nil;
}

// -----------------------------------------------------------------------------

+ (id)alloc {
	@synchronized([LevelManager class]) {
		NSAssert(_sharedLevelManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedLevelManager = [super alloc];
		return _sharedLevelManager;
	}	
	
	return nil;
}

// -----------------------------------------------------------------------------

- (id)init {
	if ((self=[super init]) ) {
		// First chapter and level is always unlocked
		[self unlockChapter:1];
		[self unlockLevel:1 chapter:1];

		// Go to level
		[self setLevel:1 inChapter:1];
		
		// Enable all (TODO: Remove later)
#ifdef RB_DEBUG
		[self reset];
		[self enableAll];
		//[self enableChapter:1];
		//[self enableChapter:2];
		//[self dump];
#endif
		
		NSString *myKey = [NSString stringWithFormat:@"currentchapter"];
		NSNumber *myNumber = [[NSUserDefaults standardUserDefaults] objectForKey:myKey];
		if (myNumber != nil) {
			chapter_ = [myNumber intValue];
		}
		
		myKey = [NSString stringWithFormat:@"currentlevel"];
		myNumber = [[NSUserDefaults standardUserDefaults] objectForKey:myKey];
		if (myNumber != nil) {
			level_ = [myNumber intValue];
		}	
	}

	return self;
}

// -----------------------------------------------------------------------------

@end
