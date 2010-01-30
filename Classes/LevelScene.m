//
//  LevelScene.m
//  TrickTheDonkey
//
//  Created by Martin on 30/1/10.
//  Copyright 2010 Identified Object. All rights reserved.
//

#import "LevelScene.h"


@implementation LevelScene

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
