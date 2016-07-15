//
//  Iceblock.h
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "BodyNode.h"

@interface Iceblock : BodyNode {
	BOOL touched_;
}

- (void)touchedByHero;

@end
