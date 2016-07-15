//
//  Tnt.h
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "BodyNode.h"

@interface Tnt : BodyNode {
	BOOL touched_;
	id particleSystem_;
	BOOL implosion_;
	float force_;
}

@end
