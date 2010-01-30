//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "LevelOneScene.h"
#import "Helper.h"
#import "LevelTwoScene.h"

// HelloWorld implementation
@implementation LevelOne

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LevelOne *layer = [LevelOne node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

#define CARROT_INITIAL_POS ccp(400,290)
#define DONKEY_INITIAL_POS ccp(40, 190)
// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		audioPlayerDict = [[NSDictionary dictionaryWithObjectsAndKeys:
							[Helper prepAudio:@"applause"],@"applause",
							[Helper prepAudio:@"trombone"],@"trombone",
							nil] retain];
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		// addbackground
		CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
		background.position = ccp( size.width /2 , size.height/2 );
		[self addChild:background];
		[self setIsTouchEnabled:YES];
		[self schedule: @selector(tick:)];
		mode=ModeAlive;
		
		// add carrot
		carrot = [CCSprite spriteWithFile:@"carrot.png"];
		carrot.position = CARROT_INITIAL_POS;
		[self addChild:carrot];
		
		CCAnimation *an = [CCAnimation animationWithName:@"carrot" delay:0];
		[an addFrameWithFilename:@"carrot.png"];
		[an addFrameWithFilename:@"carrotgone.png"];
		[carrot addAnimation:an];
		
		// Add donkey and its animations
		donkey = [CCSprite spriteWithFile:@"Donkey_neutral.png"];
		donkey.position = DONKEY_INITIAL_POS;
		[self addChild:donkey];
		
		CCAnimation *donkey_walk_animation = [CCAnimation animationWithName:@"donkey_walk" delay:0];
		[donkey_walk_animation addFrameWithFilename:@"Donkey_stretch_neutral.png"];
		[donkey_walk_animation addFrameWithFilename:@"Donkey_stretch_left_front.png"];
		[donkey_walk_animation addFrameWithFilename:@"Donkey_stretch_neutral.png"];
		[donkey_walk_animation addFrameWithFilename:@"Donkey_stretch_right_front.png"];
		[donkey addAnimation:donkey_walk_animation];
		donkey_walk_frame_index = 0;

		CCAnimation *donkey_eat_animation = [CCAnimation animationWithName:@"donkey_eat" delay:0];
		[donkey_eat_animation addFrameWithFilename:@"Donkey_eating_state1.png"];
		[donkey_eat_animation addFrameWithFilename:@"Donkey_eating_state2.png"];
		[donkey addAnimation:donkey_eat_animation];
		
		CCAnimation *donkey_neutral_animation = [CCAnimation animationWithName:@"donkey_neutral" delay:0];
		[donkey_neutral_animation addFrameWithFilename:@"Donkey_neutral.png"];
		[donkey addAnimation:donkey_neutral_animation];
		
		// background
		CCSprite *lawn = [CCSprite spriteWithFile:@"grassandfence.png"];
		lawn.position = ccp(480.0f/2-7.0, 97);
		[self addChild:lawn];
		
		}
	return self;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (mode!=ModeAlive)
		return kEventHandled;
	UITouch *touch = [touches anyObject];
	if (touch) {
		CGPoint location = [touch locationInView: [touch view]];
		
		// IMPORTANT:
		// The touches are always in "portrait" coordinates. You need to convert them to your current orientation
		CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:location];
		
		// we stop the all running actions
		[carrot stopAllActions];
		
		// and we run a new action
		
		carrot.position = ccp(convertedPoint.x, carrot.position.y);
		//[carrot runAction: [CCMoveTo actionWithDuration:0.1 position: ccp(convertedPoint.x, carrot.position.y)]];
		
		// no other handlers will receive this event
		return kEventHandled;
	}
	
	// we ignore the event. Other receivers will receive this event.
	return kEventHandled;
	
}

-(void) levelCompleted{
	[[CCDirector sharedDirector] pushScene: [CCSlideInRTransition transitionWithDuration:1 scene:[LevelTwo scene]]];	
}

-(void) tick: (ccTime) dt {

	#define DONKEY_CARROT_REACT_DISTANCE 70.0f
	#define DONKEY_VEL 5.0f
	#define DONKEY_ACC 3.0f
	#define FALL_DOWN_POS 345.0f
	#define DONKEY_EAT_DIST 5.0f
	#define REVERT_TIME 1.0f

	
	float dcDist = carrot.position.x - donkey.position.x-donkey.contentSize.width/2;
	timeSinceAction += dt;
	if (mode==ModeAlive) {	
		if (dcDist < DONKEY_EAT_DIST) {
			mode=ModeCarrotCaught;
			[[audioPlayerDict objectForKey:@"trombone"] play];
			
			[carrot setDisplayFrame:@"carrot" index:1];
			
			[carrot runAction:[[CCMoveTo alloc] initWithDuration:REVERT_TIME position:CARROT_INITIAL_POS]];
			[donkey runAction:[CCMoveTo actionWithDuration:REVERT_TIME position:DONKEY_INITIAL_POS]];
			timeSinceAction=0.0f;
		} else if (donkey.position.x > FALL_DOWN_POS) {
			// donkey fall down
			
			[donkey runAction:[CCMoveTo actionWithDuration:1.0f position:ccp(375,10)]];
			[donkey runAction:[CCRotateTo actionWithDuration:0.7 angle:91.0]];
			mode=ModeDead;
			[[audioPlayerDict objectForKey:@"applause"] play];

			[self performSelector:@selector(levelCompleted) withObject:nil afterDelay:2];

		} else if (dcDist < DONKEY_CARROT_REACT_DISTANCE && dcDist > DONKEY_EAT_DIST) {
			//NSLog(@"Ticked! %f", dt);
			// move the donkey
			float moved = DONKEY_VEL*dt + (DONKEY_CARROT_REACT_DISTANCE-dcDist)*dt*DONKEY_ACC;
			donkey.position=ccp(donkey.position.x+moved, donkey.position.y);
			donkey_walk_frame_index = donkey.position.x/10;
			[donkey setDisplayFrame:@"donkey_walk" index:donkey_walk_frame_index%4];
		} else {
			[donkey setDisplayFrame:@"donkey_neutral" index:0];
		}
	} else if (mode==ModeCarrotCaught) {
		if (timeSinceAction > REVERT_TIME) {
			mode=ModeAlive;
			[carrot setDisplayFrame:@"carrot" index:0];
		}
	}	
}




// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
	[audioPlayerDict release];
}
@end
