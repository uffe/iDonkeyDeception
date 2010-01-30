
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer

enum  {
	ModeAlive = 1,
	ModeDead = 2,
	ModeCarrotCaught = 3,
	ModeReturning = 4
} typedef LevelOneMode;

@interface LevelOne : CCLayer
{
	CCSprite *carrot;
	CCSprite *donkey;
	LevelOneMode mode;
	NSDictionary *audioPlayerDict;
	int donkey_walk_frame_index;
	float timeSinceAction;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
