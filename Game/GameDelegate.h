//
//  GameDelegate.h
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "AppDelegate.h"
#import "Level.h"

// Gamekit categories for leaderboard
#define LEADERBOARD_DEFAULT @"fatmanboo.leaderboard.default" 

// Gamekit achievements
#define ACHIEVEMENT_CHAPTER_COMPLETED @"fatmanboo.achievement.chapter%d" 
#define ACHIEVEMENT_BONUS_COMPLETED @"fatmanboo.achievement.bonuschapter%d" 

@interface GameDelegate : AppDelegate {
}

// GameCenter support
- (void)authenticateLocalPlayer;
- (void)showLeaderboard;
- (void)showAchievements;
- (void)reportScore:(int64_t)score forCategory:(NSString*)category;
- (void)reportAchievement:(NSString*)aIdentifier;

// GameKit support
- (NSString *)username;

@end
