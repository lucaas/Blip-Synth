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

#define kMaxLFOAmplitude 0.25

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

typedef enum {
    kLFOAmp = 0,
    kLFOFreq = 1
} LFOMode;

typedef enum {
    kArpSimple,
    kArpLong,
    kArpBach,
    kArp4
} ArpMode;

@interface Synthesizer : NSObject {
    double midi[128];
    int noteNumber;
    
    double theta;
    double sampleRate;
    double frequency;
    double elapsed;
    
    BOOL isADSR;
    BOOL active;
    
    double maxAmp;
    double attack;
    double decay;
    double sustain;
    double release;
    EnvelopeMode envelopeMode;
    
    
    BOOL LFOAmplitude;
    double lfoAmount;
    double lfoFreq;
    
    AudioComponentInstance toneUnit;
    
   
    WaveSawtooth *sawtooth;
    WaveSquare *square;
    WaveTriangle *triangle;
    WaveNoise *noise;
    WaveType waveType;
    
    BOOL arpEnabled;
    ArpMode arpMode;
    int arpPeriod;
    int arpIndex;
    
}

@property (nonatomic, assign) double theta;
@property (nonatomic, assign) double sampleRate;
@property (nonatomic, assign) double frequency;
@property (nonatomic, assign) double attack;
@property (nonatomic, assign) double decay;
@property (nonatomic, assign) double sustain;
@property (nonatomic, assign) double release;
@property (nonatomic, assign) WaveType waveType;
@property (nonatomic, assign) EnvelopeMode envelopeMode;
@property (nonatomic, assign) BOOL isADSR;

@property (nonatomic, assign) BOOL arpEnabled;
@property (nonatomic, assign) ArpMode arpMode;


OSStatus RenderTone(void *inRefCon, 
                    AudioUnitRenderActionFlags *ioActionFlags, 
                    const AudioTimeStamp *inTimeStamp, 
                    UInt32 inBusNumber, 
                    UInt32 inNumberFrames, 
                    AudioBufferList *ioData);
- (void) togglePlay;



- (void)setLFO:(BOOL)enabled forMode:(LFOMode)mode;
- (void)setLFOFreq:(double)value forMode:(LFOMode)mode;
- (void)setLFOAmount:(double)freq forMode:(LFOMode)mode;
- (void)setPlay:(int)note;
- (void)setNote:(int)note;
- (void)setPitch:(float)pitch;
- (void)doArp;
- (void)setArpFreq:(double)freq;

double linearInterpolation(double x, double x0, double x1, double y0, double y1);

@end
