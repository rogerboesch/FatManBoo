//
//  GameDelegate.mm
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "cocos2d.h"
#import "GameDelegate.h"
#import "IntroScene.h"
#import "RBGameKitViewController.h"
#import "LevelManager.h"
#import "GameConfiguration+Extension.h"
#import "RBSoundEngine.h"

@interface GameDelegate (Private)
- (void)initSounds;
@end

@implementation GameDelegate

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Enable/disable physics debug

+ (void)enablePhysicsDebug {
	NSNumber* value = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"RBPhysicsDebug"];
	if (value == nil) {
		[[GameConfiguration sharedConfiguration] setShowPhysics:NO];
		return;
	}
	
	if ([value boolValue]) {
		[[GameConfiguration sharedConfiguration] setShowPhysics:YES];
		return;
	}
	
	[[GameConfiguration sharedConfiguration] setShowPhysics:NO];
	return;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark GameKit methods

- (void)showAchievements {
	RBGameKitViewController *myController = [[RBGameKitViewController alloc] init];
	[[[CCDirector sharedDirector] view] addSubview:myController.view];
	
    myController.achievementViewController = [[[GKAchievementViewController alloc] init] autorelease];
    if (myController.achievementViewController != nil) {
        myController.achievementViewController.achievementDelegate = myController;
        [myController presentViewController:myController.achievementViewController animated:YES completion:NULL];
    }
}

// -----------------------------------------------------------------------------

- (void)showLeaderboard {
	RBGameKitViewController *myController = [[RBGameKitViewController alloc] init];
	[[[CCDirector sharedDirector] view] addSubview:myController.view];
	
    myController.leaderboardViewController = [[[GKLeaderboardViewController alloc] init] autorelease];
    if (myController.leaderboardViewController != nil) {
        myController.leaderboardViewController.leaderboardDelegate = myController;
        [myController presentViewController:myController.leaderboardViewController animated:YES completion:NULL];
    }
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Score reporting

- (void)performReportScore:(NSArray *)aList {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	NSString *category = [aList objectAtIndex:0];
	int score = [[aList objectAtIndex:1] intValue];
	
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
    scoreReporter.value = score;
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
		if (error != nil) {
			CCLOG(@"Error report score to gamekit");
		}
		else {
			CCLOG(@"Report score to GK for '%@': %d", category, score);
		}
    }];	
	
	[pool release];
}

// -----------------------------------------------------------------------------

- (void)reportScore:(int64_t)score forCategory:(NSString*)category {
	[self performSelectorInBackground:@selector(performReportScore:) withObject:[NSArray arrayWithObjects:category, [NSNumber numberWithInt:(int)score], nil]];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Achievment reporting

- (void)performReportAchievement:(NSString*)aIdentifier {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:aIdentifier];
	if (achievement) {
		achievement.percentComplete = 100.0;
		[achievement reportAchievementWithCompletionHandler:^(NSError *error) {
			if (error != nil) {
				if (error != nil) {
					CCLOG(@"Error report achievment '%@' to gamekit", aIdentifier);
				}
				else {
					CCLOG(@"Report achievement to GK for '%@'", aIdentifier);
				}
			}
		}];
    }
	
	[pool release];
}

// -----------------------------------------------------------------------------

- (void)reportAchievement:(NSString*)aIdentifier {
	[self performSelectorInBackground:@selector(performReportAchievement:) withObject:aIdentifier];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark GameCenter integration

- (void)authenticateLocalPlayer {
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
		if (error == nil) {
			CCLOG(@"Gamekit, authenticateLocalPlayer ok");
		}
		else {
			CCLOG(@"Gamekit, authenticateLocalPlayer FAILED");
		}
	}];
}

// -----------------------------------------------------------------------------

- (void)authenticationChanged {
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
		CCLOG(@"Gamekit, player is authenticated: %@", [GKLocalPlayer localPlayer].playerID);
	}
	else {
		CCLOG(@"Gamekit, player is NOT authenticated: %@", [GKLocalPlayer localPlayer].playerID);
	}
}

// -----------------------------------------------------------------------------

- (void)registerGameKitNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
}

// -----------------------------------------------------------------------------

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
	[viewController.view removeFromSuperview];
}

// -----------------------------------------------------------------------------

- (NSString *)username {
	return [GKLocalPlayer localPlayer].playerID;
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Preload sounds

- (void)initSounds {
	[[RBSoundEngine sharedEngine] preload];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Application life cycle

- (void)applicationDidFinishLaunching:(UIApplication*)application {
    //seed random number generator.
	srandom([[NSDate date] timeIntervalSince1970]);

	[super applicationDidFinishLaunching:application];

	// Enable/Disable physics
	[GameDelegate enablePhysicsDebug];

	// Init sounds
	[self initSounds];
	
	// Run
	[[CCDirector sharedDirector] runWithScene:[IntroScene scene]];
}

// -----------------------------------------------------------------------------

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

// -----------------------------------------------------------------------------

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

// -----------------------------------------------------------------------------

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

// -----------------------------------------------------------------------------

- (void)applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

// -----------------------------------------------------------------------------

- (void)applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

// -----------------------------------------------------------------------------

- (void)applicationWillTerminate:(UIApplication *)application {	
	[[CCDirector sharedDirector] end];
}

// -----------------------------------------------------------------------------

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

// -----------------------------------------------------------------------------

#pragma mark -
#pragma mark Memory allocation

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window_ release];
	[super dealloc];
}

// -----------------------------------------------------------------------------

@end
