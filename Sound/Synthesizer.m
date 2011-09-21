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
@synthesize waveType;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        sampleRate = 44100.00;
        frequency = 440; // Hz
       theta = M_PI / 2;
    }
    
    return self;
}

double sinvalue(double angle, double amplitude) {
    return sin(angle) * amplitude;
}

double square(double angle, double amplitude) {
    double sign = (sin(angle) > 0)  ? 1 : -1;
    return sign * amplitude;
}

double sawtooth(double angle, double amplitude, double sampleRate) {
    double value = 0;
    for (int k = 1; k < 24; ++k) {
        value += sin(k*angle) / k;
    }
    value *= amplitude * -2 / M_PI;
    return value;

}

double triangle(int period, int frame, double amplitude) {
    // This gives a triangular wave of period 6, oscillating between 3 and 0.
    // http://stackoverflow.com/questions/1073606/is-there-a-one-line-function-that-generates-a-triangle-wave
    // y = abs((x++ % 6) - 3);
    
    double value = amplitude * (2.0/period) * abs((frame % period) - period/2);
    return value;
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
    const double amplitude = 0.25;
    
    // Get the tone parameters out of the view controller
	Synthesizer *synthesizer = (Synthesizer *)(inRefCon);
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
                buffer[frame] = square(theta, amplitude);
                break;            
            case kSawTooth:
                buffer[frame] = sawtooth(theta, amplitude, synthesizer->sampleRate);
                break;
            case kTriangle:
                buffer[frame] = triangle(period, frame, amplitude);
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
