//
//  MyAUGraphPlayer.h
//  SpeechSynthesisWithAudioUnits
//
//  Created by Panayotis Matsinopoulos on 18/7/21.
//

#ifndef MyAUGraphPlayer_h
#define MyAUGraphPlayer_h

#import <AudioToolbox/AUGraph.h>
#import <AudioToolbox/AUComponent.h>

typedef struct _MyAUGraphPlayer {
  AUGraph graph;
  AudioUnit speechAU;
} MyAUGraphPlayer;

#endif /* MyAUGraphPlayer_h */
