//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "EndScene.h"

// HelloWorld implementation
@implementation EndScene


#define L1_DONKEY_INITIAL_POS_X 40
#define L1_DONKEY_INITIAL_POS ccp(L1_DONKEY_INITIAL_POS_X, 190)
#define L1_DONKEY_MAX_X 1000
// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		// addbackground
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"endbackground.png"];
		background.position = ccp( size.width /2 , size.height/2 );
		[self addChild:background];
		[self setIsTouchEnabled:YES];
		[self schedule: @selector(tick:)];
		mode=ModeAlive;
		

		
		// add donkey
		//[self addChild:donkey];
		//donkey.position = L1_DONKEY_INITIAL_POS;

		
	}
	return self;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (mode!=ModeAlive)
		return kEventHandled;
	UITouch *touch = [touches anyObject];
	if (touch) {
		CGPoint location = [touch locationInView: [touch view]];

		return kEventHandled;
	}
	
	// we ignore the event. Other receivers will receive this event.
	return kEventHandled;
	
}


-(void)playSpike {
	NSLog(@"playSpike");
	//TODO
	[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"knife"] withObject:nil];
}


-(void) tick: (ccTime) dt {
//	[super tick:dt];
}



// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[super dealloc];
	[audioPlayerDict release];
}
@end
