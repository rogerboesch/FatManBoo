//
//  Rope.h
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "BodyNode.h"

@interface Rope : BodyNode {
	int numberOfLinks_;
}

- (id)initWithBody:(b2Body*)body game:(GameNode*)game numberOfLinks:(int)aNumber;

@end
