//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "LevelTwoScene.h"
#import "Helper.h"

// HelloWorld implementation
@implementation LevelTwo

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LevelTwo *layer = [LevelTwo node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

#define CARROT_INITIAL_POS ccp(400,260)
#define DONKEY_INITIAL_POS ccp(40, 180)
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
		CCSprite *background = [CCSprite spriteWithFile:@"background2.png"];
		background.position = ccp( size.width /2 , size.height/2 );
		[self addChild:background];
		[self setIsTouchEnabled:YES];
		[self schedule: @selector(tick:)];
		mode=L2ModeAlive;
		
		// add carrot
		carrot = [CCSprite spriteWithFile:@"Carrot_alt1.png"];
		carrot.position = CARROT_INITIAL_POS;
		[self addChild:carrot];
		
		CCAnimation *an = [CCAnimation animationWithName:@"carrot" delay:0];
		[an addFrameWithFilename:@"Carrot_alt1.png"];
		[an addFrameWithFilename:@"Carrot_alt1_gone.png"];
		[carrot addAnimation:an];
		
		donkey = [CCSprite spriteWithFile:@"DonkeySprite1.png"];
		donkey.position = DONKEY_INITIAL_POS;
		[self addChild:donkey];
		
		CCSprite *water = [CCSprite spriteWithFile:@"vand.png"];
		water.position = ccp(480.0f/2+230, 10);
		[self addChild:water];
		[water runAction:[CCWaves3D actionWithWaves:100000 amplitude:40.0 grid:ccg(20,20) duration:200000]];
		
		CCSprite *foreground = [CCSprite spriteWithFile:@"bane-2-forgrund.png"];
		foreground.position = ccp(70, 120);
		[self addChild:foreground];
		

		
		}
	return self;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (mode!=L2ModeAlive)
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

-(void) tick: (ccTime) dt {

	#define DONKEY_CARROT_REACT_DISTANCE 70.0f
	#define DONKEY_VEL 5.0f
	#define DONKEY_ACC 3.0;
	#define FALL_DOWN_POS 345.0f
	#define DONKEY_EAT_DIST 5.0f
	#define REVERT_TIME 1.0f

	
	float dcDist = carrot.position.x - donkey.position.x-donkey.contentSize.width/2;
	timeSinceAction += dt;
	if (mode==L2ModeAlive) {	
		if (dcDist < DONKEY_EAT_DIST) {
			mode=L2ModeCarrotCaught;
			[[audioPlayerDict objectForKey:@"trombone"] play];
			
			[carrot setDisplayFrame:@"carrot" index:1];
			
			[carrot runAction:[[CCMoveTo alloc] initWithDuration:REVERT_TIME position:CARROT_INITIAL_POS]];
			[donkey runAction:[CCMoveTo actionWithDuration:REVERT_TIME position:DONKEY_INITIAL_POS]];
			timeSinceAction=0.0f;
		} else if (donkey.position.x > FALL_DOWN_POS) {
			// donkey fall down
			
			[donkey runAction:[CCMoveTo actionWithDuration:1.0f position:ccp(375,10)]];
			[donkey runAction:[CCRotateTo actionWithDuration:0.7 angle:91.0]];
			mode=L2ModeDead;
			[[audioPlayerDict objectForKey:@"applause"] play];
		} else if (dcDist < DONKEY_CARROT_REACT_DISTANCE && dcDist > DONKEY_EAT_DIST) {
			//NSLog(@"Ticked! %f", dt);
			// move the donkey
			float moved = DONKEY_VEL*dt + (DONKEY_CARROT_REACT_DISTANCE-dcDist)*dt*DONKEY_ACC;
			donkey.position=ccp(donkey.position.x+moved, donkey.position.y);
		}
	} else if (mode==L2ModeCarrotCaught) {
		if (timeSinceAction > REVERT_TIME) {
			mode=L2ModeAlive;
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
