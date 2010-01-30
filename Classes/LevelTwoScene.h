
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer

enum  {
	L2ModeAlive = 1,
	L2ModeDead = 2,
	L2ModeCarrotCaught = 3
} typedef LevelTwoMode;

@interface LevelTwo : CCLayer
{
	CCSprite *carrot;
	CCSprite *donkey;
	LevelTwoMode mode;
	NSDictionary *audioPlayerDict;
	float timeSinceAction;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
