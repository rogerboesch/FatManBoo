//
//  HelpScene.h
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "SlidingMenuGrid.h"

@interface HelpScene : CCLayer <SlidingMenuGridDelegate> {
	CCLabelTTF *helpText_;
}

+ (id)scene;

@end
