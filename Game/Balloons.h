//
//  Ballons.h
//
//  Written by Roger Boesch on 10/01/10.
//  (C) Copyright 2010 rogerboesch.com. All rights reserved.
//

#import "BonusNode.h"

@interface Ballon : BonusNode {
	ccTime	elapsedTime_;
	b2World	*world_;	
}

- (id)initWithPosition:(CGPoint)aPosition game:(GameNode*)aGame speedY:(float)speedY heart:(BOOL)aHeart;

@end