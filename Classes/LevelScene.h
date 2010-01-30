//
//  LevelScene.h
//  TrickTheDonkey
//
//  Created by Martin on 30/1/10.
//  Copyright 2010 Identified Object. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Helper.h"

enum  {
	ModeAlive = 1,
	ModeDead = 2,
	ModeCarrotCaught = 3,
	ModeReturning = 4,
	ModeFishEatingDonkey = 100
} typedef LevelMode;

@interface LevelScene : CCLayer {
	CCSprite *carrot;
	CCSprite *donkey;
	LevelMode mode;
	NSDictionary *audioPlayerDict;
	float timeSinceAction;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end

