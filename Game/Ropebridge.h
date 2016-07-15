//
//  Ropebridge.h
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "BodyNode.h"

@interface Ropebridge : BodyNode {
	int numberOfLinks_;
}

// Used to open "exit"
- (void)removeEndBody;

@end
