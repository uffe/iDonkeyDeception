//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "LevelOneScene.h"
//#import "Helper.h"
#import "LevelTwoScene.h"


// *** Trick The Donkey: Level 1 ***
//
// The donkey is placed on the left. On the right some leaved disguise a pit.
// At the bottom of the pit spikes are waiting to kill the donkey.
// The player must lure the donkey using the carrot and make it fall into the pit.

@implementation LevelOne

#define L1_CARROT_INITIAL_POS_X 263
#define L1_CARROT_INITIAL_POS_Y 290

#define L1_DONKEY_INITIAL_POS_X 40
#define L1_DONKEY_INITIAL_POS ccp(L1_DONKEY_INITIAL_POS_X, 190)
#define L1_DONKEY_MAX_X 1000
// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		[self setIsTouchEnabled:YES];

		// schedule game loop
		[self schedule: @selector(tick:)];
		// set initial game mode
		mode = ModeAlive;
		
		// add background
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
		background.position = ccp( size.width /2 , size.height/2 );
		[self addChild:background];
		
		// add carrot
		[self addChild:carrot];
		carrot_initial_pos_x = L1_CARROT_INITIAL_POS_X;
		carrot_initial_pos_y = L1_CARROT_INITIAL_POS_Y;
		carrot.position = ccp(carrot_initial_pos_x,carrot_initial_pos_y);
		
		// add donkey
		[self addChild:donkey];
		donkey.position = L1_DONKEY_INITIAL_POS;

		// background
		CCSprite *lawn = [CCSprite spriteWithFile:@"grassandfence.png"];
		lawn.position = ccp(480.0f/2-7.0, 97);
		[self addChild:lawn];
		
		}
	return self;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// only move carrot if in alive mode
	if (mode != ModeAlive) { return kEventHandled; }
	
	UITouch *touch = [touches anyObject];
	if (touch) {
		CGPoint location = [touch locationInView: [touch view]];
		
		// IMPORTANT:
		// The touches are always in "portrait" coordinates. You need to convert them to your current orientation
		CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:location];
		
		// update carrot position
		carrot.position = ccp(convertedPoint.x, carrot.position.y);
	}
	
	// we've handled the event
	return kEventHandled;
}

// level completed - go to next level
-(void) levelCompleted {
	[[CCDirector sharedDirector] pushScene: [CCSlideInRTransition transitionWithDuration:1 scene:[LevelTwo scene]]];	
}

// play sound of donkey hitting spikes
-(void)playSpike {
	//TODO
	[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"knife"] withObject:nil];
}

// game loop
-(void) tick: (ccTime) dt {
	[super tick:dt];
	#define FALL_DOWN_POS 345.0f
	
	// player is alive
	if (mode == ModeAlive) {	
		// carrot is close enough to donkey for donkey to eat it
		if (dcDist < DONKEY_EAT_DIST) {
			// switch game mode
			mode = ModeCarrotCaught;
			// play sound
			[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"trombone"] withObject:nil];
			// set carrot has been eaten image
			[carrot setDisplayFrame:@"carrot" index:1];
			// move carrot to initial position
			[carrot runAction:[[CCMoveTo alloc] initWithDuration:REVERT_TIME position:ccp(carrot_initial_pos_x,carrot_initial_pos_y)]];
			// counter for elapsed time since carrot was eaten
			timeSinceAction=0.0f;
		// donkey is over pit, so kill it
		} else if (donkey.position.x > FALL_DOWN_POS) {
			// animate donkey falling into pit
			[donkey runAction:[CCMoveTo actionWithDuration:1.0f position:ccp(375,10)]];
			[donkey runAction:[CCRotateTo actionWithDuration:0.7 angle:91.0]];
			// switch game mode
			mode = ModeDead;
			// play level completed sound
			[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"applause"] withObject:nil];
			// run level complete actions
			[self performSelector:@selector(levelCompleted) withObject:nil afterDelay:2];
			[self performSelector:@selector(playSpike) withObject:nil afterDelay:0.8];

		// carrot is close enough to lure donkey but far enough away to not be eaten
		} else if (dcDist < DONKEY_CARROT_REACT_DISTANCE && dcDist > DONKEY_EAT_DIST) {
			// update donkey position and animation
			float moved = DONKEY_VEL*dt + (DONKEY_CARROT_REACT_DISTANCE-dcDist)*dt*DONKEY_ACC;
			CGPoint newPos = ccp(donkey.position.x+moved, donkey.position.y);
			if (newPos.x < L1_DONKEY_MAX_X) {
				int donkey_walk_frame_index = newPos.x/DONKEY_FRAME_DX;
				[donkey setDisplayFrame:@"donkey_stretch" index:donkey_walk_frame_index%4];
				donkey.position = newPos;
			}
		// carrot is too far away from donkey
		} else {
			[donkey setDisplayFrame:@"donkey_neutral" index:0];
		}
	// donkey has eaten carrot
	} else if (mode == ModeCarrotCaught) {
		// show donkey eating animation for some time
		if (timeSinceAction < REVERT_TIME) {
			int donkey_eat_index = timeSinceAction*1000/DONKEY_CHEW_DT;
			[donkey setDisplayFrame:@"donkey_eat" index:donkey_eat_index%2];
		// reset level
		} else {
			mode = ModeReturning;
		}
	
	// reset level
	} else if (mode == ModeReturning) {
		// donkey is still moving towards initial position
		if (donkey.position.x>L1_DONKEY_INITIAL_POS_X) {
			float moved = DONKEY_VEL*dt + (30*dt*DONKEY_ACC);
			donkey.position=ccp(donkey.position.x-moved, donkey.position.y);
			int donkey_walk_frame_index = donkey.position.x/DONKEY_FRAME_DX;
			[donkey setDisplayFrame:@"donkey_neutral" index:donkey_walk_frame_index%4];
		// donkey is at initial position - switch to play game mode
		} else {
			mode = ModeAlive;
			[carrot setDisplayFrame:@"carrot" index:0];
		}
	}
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc {
	
	// don't forget to call "super dealloc"
	[super dealloc];
	[audioPlayerDict release];
}

@end
