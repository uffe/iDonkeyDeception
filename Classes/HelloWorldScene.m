//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "HelloWorldScene.h"
#import "Helper.h"

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
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
		
		donkey = [CCSprite spriteWithFile:@"DonkeySprite1.png"];
		donkey.position = DONKEY_INITIAL_POS;
		[self addChild:donkey];
		
		CCSprite *lawn = [CCSprite spriteWithFile:@"grasandfence.png"];
		lawn.position = ccp(480.0f/2, 150);
		[self addChild:lawn];

		
		
		// create and initialize a Label
		CCLabel* label = [CCLabel labelWithString:@"Trick the Donkey" fontName:@"Marker Felt" fontSize:14];

		// ask director the the window size

	
		// position the label on the center of the screen
		label.position =  ccp( 60, 300 );
		
		// add the label as a child to this Layer
		[self addChild: label];
	}
	return self;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
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
	#define DONKEY_CARROT_REACT_DISTANCE 50.0f
	#define DONKEY_VEL 40.0f
	#define FALL_DOWN_POS 345.0f
	#define DONKEY_EAT_DIST 5.0f
	
	float dcDist = carrot.position.x - donkey.position.x-donkey.contentSize.width/2;
	
	if (mode==ModeAlive) {	
		if (dcDist < DONKEY_EAT_DIST) {
			mode=ModeCarrotCaught;
			[[audioPlayerDict objectForKey:@"trombone"] play];
			[carrot runAction:[CCMoveTo actionWithDuration:1.0f position:CARROT_INITIAL_POS]];
			[donkey runAction:[CCMoveTo actionWithDuration:1.0f position:DONKEY_INITIAL_POS]];
//			[donkey runAction:[CCRotateTo actionWithDuration:1.0f angle:-471.0]];
			//TODO: when action done, set mode to alive
		} else if (donkey.position.x > FALL_DOWN_POS) {
			// donkey fall down
			[donkey runAction:[CCMoveTo actionWithDuration:1.0f position:ccp(380,10)]];
			[donkey runAction:[CCRotateTo actionWithDuration:0.7 angle:91.0]];
			mode=ModeDead;
			[[audioPlayerDict objectForKey:@"applause"] play];
		} else if (dcDist < DONKEY_CARROT_REACT_DISTANCE && dcDist > DONKEY_EAT_DIST) {
			//NSLog(@"Ticked! %f", dt);
			// move the donkey
			float moved = DONKEY_VEL*dt;
			donkey.position=ccp(donkey.position.x+moved, donkey.position.y);
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
