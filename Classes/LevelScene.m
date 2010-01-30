//
//  LevelScene.m
//  TrickTheDonkey
//
//  Created by Martin on 30/1/10.
//  Copyright 2010 Identified Object. All rights reserved.
//

#import "LevelScene.h"
#import "Helper.h"



@implementation LevelScene
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
		
//		// add carrot
//		carrot = [CCSprite spriteWithFile:@"Carrot_alt1.png"];
//		[self addChild:carrot];

//		carrot = [CCSprite spriteWithFile:@"carrot.png"];
//		//		carrot.position = L1_CARROT_INITIAL_POS;
//		[self addChild:carrot];
//		
//		CCAnimation *an = [CCAnimation animationWithName:@"carrot" delay:0];
//		[an addFrameWithFilename:@"Carrot_alt1.png"];
//		[an addFrameWithFilename:@"Carrot_alt1_gone.png"];
//		[carrot addAnimation:an];
//		
//		// Add donkey and its animations
//		donkey = [CCSprite spriteWithFile:@"Donkey_neutral.png"];
//		//		donkey.position = DONKEY_INITIAL_POS;
//		[self addChild:donkey];
//		
//		CCAnimation *donkey_stretch_animation = [CCAnimation animationWithName:@"donkey_stretch" delay:0];
//		[donkey_stretch_animation addFrameWithFilename:@"Donkey_stretch_neutral.png"];
//		[donkey_stretch_animation addFrameWithFilename:@"Donkey_stretch_left_front.png"];
//		[donkey_stretch_animation addFrameWithFilename:@"Donkey_stretch_neutral.png"];
//		[donkey_stretch_animation addFrameWithFilename:@"Donkey_stretch_right_front.png"];
//		[donkey addAnimation:donkey_stretch_animation];
//		
//		CCAnimation *donkey_neutral_animation = [CCAnimation animationWithName:@"donkey_neutral" delay:0];
//		[donkey_neutral_animation addFrameWithFilename:@"Donkey_neutral_neutral.png"];
//		[donkey_neutral_animation addFrameWithFilename:@"Donkey_neutral_left_front.png"];
//		[donkey_neutral_animation addFrameWithFilename:@"Donkey_neutral_neutral.png"];
//		[donkey_neutral_animation addFrameWithFilename:@"Donkey_neutral_right_front.png"];
//		[donkey addAnimation:donkey_neutral_animation];
//		
//		CCAnimation *donkey_eat_animation = [CCAnimation animationWithName:@"donkey_eat" delay:0];
//		[donkey_eat_animation addFrameWithFilename:@"Donkey_eating_state1.png"];
//		[donkey_eat_animation addFrameWithFilename:@"Donkey_eating_state2.png"];
//		[donkey addAnimation:donkey_eat_animation];
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

@end
