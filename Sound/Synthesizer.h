//
//  Synthesizer.h
//  Sound
//
//  Created by Lucas Correia on 2011-09-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "WaveSawtooth.h"
#import "WaveSquare.h"
#import "WaveTriangle.h"
#import "WaveNoise.h"
typedef enum {
    kSinus,
    kSquare,
    kSawTooth,
    kTriangle,
    kNoise
} WaveType;

typedef enum {
    kAttack = ATTACK,
    kDecay = DECAY,
    kSustain = SUSTAIN,
    kRelease = RELEASE
} EnvelopeMode;

@interface Synthesizer : NSObject {
    double theta;
    double sampleRate;
    double frequency;
    double startTime;
    
    BOOL isADSR;
    float attack;
    float decay;
    float sustain;
    float release;
    EnvelopeMode envelopeMode;
    
    AudioComponentInstance toneUnit;
    
   
    WaveSawtooth *sawtooth;
    WaveSquare *square;
    WaveTriangle *triangle;
    WaveNoise *noise;
    WaveType waveType;
    
}


@property (nonatomic, assign) double theta;
@property (nonatomic, assign) double sampleRate;
@property (nonatomic, assign) double frequency;
@property (nonatomic, assign) float attack;
@property (nonatomic, assign) float decay;
@property (nonatomic, assign) float sustain;
@property (nonatomic, assign) float release;
@property (nonatomic, assign) WaveType waveType;
@property (nonatomic, assign) EnvelopeMode envelopeMode;
@property (nonatomic, assign) BOOL isADSR;

OSStatus RenderTone(void *inRefCon, 
                    AudioUnitRenderActionFlags *ioActionFlags, 
                    const AudioTimeStamp *inTimeStamp, 
                    UInt32 inBusNumber, 
                    UInt32 inNumberFrames, 
                    AudioBufferList *ioData);
- (void) togglePlay;

@end
