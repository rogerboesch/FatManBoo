//
//  RBGameKitViewController.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "RBGameKitViewController.h"

@implementation RBGameKitViewController

@synthesize leaderboardViewController = leaderboardViewController_;
@synthesize achievementViewController = achievementViewController_;

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark leaderboard delegate

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
	[self dismissViewControllerAnimated:YES completion:NULL];
	[self.view removeFromSuperview];
	[self release];
}

// -----------------------------------------------------------------------------

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
	[self dismissViewControllerAnimated:YES completion:NULL];
	[self.view removeFromSuperview];
	[self release];
}

// -----------------------------------------------------------------------------

@end