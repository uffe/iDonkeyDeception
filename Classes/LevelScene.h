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

#define DONKEY_CHEW_DT 150.0f	// milliseconds between chew animation frame updates
#define DONKEY_FRAME_DX 8		// pixels between walk animation frame updates
#define DONKEY_CARROT_REACT_DISTANCE 70.0f
#define DONKEY_VEL 5.0f
#define DONKEY_ACC 3.0f
#define DONKEY_EAT_DIST 5.0f
#define REVERT_TIME 1.0f

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
	float dcDist;
	
	float donkey_initial_pos_x;
	float donkey_initial_pos_y;
	float carrot_initial_pos_x;
	float carrot_initial_pos_y;
}

-(void) tick: (ccTime) dt;

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end

