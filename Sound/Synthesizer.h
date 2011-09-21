//
//  Synthesizer.h
//  Sound
//
//  Created by Lucas Correia on 2011-09-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
typedef enum {
    kSinus,
    kSquare,
    kSawTooth,
    kTriangle
} WaveType;

@interface Synthesizer : NSObject {
    double theta;
    double sampleRate;
    double frequency;
    AudioComponentInstance toneUnit;
    
    WaveType waveType;
    
}


@property (nonatomic, assign) double theta;
@property (nonatomic, assign) double sampleRate;
@property (nonatomic, assign) double frequency;
@property (nonatomic, assign) WaveType waveType;

OSStatus RenderTone(void *inRefCon, 
                    AudioUnitRenderActionFlags *ioActionFlags, 
                    const AudioTimeStamp *inTimeStamp, 
                    UInt32 inBusNumber, 
                    UInt32 inNumberFrames, 
                    AudioBufferList *ioData);
- (void) togglePlay;

@end
