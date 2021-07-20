//
//  main.m
//  SpeechSynthesisWithAudioUnits
//
//  Created by Panayotis Matsinopoulos on 18/7/21.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AUGraph.h>
#import <AudioToolbox/AudioComponent.h>
#import <AudioToolbox/AUComponent.h>
#import <ApplicationServices/ApplicationServices.h>

#import "CheckError.h"
#import "MyAUGraphPlayer.h"
#import "NSPrint.h"
#import "StopAudioUnitGraphPlayingBack.h"

void CreateMyAUGraph(MyAUGraphPlayer *player) {
  CheckError(NewAUGraph(&player->graph), "New Audio Unit Graph");
  
  // Creating a Speech Synthesizer Audio Unit Graph Node
  AudioComponentDescription generatorDescription = {0};
  generatorDescription.componentType = kAudioUnitType_Generator;
  generatorDescription.componentSubType = kAudioUnitSubType_SpeechSynthesis;
  generatorDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
  
  AUNode speechSynthesisNode;
  CheckError(AUGraphAddNode(player->graph,
                            &generatorDescription,
                            &speechSynthesisNode),
             "Graph Add Audio Unit Speech Synthesis Node");
  // ---------------------------------------------------------
  
  // Creating an Output Type Audio Unit with DefaultOuptut subtype
  AudioComponentDescription outputDefault = {0};
  outputDefault.componentType = kAudioUnitType_Output;
  outputDefault.componentSubType = kAudioUnitSubType_DefaultOutput;
  outputDefault.componentManufacturer = kAudioUnitManufacturer_Apple;
  
  AUNode outputDefaultNode;
  CheckError(AUGraphAddNode(player->graph,
                            &outputDefault,
                            &outputDefaultNode),
             "Graph Add Audio Unit Output Node");
  // -----------------------------------------------------------------
  
  // Connect Nodes
  CheckError(AUGraphConnectNodeInput(player->graph,
                                     speechSynthesisNode,
                                     0,
                                     outputDefaultNode,
                                     0),
             "Connecting file player node to output node");
  
  // Open the Graph
  CheckError(AUGraphOpen(player->graph), "Opening Graph");
  
  // Initialize the Graph
  CheckError(AUGraphInitialize(player->graph), "Initializing the Audio Unit Graph");
}

void PrepareSpeechAU(MyAUGraphPlayer *player) {
  AUNode speechSynthesisNode;
  CheckError(AUGraphGetIndNode(player->graph,
                               0,
                               &speechSynthesisNode),
             "Getting access to the speech synthesis node");
  
  AudioUnit speechSynthesisAudioUnit;
  CheckError(AUGraphNodeInfo(player->graph,
                             speechSynthesisNode,
                             NULL,
                             &speechSynthesisAudioUnit),
             "Getting the Audio Unit of the speech synthesis node");
  
  UInt32 dataSize = 0;
  Boolean isWritable = false;
  
  CheckError(AudioUnitGetPropertyInfo(speechSynthesisAudioUnit,
                                      kAudioUnitProperty_SpeechChannel,
                                      kAudioUnitScope_Global,
                                      0,
                                      &dataSize,
                                      &isWritable),
             "Getting the property info for property kAudioUnitProperty_SpeechChannel");
  
  SpeechChannel channel;
  CheckError(AudioUnitGetProperty(speechSynthesisAudioUnit,
                                  kAudioUnitProperty_SpeechChannel,
                                  kAudioUnitScope_Global,
                                  0,
                                  &channel,
                                  &dataSize),
             "Getting the chanel");
  
  SpeakCFString(channel, CFSTR("How are you dear?"), NULL);
}

void PrepareAudioUnitGraph(MyAUGraphPlayer *player) {
  CreateMyAUGraph(player);
  PrepareSpeechAU(player);
}

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    NSPrint(@"Starting...\n");
    
    MyAUGraphPlayer player = {0};
    
    PrepareAudioUnitGraph(&player);
    
    NSPrint(@"--------------\n");
    NSPrint(@"Click <Enter> to start playing back...\n");
    getchar();
    
    CheckError(AUGraphStart(player.graph), "Starting AU Graph...");
    
    Float64 sleepDuration = 10;
    NSPrint(@"Sleeping for: %.2f to allow for playback to finish\n", sleepDuration);
    
    usleep((int)(sleepDuration * 1000 * 1000));
    
    StopAudioUnitGraphPlayingBack(player.graph);
    
    NSPrint(@"Bye!\n");
  }
  return 0;
}
