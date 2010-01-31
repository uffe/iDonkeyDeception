//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "LevelTwoScene.h"
#import "LevelThreeScene.h"

// HelloWorld implementation
@implementation LevelTwo

#define L2_CARROT_INITIAL_POS_X 200
#define L2_CARROT_INITIAL_POS_Y 290

#define L2_DONKEY_INITIAL_POS_X 40
#define L2_DONKEY_INITIAL_POS ccp(L2_DONKEY_INITIAL_POS_X, 180)
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
		
		// addbackground
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"background2.png"];
		background.position = ccp( size.width /2, size.height/2 );
		[self addChild:background];
		[self setIsTouchEnabled:YES];
		[self schedule: @selector(tick:)];
		mode=ModeAlive;

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
		fish.position = FISH_INITIAL_POS;
		[self addChild:fish];
		[fish runAction:[CCMoveTo actionWithDuration:5 position:FISH_SECOND_POS]];
		timeSinceFishFlipped = -5;
		
		CCAnimation *fan = [CCAnimation animationWithName:@"fish" delay:0];
		[fan addFrameWithFilename:@"fishclosed.png"];
		[fan addFrameWithFilename:@"fish.png"];
		[fish addAnimation:fan];

		CCSprite *water = [CCSprite spriteWithFile:@"vand.png"];
		water.position = ccp(480.0f/2+130, 140);

		[self addChild:water];
		[water runAction:[CCWaves3D actionWithWaves:100000 amplitude:40.0 grid:ccg(10,10) duration:200000]];
		
		CCSprite *foreground = [CCSprite spriteWithFile:@"bane-2-forgrund.png"];
		foreground.position = ccp(275, 110);
		[self addChild:foreground];

		// play beach song
		[[audioPlayerDict objectForKey:@"thebeech"] play];
		
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

-(void) tick: (ccTime) dt {
	[super tick:dt];
	#define FISH_EAT_DONKEY_DIST 50.0f
	#define L2_DONKEY_MAX_X 120.0f
	#define FISH_CARROT_REACT_DISTANCE 70.0f
	#define FISH_VEL 30.0f
	
	float dfDist = fish.position.x - donkey.position.x-donkey.contentSize.width/2;
	float fcDist = carrot.position.x - fish.position.x;
	timeSinceFishFlipped += dt;
	if (mode==ModeAlive) {	
		if (dfDist < FISH_EAT_DONKEY_DIST) {
			mode = ModeFishEatingDonkey;
			[fish setDisplayFrame:@"fish" index:1];
			[fish runAction:[CCRotateTo actionWithDuration:1.0f angle:-91.0]];
			[fish runAction:[CCJumpTo actionWithDuration:1.0f position:donkey.position height:150 jumps:1]];
			[fish runAction:[CCScaleBy actionWithDuration:1.0f scale:1.5f]];
			fish.flipX = NO;
			[self performSelector:@selector(levelCompleted) withObject:nil afterDelay:3.0f];
			[self performSelector:@selector(playKnifeSound) withObject:nil afterDelay:0.9f];

		}
		if (abs(fcDist) < FISH_CARROT_REACT_DISTANCE) {
			// move the fish
			float moved;
			if (timeSinceFishFlipped > 1)
			{
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
			fish.flipX = fishFlipped;
			if (fish.position.x+moved > FISH_MIN_X && fish.position.x+moved < FISH_MAX_X) {
				fish.position=ccp(fish.position.x+moved, fish.position.y);
			}
		}
		if (dcDist < DONKEY_EAT_DIST) {
			mode=ModeCarrotCaught;
			[NSThread detachNewThreadSelector:@selector(play) toTarget:[audioPlayerDict objectForKey:@"trombone"] withObject:nil];
			
			[carrot setDisplayFrame:@"carrot" index:1];
			
			[carrot runAction:[[CCMoveTo alloc] initWithDuration:REVERT_TIME position:ccp(carrot_initial_pos_x,carrot_initial_pos_y)]];
//			[donkey runAction:[CCMoveTo actionWithDuration:REVERT_TIME position:L2_DONKEY_INITIAL_POS]];
			timeSinceAction=0.0f;
		} else if (dcDist < DONKEY_CARROT_REACT_DISTANCE && dcDist > DONKEY_EAT_DIST) {
			float moved = DONKEY_VEL*dt + (DONKEY_CARROT_REACT_DISTANCE-dcDist)*dt*DONKEY_ACC;
			CGPoint newPos = ccp(donkey.position.x+moved, donkey.position.y);
			if (newPos.x < L2_DONKEY_MAX_X) {
				int donkey_walk_frame_index = newPos.x/DONKEY_FRAME_DX;
				[donkey setDisplayFrame:@"donkey_stretch" index:donkey_walk_frame_index%4];
				donkey.position=newPos;
			}
		} else {
			[donkey setDisplayFrame:@"donkey_neutral" index:0];
		}
	} else if (mode==ModeCarrotCaught) {
		if (timeSinceAction < REVERT_TIME) {
			int donkey_eat_index = timeSinceAction*1000/DONKEY_CHEW_DT;
			[donkey setDisplayFrame:@"donkey_eat" index:donkey_eat_index%2];
		} else {
			mode=ModeReturning;
		}
	} else if (mode==ModeReturning) {
		if (donkey.position.x>L2_DONKEY_INITIAL_POS_X) {
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

-(void) levelCompleted{
	[[audioPlayerDict objectForKey:@"thebeech"] stop];
	[[CCDirector sharedDirector] pushScene: [CCSlideInRTransition transitionWithDuration:1 scene:[LevelThree scene]]];	
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
