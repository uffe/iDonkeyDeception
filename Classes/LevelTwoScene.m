//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "LevelTwoScene.h"
#import "LevelThreeScene.h"

// *** Trick The Donkey: Level 2 ***
//
// The donkey is placed on land to the left of some water
// The donkey will follow the carrot to the water, but won't fall in
// Holding the carrot on the right side of of the water, a fish appears
// Lure the fish towards the donkey using the carrot
// When the fish is close enough, it will jump out of the water and eat the donkey

@implementation LevelTwo

#define L2_CARROT_INITIAL_POS_X 200
#define L2_CARROT_INITIAL_POS_Y 290

#define L2_DONKEY_INITIAL_POS_X 40
#define L2_DONKEY_INITIAL_POS ccp(L2_DONKEY_INITIAL_POS_X, 192)
#define FISH_INITIAL_POS ccp(400, 30)
#define FISH_SECOND_POS ccp(370, 80)
#define FISH_MIN_X 115
#define FISH_MAX_X 380
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
		CCSprite *background = [CCSprite spriteWithFile:@"background2.png"];
		background.position = ccp( size.width /2, size.height/2 );
		[self addChild:background];

		// add carrot
		[self addChild:carrot];
		carrot_initial_pos_x = L2_CARROT_INITIAL_POS_X;
		carrot_initial_pos_y = L2_CARROT_INITIAL_POS_Y;
		carrot.position = ccp(carrot_initial_pos_x,carrot_initial_pos_y);
		
		// add donkey
		[self addChild:donkey];
		donkey.position = L2_DONKEY_INITIAL_POS;
		
		// add fish
		fish = [CCSprite spriteWithFile:@"fishclosed.png"];
		fish.scaleX = 0.5f;
		fish.scaleY = 0.5f;
//		fish.position = FISH_INITIAL_POS;
		fish.position = FISH_SECOND_POS;
		fish.opacity = 0.0f;
		[self addChild:fish];
//		[fish runAction:[CCMoveTo actionWithDuration:5 position:FISH_SECOND_POS]];
		timeSinceFishFlipped = -2;
		// setup fish animation frames
		CCAnimation *fan = [CCAnimation animationWithName:@"fish" delay:0];
		[fan addFrameWithFilename:@"fishclosed.png"];
		[fan addFrameWithFilename:@"fish.png"];
		[fish addAnimation:fan];

		CCSprite *barrel = [CCSprite spriteWithFile:@"Nuclear_waste_barrel_80x80.png"];
		barrel.position = ccp(300,45);
		[self addChild:barrel];

		CCSprite *water = [CCSprite spriteWithFile:@"vand.png"];
		water.position = ccp(480.0f/2+130, 140);

		[self addChild:water];
		[water runAction:[CCWaves3D actionWithWaves:100000 amplitude:40.0 grid:ccg(10,10) duration:200000]];
		
		CCSprite *foreground = [CCSprite spriteWithFile:@"bane-2-forgrund.png"];
		foreground.position = ccp(275, 125);
		[self addChild:foreground];

		// play beach song
		[[audioPlayerDict objectForKey:@"thebeech"] setVolume:0.1];
		[[audioPlayerDict objectForKey:@"thebeech"] play];
		
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

// game loop
-(void) tick: (ccTime) dt {
	[super tick:dt];
	#define FISH_EAT_DONKEY_DIST 50.0f
	#define L2_DONKEY_MAX_X 120.0f
	#define FISH_CARROT_REACT_DISTANCE 70.0f
	#define FISH_VEL 30.0f
	
	// calculate distance between donkey-fish and fish-carrot
	float dfDist = fish.position.x - donkey.position.x-donkey.contentSize.width/2;
	float fcDist = carrot.position.x - fish.position.x;
	// player is alive
	if (mode == ModeAlive) {	
		// fish is close enough to donkey to eat it
		if (dfDist < FISH_EAT_DONKEY_DIST) {
			// switch game mode
			mode = ModeFishEatingDonkey;
			// show fish eating donkey animation
			[fish setDisplayFrame:@"fish" index:1];
			fish.flipX = NO;
			[fish runAction:[CCRotateTo actionWithDuration:1.0f angle:-91.0]];
			[fish runAction:[CCJumpTo actionWithDuration:1.0f position:donkey.position height:150 jumps:1]];
			[fish runAction:[CCScaleBy actionWithDuration:1.0f scale:1.5f]];
			// complete level after fish has eaten donkey
			[self performSelector:@selector(levelCompleted) withObject:nil afterDelay:3.0f];
			[self performSelector:@selector(playKnifeSound) withObject:nil afterDelay:0.9f];

		}
		
		// carrot is within reaction distance of fish
		if (abs(fcDist) < FISH_CARROT_REACT_DISTANCE) {
			float moved;
			// fish is not visible
			if (fish.opacity == 0.0f) {
				// fish is hidden
				// show fish if carrot has been static for long enough
				if (timeSinceFishFlipped > 1) {
					[fish runAction:[CCFadeIn actionWithDuration:1.0f]];
				} else {
					timeSinceFishFlipped += dt;					
				}
			// fish is visible
			} else {
				// move the fish left or right
				if (fcDist > 0){
					moved = FISH_VEL*dt;
					if (!fishFlipped)
						timeSinceFishFlipped = 0;
					fishFlipped = YES;
				} else {
					moved = -FISH_VEL*dt;
					if (fishFlipped)
						timeSinceFishFlipped = 0;
					fishFlipped = NO;
				} 				
			}
			// update fish position and orientation
			fish.flipX = fishFlipped;
			if (fish.position.x+moved > FISH_MIN_X && fish.position.x+moved < FISH_MAX_X) {
				fish.position=ccp(fish.position.x+moved, fish.position.y);
			}
		}
		
		// carrot is within eating range of donkey
		if (dcDist < DONKEY_EAT_DIST) {
			// switch game mode
			mode = ModeCarrotCaught;
			// play "you lost" sound
			[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"trombone"] withObject:nil];
			// show carrot has been eaten image
			[carrot setDisplayFrame:@"carrot" index:1];
			// move carrot back to initial position
			[carrot runAction:[[CCMoveTo alloc] initWithDuration:REVERT_TIME position:ccp(carrot_initial_pos_x,carrot_initial_pos_y)]];
			// counter for elapsed time since carrot was caught
			// used to move donkey back after a certain time has elapsed
			timeSinceAction=0.0f;
			
		// carrot is close enough to lure donkey but far enough away to not be eaten
		} else if (dcDist < DONKEY_CARROT_REACT_DISTANCE && dcDist > DONKEY_EAT_DIST) {
			// calculate new position
			float moved = DONKEY_VEL*dt + (DONKEY_CARROT_REACT_DISTANCE-dcDist)*dt*DONKEY_ACC;
			CGPoint newPos = ccp(donkey.position.x+moved, donkey.position.y);
			// set new position if donkey isn't out of moving bounds
			if (newPos.x < L2_DONKEY_MAX_X) {
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
		// donkey hasn't been moved back to initial position yet
		if (donkey.position.x>L2_DONKEY_INITIAL_POS_X) {
			float moved = DONKEY_VEL*dt + (30*dt*DONKEY_ACC);
			donkey.position=ccp(donkey.position.x-moved, donkey.position.y);
			int donkey_walk_frame_index = donkey.position.x/DONKEY_FRAME_DX;
			[donkey setDisplayFrame:@"donkey_neutral" index:donkey_walk_frame_index%4];
		// donkey is at initial posistion, so switch game mode
		} else {
			mode = ModeAlive;
			[carrot setDisplayFrame:@"carrot" index:0];
		}
	}
}

// level completed, go to next level
-(void) levelCompleted {
	[[audioPlayerDict objectForKey:@"thebeech"] stop];
	[[CCDirector sharedDirector] pushScene: [CCSlideInRTransition transitionWithDuration:1 scene:[LevelThree scene]]];	
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{	
	// don't forget to call "super dealloc"
	[super dealloc];
	[audioPlayerDict release];
}
@end
