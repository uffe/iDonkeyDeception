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
							[Helper prepAudio:@"thebeech"],@"thebeech",
							nil] retain];
		
		// Create carrot and its animations
		carrot = [CCSprite spriteWithFile:@"Carrot_alt2.png"];

		CCAnimation *an = [CCAnimation animationWithName:@"carrot" delay:0];
		[an addFrameWithFilename:@"Carrot_alt2.png"];
		[an addFrameWithFilename:@"Carrot_alt2_gone.png"];
		[carrot addAnimation:an];
		
		// Create donkey and its animations
		donkey = [CCSprite spriteWithFile:@"Donkey_neutral.png"];

		CCAnimation *donkey_stretch_animation = [CCAnimation animationWithName:@"donkey_stretch" delay:0];
		[donkey_stretch_animation addFrameWithFilename:@"Donkey_stretch_neutral.png"];
		[donkey_stretch_animation addFrameWithFilename:@"Donkey_stretch_left_front.png"];
		[donkey_stretch_animation addFrameWithFilename:@"Donkey_stretch_neutral.png"];
		[donkey_stretch_animation addFrameWithFilename:@"Donkey_stretch_right_front.png"];
		[donkey addAnimation:donkey_stretch_animation];
		
		CCAnimation *donkey_neutral_animation = [CCAnimation animationWithName:@"donkey_neutral" delay:0];
		[donkey_neutral_animation addFrameWithFilename:@"Donkey_neutral_neutral.png"];
		[donkey_neutral_animation addFrameWithFilename:@"Donkey_neutral_left_front.png"];
		[donkey_neutral_animation addFrameWithFilename:@"Donkey_neutral_neutral.png"];
		[donkey_neutral_animation addFrameWithFilename:@"Donkey_neutral_right_front.png"];
		[donkey addAnimation:donkey_neutral_animation];
		
		CCAnimation *donkey_eat_animation = [CCAnimation animationWithName:@"donkey_eat" delay:0];
		[donkey_eat_animation addFrameWithFilename:@"Donkey_eating_state1.png"];
		[donkey_eat_animation addFrameWithFilename:@"Donkey_eating_state2.png"];
		[donkey addAnimation:donkey_eat_animation];
	}
	return self;
}


-(void) tick: (ccTime) dt {
	dcDist = carrot.position.x - donkey.position.x-donkey.contentSize.width/2;
	timeSinceAction += dt;
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
