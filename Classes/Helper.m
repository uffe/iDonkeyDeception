//
//  Helper.m
//  TrickTheDonkey
//
//  Created by Uffe Koch on 30/01/10.
//  Copyright 2010 Huge Lawn Software. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (AVAudioPlayer *)prepAudio:(NSString *)audioFileName
{
	AVAudioPlayer *theMessageAudioPlayer = nil;
	@try {
		NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:audioFileName
																  ofType: @"wav"];
		
		if (! audioFilePath)
			[NSException raise:@"No audio path" format:@"No path to audio file"];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:audioFilePath])
		{
			NSLog(@"file does not exists");
		}
		else
		{
			NSURL *audioFileURL = [NSURL fileURLWithPath: audioFilePath];
			
			NSError *audioPlayerError = nil;
			theMessageAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL
																		   error:&audioPlayerError];
			if (! theMessageAudioPlayer)
				[NSException raise:@"No player" format:@"Couldn't create audio player: %@",
				 [audioPlayerError localizedDescription]];
			
			theMessageAudioPlayer.meteringEnabled = NO;
			[theMessageAudioPlayer prepareToPlay];
		}
	}
	@catch (NSException* exception)
	{
		NSLog (@"exception: %@", exception);
	}	
	return theMessageAudioPlayer;
}

@end
