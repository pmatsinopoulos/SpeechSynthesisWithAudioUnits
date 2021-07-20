//
//  StopAudioUnitGraphPlayingBack.m
//  AudioUnitsTutorial1
//
//  Created by Panayotis Matsinopoulos on 5/7/21.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AUGraph.h>

void StopAudioUnitGraphPlayingBack(AUGraph inGraph) {
  AUGraphStop(inGraph);
  AUGraphUninitialize(inGraph);
  AUGraphClose(inGraph);
}
