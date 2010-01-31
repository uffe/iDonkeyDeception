
#import "LevelScene.h"

@interface IntroScene : CCLayer
{
	float timeSinceAction;
	int devil_anim_index;
	CCSprite *devil;
}
+(id) scene;
@end
