//
//  LevelThreeScene.h
//  TrickTheDonkey
//
//  Created by Ole Gammelgaard Poulsen on 31/01/10.
//  Copyright 2010 OGP Consult. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LevelScene.h"

#define L3_BRIDGE_TILE_COUNT 12

@interface LevelThree : LevelScene {
	CCSprite *bridgeTile[L3_BRIDGE_TILE_COUNT];
}

@end
