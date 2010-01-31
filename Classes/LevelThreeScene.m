//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "LevelThreeScene.h"
//#import "Helper.h"
#import "EndScene.h"

// *** Trick The Donkey: Level 3 ***
//
// Level 3 places the donkey on the left side of a bridge
// when the donkey walks on the bridge, its weight presses the bridge down
// if the donkey eats the carrot while standing in the middle of the bridge, the bridge collapses
// and the donkey dies.
// a large carrot is used that increases the weight of the donkey when eaten.

@implementation LevelThree


#define L3_CARROT_INITIAL_POS_X 200
#define L3_CARROT_INITIAL_POS_Y 290

#define L3_DONKEY_INITIAL_POS_X 40
#define L3_DONKEY_INITIAL_POS_Y 190
#define L3_DONKEY_INITIAL_POS ccp(L3_DONKEY_INITIAL_POS_X, L3_DONKEY_INITIAL_POS_Y)
#define L3_DONKEY_MAX_X 1000
#define L3_BRIDGE_START_X 90
#define L3_BRIDGE_START_Y 155
#define L3_BRIDGE_LENGTH 310
#define L3_DONKEY_BRIDGE_OFFSET (40)
#define L3_CARROT_BRIDGE_OFFSET (150)
#define L3_DONKEY_BRIDGE_COLLAPSE_Y (160)

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
		CCSprite *background = [CCSprite spriteWithFile:@"background3.png"];
		background.position = ccp( size.width /2 , size.height/2 );
		[self addChild:background];
		
		// add carrot
		carrot = [CCSprite spriteWithFile:@"carrot-stor.png"];
		[self addChild:carrot];
		carrot_initial_pos_x = L3_CARROT_INITIAL_POS_X;
		carrot_initial_pos_y = L3_CARROT_INITIAL_POS_Y;
		carrot.position = ccp(carrot_initial_pos_x,carrot_initial_pos_y);
		// add different carrot states as an animation
		CCAnimation *an = [CCAnimation animationWithName:@"carrot" delay:0];
		[an addFrameWithFilename:@"carrot-stor.png"];
		[an addFrameWithFilename:@"Carrot_alt2_gone.png"];
		[carrot addAnimation:an];
		
		// add donkey
		[self addChild:donkey];
		donkey.position = L3_DONKEY_INITIAL_POS;
				
		// add bridge tiles
		for (int i=0;i<L3_BRIDGE_TILE_COUNT;i++) {
			bridgeTile[i] = [CCSprite spriteWithFile:@"bridgetile.png"];
			bridgeTile[i].position = ccp(L3_BRIDGE_START_X+i*L3_BRIDGE_LENGTH/L3_BRIDGE_TILE_COUNT,L3_BRIDGE_START_Y);
			tile_y0[i] = L3_BRIDGE_START_Y;
			[self addChild:bridgeTile[i]];
		}
		
		// foreground
		CCSprite *lawn = [CCSprite spriteWithFile:@"foreground3.png"];
		lawn.position = ccp(480.0f/2-7.0, 125);
		[self addChild:lawn];

	}
	return self;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// only handle touch if we're in alive game mode
	if (mode != ModeAlive) { return kEventHandled; }
	
	UITouch *touch = [touches anyObject];
	if (touch) {
		CGPoint location = [touch locationInView: [touch view]];
		
		// IMPORTANT:
		// The touches are always in "portrait" coordinates. You need to convert them to your current orientation
		CGPoint convertedPoint = [[CCDirector sharedDirector] convertToGL:location];
		
		// update carrot position
		carrot.position = ccp(convertedPoint.x, carrot.position.y);
		
		// no other handlers will receive this event
		return kEventHandled;
	}
	
	// event has been handled
	return kEventHandled;
	
}

// push end scene when level completed
-(void) levelCompleted {
	[[CCDirector sharedDirector] pushScene: [CCSlideInTTransition transitionWithDuration:1 scene:[EndScene scene]]];	
}

// move carrot back to initial position
- (void) moveBackCarrot {
	[carrot runAction:[[CCMoveTo alloc] initWithDuration:REVERT_TIME position:ccp(263, carrot_initial_pos_y)]];
}

// play sound "spike"
-(void)playSpike {
	// TODO
	[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"knife"] withObject:nil];
}


// animate the bridge tiles
- (void)animateBridge:(ccTime)dt {
	float previous_tile_y = L3_BRIDGE_START_Y;
	float next_tile_y = L3_BRIDGE_START_Y;
	float new_y;
	float gravity_acc = 0.3f;
	float tile_chain_pull = 0.7f;
	
	// don't do anything if in dead mode
	if (ModeDead == mode) {	return; }
	
	// Verlet integration <- google it :)
	// Momentum (and gravity and drag)
	for (int i=1;i<L3_BRIDGE_TILE_COUNT-1;i++) {
		new_y = tile_y0[i] + (bridgeTile[i].position.y - tile_y0[i])*0.5f - gravity_acc;
		bridgeTile[i].position = ccp(bridgeTile[i].position.x,new_y);
		tile_y0[i] = bridgeTile[i].position.y;
	}

	
	// Move tiles according to neighbor tiles
	for (int i=0;i<L3_BRIDGE_TILE_COUNT;i++) {
			if ((L3_BRIDGE_TILE_COUNT-1)==i) {
				next_tile_y = L3_BRIDGE_START_Y;
			} else {
				next_tile_y = bridgeTile[i+1].position.y;
			}
			float dist_y = (bridgeTile[i].position.y - previous_tile_y) + (bridgeTile[i].position.y - next_tile_y);
			new_y = bridgeTile[i].position.y - tile_chain_pull*(dist_y);
			previous_tile_y = bridgeTile[i].position.y; // remember this for next tile..
			CGPoint newPos = ccp(bridgeTile[i].position.x, new_y);
			bridgeTile[i].position = newPos;
	}
/**/
	CCSprite *myDonkey = donkey;
	CGPoint newPos;

	// Is donkey on bridge?
	if (((L3_BRIDGE_START_Y-20)<myDonkey.position.x) && (myDonkey.position.x<L3_BRIDGE_START_X+L3_BRIDGE_LENGTH-20)) {
		// What tile is donkey on? (donkey_pos_on_bridge/tile_length)
		int donkey_tile = ((myDonkey.position.x - L3_BRIDGE_START_X)/(L3_BRIDGE_LENGTH/L3_BRIDGE_TILE_COUNT));

		// Donkey push on tile
		new_y = bridgeTile[donkey_tile].position.y - 5;
		CGPoint newPos = ccp(bridgeTile[donkey_tile].position.x,new_y);
		bridgeTile[donkey_tile].position = newPos;
		
		// Place donkey according to tile
		new_y = bridgeTile[donkey_tile].position.y + donkey.contentSize.height*donkey.scaleY/2.0f;
		newPos = ccp(donkey.position.x,new_y);
		myDonkey.position = newPos;
	} else {
		newPos = ccp(myDonkey.position.x,L3_DONKEY_INITIAL_POS_Y);
		myDonkey.position = newPos;
	}
	
	// Is carrot on bridge?
	if (((L3_BRIDGE_START_Y-20)<carrot.position.x) && (carrot.position.x<L3_BRIDGE_START_X+L3_BRIDGE_LENGTH-20)) {
		// What tile is carrot on? 
		int tile = ((carrot.position.x - L3_BRIDGE_START_X)/(L3_BRIDGE_LENGTH/L3_BRIDGE_TILE_COUNT));
		// Place carrot according to tile
		new_y = bridgeTile[tile].position.y + L3_CARROT_BRIDGE_OFFSET;
		newPos = ccp(carrot.position.x,new_y);
		carrot.position = newPos;
	} 
}

// game loop
-(void) tick: (ccTime) dt {
	[super tick:dt];
	#define FALL_DOWN_POS 345.0f
	[self animateBridge:dt];
	
	// player is alive
	if (mode == ModeAlive) {	
		// donkey is close enough to carrot to eat it
		if (dcDist < DONKEY_EAT_DIST) {
			// change to carrot caught game mode
			mode = ModeCarrotCaught;
			// show carrot eaten image
			[carrot setDisplayFrame:@"carrot" index:1];
			// move carrot back to initial position
			[carrot runAction:[[CCMoveTo alloc] initWithDuration:REVERT_TIME position:ccp(carrot_initial_pos_x,carrot_initial_pos_y)]];
			// reset time counter
			// used to measure time since carrot was eaten
			timeSinceAction=0.0f;
			// scale donkey up to indicate that donkey's weight increases
			[donkey runAction:[CCScaleTo actionWithDuration:0.3f scale:1.1f]];
			
		// carrot is close enough to carrot to be attracted by it but not close enough to eat it
		} else if (dcDist < DONKEY_CARROT_REACT_DISTANCE && dcDist > DONKEY_EAT_DIST) {
			// calculate how much donkey should move
			float moved = DONKEY_VEL*dt + (DONKEY_CARROT_REACT_DISTANCE-dcDist)*dt*DONKEY_ACC;
			CGPoint newPos = ccp(donkey.position.x+moved, donkey.position.y);
			
			// only move donkey if it's not past max position
			if (newPos.x < L3_DONKEY_MAX_X) {
				// update animation frame
				int donkey_walk_frame_index = newPos.x/DONKEY_FRAME_DX;
				[donkey setDisplayFrame:@"donkey_stretch" index:donkey_walk_frame_index%4];
				// set new position
				donkey.position = newPos;
			}
			
		// donkey is not close enough to carrot to interact with it
		} else {
			[donkey setDisplayFrame:@"donkey_neutral" index:0];
		}
		
	// carrot has been caught by the donkey
	} else if (mode == ModeCarrotCaught) {
		// time since entering caught mode is less than time when we reset or complete the level
		if (timeSinceAction < REVERT_TIME) {
			// update the eat animation frame
			int donkey_eat_index = timeSinceAction*1000/DONKEY_CHEW_DT;
			[donkey setDisplayFrame:@"donkey_eat" index:donkey_eat_index%2];
			
		// we're ready to reset or complete the level
		} else {
			// donkey has weighed bridge down enough to complete the level
			if ((donkey.position.y - (donkey.contentSize.height*donkey.scaleY-donkey.contentSize.height)) < L3_DONKEY_BRIDGE_COLLAPSE_Y) {
				// animate dokey falling down
				[donkey runAction:[CCMoveTo actionWithDuration:1.5f position:ccp(donkey.position.x+100,0)]];
				[donkey runAction:[CCRotateTo actionWithDuration:1.2 angle:179.0]];
				// game mode dead
				mode = ModeDead;
				// animate bridge falling down
				for (int i=0;i<L3_BRIDGE_TILE_COUNT;i++) {
					[bridgeTile[i] runAction:[CCMoveTo actionWithDuration:1.2 position:ccp(bridgeTile[i].position.x,0)]];
				}
				// play sound
				[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"applause"] withObject:nil];
				// perform level complete actions
				[self performSelector:@selector(levelCompleted) withObject:nil afterDelay:2];
				[self performSelector:@selector(playSpike) withObject:nil afterDelay:1.3];
				[self performSelector:@selector(moveBackCarrot) withObject:nil afterDelay:0.2];
			
			// carrot is eaten but donkey is not far enough down on bridge to complete level, so reset level
			} else {
				// change game mode 
				mode = ModeReturning;
				// scale donkey back to normal size
				[donkey runAction:[CCScaleTo actionWithDuration:0.3f scale:1.0f]];
				// play level failed sound
				[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"trombone"] withObject:nil];
			}
		}
		
	// return carrot and donkey to initial positions
	} else if (mode == ModeReturning) {
		// donkey is not back to initial position
		if (donkey.position.x>L3_DONKEY_INITIAL_POS_X) {
			// update donkey position and animation
			float moved = DONKEY_VEL*dt + (30*dt*DONKEY_ACC);
			donkey.position = ccp(donkey.position.x-moved, donkey.position.y);
			int donkey_walk_frame_index = donkey.position.x/DONKEY_FRAME_DX;
			[donkey setDisplayFrame:@"donkey_neutral" index:donkey_walk_frame_index%4];
		// level is reset, so change to alive mode
		} else {
			mode = ModeAlive;
			[carrot setDisplayFrame:@"carrot" index:0];
		}
	}
}



// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// don't forget to call "super dealloc"
	[super dealloc];
	[audioPlayerDict release];
}
@end
