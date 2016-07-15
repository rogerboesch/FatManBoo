//
//  Island.h
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "BodyNode.h"

enum {
	kPlatformDirectionHorizontal,
	kPlatformDirectionVertical,
};

@interface Island : BodyNode {
	int direction_;
	float duration_;
	float translationInPixels_;
	b2Vec2 origPosition_;
	b2Vec2 finalPosition_;
	b2Vec2 velocity_;
	BOOL goingForward_;
}

@end
