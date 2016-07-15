//
//  Spikeball.h
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "BodyNode.h"

@interface Spikeball : BodyNode {
	BOOL touched_;
	int autorepeat_;
	int lifeTime_;
	b2Vec2 startPosition_;
}

@property (nonatomic, assign) int lifeTime;

- (void)touchedByHero;

- (id)initWithPosition:(b2Vec2)position game:(GameNode*)game;

@end
