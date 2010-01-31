//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "IntroScene.h"
#import "LevelOneScene.h"
#

// HelloWorld implementation
@implementation IntroScene

- (void)setLastFrame{
	[devil setDisplayFrame:@"devil" index:22];
	CCSprite *rope_extension = [CCSprite spriteWithFile:@"rope.png"];
	rope_extension.position = ccp(265,17);
	[self addChild:rope_extension];
}

- (void)levelCompleted{
	[[CCDirector sharedDirector] pushScene: [CCSlideInBTransition transitionWithDuration:1 scene:[LevelOne scene]]];	
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		// addbackground
		CGSize size = [[CCDirector sharedDirector] winSize];		
		CCSprite *background = [CCSprite spriteWithFile:@"background_prequel.png"];
		background.position = ccp( size.width /2 , size.height/2 );
		[self addChild:background];
		
		// add devil
		devil = [CCSprite spriteWithFile:@"Start.png"];
		devil.position = ccp(300,100);
		CCAnimation *da = [CCAnimation animationWithName:@"devil" delay:0.3f];
		[da addFrameWithFilename:@"Start.png"];
		[da addFrameWithFilename:@"02_hand_movement.png"];
		[da addFrameWithFilename:@"03_hand_movement.png"];
		[da addFrameWithFilename:@"04_hand_movement.png"];
		[da addFrameWithFilename:@"05_laugh.png"];
		[da addFrameWithFilename:@"06_laugh.png"];
		[da addFrameWithFilename:@"07_laugh.png"];
		[da addFrameWithFilename:@"08_laugh.png"];
		[da addFrameWithFilename:@"09_movement.png"];
		[da addFrameWithFilename:@"10_movement.png"];
		[da addFrameWithFilename:@"11_pause.png"];
		[da addFrameWithFilename:@"12_wink.png"];
		[da addFrameWithFilename:@"13_unwink.png"];
		[da addFrameWithFilename:@"14_movement.png"];
		[da addFrameWithFilename:@"15_grab.png"];
		[da addFrameWithFilename:@"16_pole.png"];
		[da addFrameWithFilename:@"17_pole.png"];
		[da addFrameWithFilename:@"18_fishing.png"];
		[da addFrameWithFilename:@"19_fishing.png"];
		[da addFrameWithFilename:@"20_fishing.png"];
		[da addFrameWithFilename:@"21_fishing.png"];
		[da addFrameWithFilename:@"22_fishing.png"];
		[da addFrameWithFilename:@"End.png"];
		[devil addAnimation:da];
		
		id actionDelay = [CCDelayTime actionWithDuration:2];
		id actionAnim = [CCAnimate actionWithAnimation:da];
		id actionCallFunc = [CCCallFunc actionWithTarget:self selector:@selector(levelCompleted)];
		id actionLastFrame = [CCCallFunc actionWithTarget:self selector:@selector(setLastFrame)];
		id actionSequence = [CCSequence actions: actionDelay, actionAnim, actionLastFrame, actionDelay, actionCallFunc, nil];
		[devil runAction:actionSequence];
		
		[self addChild:devil];

		}
	return self;
}

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LevelScene *layer = [[self class] node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
//	[audioPlayerDict release];
}
@end
