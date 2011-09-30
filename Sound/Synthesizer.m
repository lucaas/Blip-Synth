//
//  Synthesizer.m
//  Sound
//
//  Created by Lucas Correia on 2011-09-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Synthesizer.h"

@implementation Synthesizer
@synthesize sampleRate;
@synthesize frequency;
@synthesize theta;
@synthesize attack;
@synthesize decay;
@synthesize sustain;
@synthesize release;
@synthesize waveType;
@synthesize isADSR;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        sampleRate = 44100.00;
        frequency = 440; // Hz
        theta = M_PI / 2;
        
        sawtooth = [[WaveSawtooth alloc] init];
        square = [[WaveSquare alloc] init];
        triangle = [[WaveTriangle alloc] init];
        noise = [[WaveNoise alloc] init];
        
        isADSR = NO;
    }
    
    return self;
}

double sinvalue(double angle, double amplitude) {
    return sin(angle) * amplitude;
}


double linearInterpolation(double x, double x0, double x1, double y0, double y1) {
    return y0 + (x-x0) * ((y1-y0)/(x1-x0));
}

- (EnvelopeMode) envelopeMode {
    return envelopeMode;
}
- (void) setEnvelopeMode:(EnvelopeMode)_envelopeMode {
    envelopeMode = _envelopeMode;
    startTime = -1;
    NSLog(@"Changed envelope mode to: %d", envelopeMode);
}


OSStatus RenderTone(
                    void *inRefCon, 
                    AudioUnitRenderActionFlags *ioActionFlags, 
                    const AudioTimeStamp *inTimeStamp, 
                    UInt32 inBusNumber, 
                    UInt32 inNumberFrames, 
                    AudioBufferList *ioData)

{
    // Fixed amplitude is good enough for our purposes
    
    
    // Get the tone parameters out of the view controller
	Synthesizer *synthesizer = (Synthesizer *)(inRefCon);
    
    
    
    // ADSR ENVELOPE -----
    
    if (synthesizer->startTime == -1)
        synthesizer->startTime = inTimeStamp->mSampleTime / synthesizer->sampleRate;
    double amplitude = 1.0;

    if (synthesizer->isADSR) {
        Float64 elapsed_time = inTimeStamp->mSampleTime / synthesizer->sampleRate - synthesizer->startTime;    

        static const double maxAmp = 1.0;
        switch (synthesizer->envelopeMode) {
            case kAttack:
                if (elapsed_time < synthesizer->attack) {
                    amplitude = linearInterpolation(elapsed_time, 0, synthesizer->attack, 0, maxAmp);
                }
                else {
                    synthesizer->startTime = inTimeStamp->mSampleTime / synthesizer->sampleRate;
                    amplitude = maxAmp;
                    synthesizer->envelopeMode = kDecay;
                }
                break;
            case kDecay:
                if (elapsed_time < synthesizer->decay) {
                    double t0 = 0.0;
                    // linear interpolation maxamp -> sustain from t0 -> decay.
                    amplitude = linearInterpolation(elapsed_time, t0, synthesizer->decay, maxAmp, synthesizer->sustain);
                }
                else {
                    amplitude = synthesizer->sustain;
                    synthesizer->envelopeMode = kSustain;
                }
                break;
            case kSustain:
                amplitude = synthesizer->sustain;
                break;
            case kRelease:
                if (elapsed_time < synthesizer->release) {
                    double t0 = 0.0;
                    double y1 = 0.0;
                    // linear interpolation sustain -> 0 from t0 -> release.
                    amplitude = linearInterpolation(elapsed_time, t0, synthesizer->release, synthesizer->sustain, y1);
                    //NSLog(@"releasing: %2.2f, %2.2f, %2.2f, %2.2f", elapsed_time, t0, synthesizer->release, synthesizer->sustain);
                }
                else    {
                    amplitude = 0;
                    // TODO: Stop playing
                }
                break;
        }
    }
    
    // END ADSR ---
             
             

	double theta = synthesizer->theta;
	double theta_increment = 2.0 * M_PI * synthesizer->frequency / synthesizer->sampleRate;
    int period = (int)(synthesizer->sampleRate / synthesizer->frequency);
             
    // This is a mono tone generator so we only need the first buffer
    const int channel = 0;
    Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
    
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) 
    {
        switch (synthesizer->waveType) {
            case kSinus:
                buffer[frame] = sinvalue(theta, amplitude);
                break;
                
            case kSquare:
                buffer[frame] = amplitude * [synthesizer->square nextValue];
                break; 
                
            case kSawTooth:
                buffer[frame] = amplitude * [synthesizer->sawtooth nextValue];
                break;
                
            case kTriangle:
                buffer[frame] = amplitude * [synthesizer->triangle nextValue];
                break;
                
            case kNoise:
                buffer[frame] = amplitude * [synthesizer->noise nextValue];
                break;
                
            default:
                buffer[frame] = 0.0;

        }
        
        
        theta += theta_increment;
        if (theta > 2.0 * M_PI)
        {
            theta -= 2.0 * M_PI;
        }
    }
    synthesizer->theta = theta;
    
    return noErr;
}

- (void)setFrequency:(double)freq {
    frequency = freq;
    sawtooth.freq = freq;
    square.freq = freq;
    triangle.freq = freq;
    noise.freq = freq;
}




- (void) createToneUnit {
    // Configure the search parameters to find the default playback output unit
    // (called the kAudioUnitSubType_RemoteIO on iOS but
    // kAudioUnitSubType_DefaultOutput on Mac OS X)
    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;
    
    // Get the default playback output unit
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
    NSAssert(defaultOutput, @"Can't find default output");
    
    // Create a new unit based on this that we'll use for output
    OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
    NSAssert1(toneUnit, @"Error creating unit: %ld", err);
    
    // Set our tone rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = RenderTone;
    input.inputProcRefCon = (self);
    err = AudioUnitSetProperty(toneUnit, 
                               kAudioUnitProperty_SetRenderCallback, 
                               kAudioUnitScope_Input,
                               0, 
                               &input, 
                               sizeof(input));
    NSAssert1(err == noErr, @"Error setting callback: %ld", err);
    
    // Set the format to 32 bit, single channel, floating point, linear PCM
    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = sampleRate;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;    
    streamFormat.mBytesPerFrame = four_bytes_per_float;        
    streamFormat.mChannelsPerFrame = 1;    
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    err = AudioUnitSetProperty (toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
    NSAssert1(err == noErr, @"Error setting stream format: %ld", err);

}

- (void) togglePlay
{
    if (!toneUnit)
    {
        
        // Set start time
        startTime = -1;
        
        // Create the audio unit as shown above
        [self createToneUnit];
        
        // Finalize parameters on the unit
        OSErr err = AudioUnitInitialize(toneUnit);
        NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
        
        // Start playback
        err = AudioOutputUnitStart(toneUnit);
        NSAssert1(err == noErr, @"Error starting unit: %ld", err);
        
    }
    else
    {
        // Tear it down in reverse
        AudioOutputUnitStop(toneUnit);
        AudioUnitUninitialize(toneUnit);
        AudioComponentInstanceDispose(toneUnit);
        toneUnit = nil;
    }
}
@end
