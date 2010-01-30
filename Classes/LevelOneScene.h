
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer

enum  {
	ModeAlive = 1,
	ModeDead = 2,
	ModeCarrotCaught = 3
} typedef GameMode;

@interface LevelOne : CCLayer
{
	CCSprite *carrot;
	CCSprite *donkey;
	GameMode mode;
	NSDictionary *audioPlayerDict;
	float timeSinceAction;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
