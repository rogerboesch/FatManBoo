//
//  RBGameKitViewController.h
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import <GameKit/GameKit.h>

@interface RBGameKitViewController :UIViewController <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate> {
	GKLeaderboardViewController *leaderboardViewController_;
	GKAchievementViewController *achievementViewController_;
}

@property (nonatomic, readwrite, assign) GKLeaderboardViewController *leaderboardViewController;
@property (nonatomic, readwrite, assign) GKAchievementViewController *achievementViewController;

@end