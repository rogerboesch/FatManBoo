//
//  Babyboo.h
//
//  Created by Roger Boesch on 10/30/10.
//  Copyright 2010 Art & Bits. All rights reserved.
//

#import "BonusNode.h"

@interface Babyboo : BonusNode {
	BOOL follows_;
	BOOL remove_;
}

@property (nonatomic, assign) BOOL follows;

- (void)setIdle;
- (void)animate;

@end