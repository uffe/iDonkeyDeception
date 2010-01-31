//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "LevelThreeScene.h"
//#import "Helper.h"
#import "EndScene.h"

// HelloWorld implementation
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
#define L3_DONKEY_BRIDGE_COLLAPSE_Y (157)

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		// addbackground
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"background3.png"];
		background.position = ccp( size.width /2 , size.height/2 );
		[self addChild:background];
		[self setIsTouchEnabled:YES];
		[self schedule: @selector(tick:)];
		mode=ModeAlive;
		
		// add carrot
		[self addChild:carrot];
		carrot_initial_pos_x = L3_CARROT_INITIAL_POS_X;
		carrot_initial_pos_y = L3_CARROT_INITIAL_POS_Y;
		carrot.position = ccp(carrot_initial_pos_x,carrot_initial_pos_y);
		
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
	[[CCDirector sharedDirector] pushScene: [CCSlideInTTransition transitionWithDuration:1 scene:[EndScene scene]]];	
}

- (void) moveBackCarrot {
	[carrot runAction:[[CCMoveTo alloc] initWithDuration:REVERT_TIME position:ccp(263, carrot_initial_pos_y)]];
}

-(void)playSpike {
	NSLog(@"playSpike");
	//TODO
	[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"knife"] withObject:nil];
}


- (void)animateBridge:(ccTime)dt {
	float previous_tile_y = L3_BRIDGE_START_Y;
	float next_tile_y = L3_BRIDGE_START_Y;
	float new_y;
//	bridgeTile[5].position = ccp(bridgeTile[5].position.x, L3_BRIDGE_START_Y-20);
	float gravity_acc = 0.3f;
	float tile_chain_pull = 0.7f;
	
	if (ModeDead==mode) {
		return;
	}
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
//			if (dist_y>5) {
				new_y = bridgeTile[i].position.y - tile_chain_pull*(dist_y);
//			} else {
//				new_y = bridgeTile[i].position.y - tile_chain_pull*(dist_y-10);
//			}
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
		new_y = bridgeTile[donkey_tile].position.y + L3_DONKEY_BRIDGE_OFFSET;
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
//	else {
//		newPos = ccp(carrot.position.x,L3_CARROT_INITIAL_POS_Y);
//		carrot.position = newPos;
//	}
}

-(void) tick: (ccTime) dt {
	[super tick:dt];
#define FALL_DOWN_POS 345.0f
	
	[self animateBridge:dt];
//	NSLog(@"%f",donkey.position.y);
	if (mode==ModeAlive) {	
		if (dcDist < DONKEY_EAT_DIST) {
			mode=ModeCarrotCaught;
//			[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"trombone"] withObject:nil];
			
			[carrot setDisplayFrame:@"carrot" index:1];
			
			[carrot runAction:[[CCMoveTo alloc] initWithDuration:REVERT_TIME position:ccp(carrot_initial_pos_x,carrot_initial_pos_y)]];
			timeSinceAction=0.0f;
		} else if (dcDist < DONKEY_CARROT_REACT_DISTANCE && dcDist > DONKEY_EAT_DIST) {
			float moved = DONKEY_VEL*dt + (DONKEY_CARROT_REACT_DISTANCE-dcDist)*dt*DONKEY_ACC;
			CGPoint newPos = ccp(donkey.position.x+moved, donkey.position.y);
			if (newPos.x < L3_DONKEY_MAX_X) {
				int donkey_walk_frame_index = newPos.x/DONKEY_FRAME_DX;
				[donkey setDisplayFrame:@"donkey_stretch" index:donkey_walk_frame_index%4];
				donkey.position=newPos;
			}
			//NSLog(@"Ticked! %f", dt);
			// move the donkey
			//			float moved = DONKEY_VEL*dt + (DONKEY_CARROT_REACT_DISTANCE-dcDist)*dt*DONKEY_ACC;
			//			donkey.position=ccp((donkey.position.x+moved), donkey.position.y);
			//			int donkey_walk_frame_index = donkey.position.x/DONKEY_FRAME_DX;
			//			[donkey setDisplayFrame:@"donkey_stretch" index:donkey_walk_frame_index%4];
		} else {
			[donkey setDisplayFrame:@"donkey_neutral" index:0];
		}
	} else if (mode==ModeCarrotCaught) {
		if (timeSinceAction < REVERT_TIME) {
			int donkey_eat_index = timeSinceAction*1000/DONKEY_CHEW_DT;
			[donkey setDisplayFrame:@"donkey_eat" index:donkey_eat_index%2];
			if (donkey.position.y < L3_DONKEY_BRIDGE_COLLAPSE_Y) {
				// donkey fall down
				[donkey runAction:[CCMoveTo actionWithDuration:1.5f position:ccp(donkey.position.x+100,0)]];
				[donkey runAction:[CCRotateTo actionWithDuration:1.2 angle:179.0]];
				mode=ModeDead;
				for (int i=0;i<L3_BRIDGE_TILE_COUNT;i++) {
//					[bridgeTile[i] runAction:[CCRotateTo actionWithDuration:1.2 position:ccp(bridgeTile[i].position.x,0)]];
					[bridgeTile[i] runAction:[CCMoveTo actionWithDuration:1.2 position:ccp(bridgeTile[i].position.x,0)]];
				}
				[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"applause"] withObject:nil];
				[self performSelector:@selector(levelCompleted) withObject:nil afterDelay:2];
				[self performSelector:@selector(playSpike) withObject:nil afterDelay:1.3];
				[self performSelector:@selector(moveBackCarrot) withObject:nil afterDelay:0.2];
				//			[NSTimer timerWithTimeInterval:0.8 target:self selector:@selector(playSpike) userInfo:nil repeats:NO];
			}
		} else {
			mode=ModeReturning;
			[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"trombone"] withObject:nil];
		}
	} else if (mode==ModeReturning) {
		if (donkey.position.x>L3_DONKEY_INITIAL_POS_X) {
			float moved = DONKEY_VEL*dt + (30*dt*DONKEY_ACC);
			donkey.position=ccp(donkey.position.x-moved, donkey.position.y);
			int donkey_walk_frame_index = donkey.position.x/DONKEY_FRAME_DX;
			[donkey setDisplayFrame:@"donkey_neutral" index:donkey_walk_frame_index%4];
		} else {
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
