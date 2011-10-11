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
@synthesize arpEnabled;
@synthesize arpMode;

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
        elapsed = 0.0;
        maxAmp = 1.0;
        
        LFOAmplitude = NO;
        lfoAmount = 0.5;
        lfoFreq = 10.0;
        
        arpEnabled = NO;
        arpMode = kArpSimple;
        arpPeriod = (int)sampleRate/4;
        arpIndex = 0;
        noteNumber = 60;
        
        
        // Generate MIDI signals
        double a5 = 440.0;
        for(int i=0;i<128;i++) { 
            //int note = i%12; 
            double noteFreq = (a5 / 32.0) * pow(2.0, (((double)i-9.0)/12.0)); 
            midi[i] = noteFreq;
        }
    }
    
    return self;
}


double linearInterpolation(double x, double x0, double x1, double y0, double y1) {
    return y0 + (x-x0) * ((y1-y0)/(x1-x0));
}

- (EnvelopeMode) envelopeMode {
    return envelopeMode;
}
- (void) setEnvelopeMode:(EnvelopeMode)_envelopeMode {
    active = YES;
    envelopeMode = _envelopeMode;
    elapsed = 0.0;
    NSLog(@"Changed envelope mode to: %d", envelopeMode);
}


-(double)adsrAmplitude {
    double amplitude = 0;
    if (envelopeMode == kAttack) {
        if (elapsed < attack) {
            double t0 = 0.0;
            double y0 = 0.0;
            // linear interpolation y0 -> maxAmp from t0 -> attack.
            amplitude = linearInterpolation(elapsed, t0, attack, y0, maxAmp);
        }
        else {
            elapsed = 0.0;
            amplitude = maxAmp;
            envelopeMode = kDecay;
        }
    }
    if (envelopeMode == kDecay ) {
        if (elapsed < decay) {
            double t0 = 0.0;
            // linear interpolation maxamp -> sustain from t0 -> decay.
            amplitude = linearInterpolation(elapsed, t0, decay, maxAmp, sustain);
        }
        else {
            elapsed = 0.0;
            amplitude = sustain;
            envelopeMode = kSustain;
        }
    }
    if (envelopeMode == kSustain) {
        amplitude = sustain;
    }
    if (envelopeMode == kRelease) {
        if ( elapsed < release) {
            double t0 = 0.0;
            double y1 = 0.0;
            // linear interpolation sustain -> 0 from t0 -> release.
            amplitude = linearInterpolation( elapsed, t0, release, sustain, y1);
        }
        else    {
            active = NO;
            amplitude = 0;
        }
    }
    
    
    //NSLog(@"mode: %d, elapsed: %2.2f < %2.2f ?, amp: %2.2f ", envelopeMode,  elapsed, attack, amplitude);
    return amplitude;

}

OSStatus RenderTone(
                    void *inRefCon, 
                    AudioUnitRenderActionFlags *ioActionFlags, 
                    const AudioTimeStamp *inTimeStamp, 
                    UInt32 inBusNumber, 
                    UInt32 inNumberFrames, 
                    AudioBufferList *ioData)

{    
    
    // Get the tone parameters out of the view controller
	Synthesizer *synthesizer = (Synthesizer *)(inRefCon);
    
    

    double amplitude = synthesizer->maxAmp;

    double theta = synthesizer->theta;
    double theta_increment = 2.0 * M_PI * synthesizer->frequency / synthesizer->sampleRate;   


    //int period = (int)(synthesizer->sampleRate / synthesizer->frequency);
             
    // This is a mono tone generator so we only need the first buffer
    const int channel = 0;
    Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
    
    // Generate the samples
    for (UInt32 frame = 0; frame < inNumberFrames; frame++) 
    {
        if (synthesizer->active) {
            
            static int sampleNumber = 0;
            ++sampleNumber;
            
        
            if (synthesizer->isADSR) {
                synthesizer->elapsed += (double) 1.0 / synthesizer->sampleRate;
                amplitude = [synthesizer adsrAmplitude];
            }
            
            // LFO, AMP
            double lfoAmplitude = amplitude;
            if (synthesizer->LFOAmplitude) {
                lfoAmplitude = amplitude + kMaxLFOAmplitude*synthesizer->lfoAmount*sin(2*M_PI*sampleNumber*synthesizer->lfoFreq/synthesizer->sampleRate);
            }
            
            // ARPEGGIO, change pitch every x seconds
            
            if (synthesizer->arpEnabled && sampleNumber % synthesizer->arpPeriod == 0) {
                [synthesizer doArp];
            }
            
            switch (synthesizer->waveType) {
            case kSinus:

                buffer[frame] =  lfoAmplitude * sin(theta);
                theta += theta_increment;
                if (theta > 2.0 * M_PI)
                {
                    theta -= 2.0 * M_PI;
                }
                break;
                
            case kSquare:
                buffer[frame] = lfoAmplitude * [synthesizer->square nextValue];
                break; 
                
            case kSawTooth:
                buffer[frame] = lfoAmplitude * [synthesizer->sawtooth nextValue];
                break;
                
            case kTriangle:
                buffer[frame] = lfoAmplitude * [synthesizer->triangle nextValue];
                break;
                
            case kNoise:
                buffer[frame] = lfoAmplitude * [synthesizer->noise nextValue];
                break;
                
            default:
                buffer[frame] = 0.0;

            }
        }
        else {
            buffer[frame] = 0.0;
        }
        
        // printf("%2.4f, ", buffer[frame]);

    }
    synthesizer->theta = theta;
    return noErr;
}

- (void)setArpFreq:(double)freq {
    arpPeriod = (int)sampleRate/freq;
}

- (void)doArp {
    static int arp1OffsetsLength = 6;
    static int arp1Offsets[6] = {0, 2, 4, 7, 4, 2};
    static int arp2OffsetsLength = 3;
    static int arp2Offsets[3] = {0, 7, 12};
    static int arp3OffsetsLength = 14;
    static int arp3Offsets[14] = {0, 2, 4, 5, 7, 9, 11, 12, 11, 9, 7, 5, 4, 2};   
    
    static int arp4OffsetsLength = 8;
    static int arp4Offsets[8] = {0, 12, 0, -12, 0, 7, 0,  -7 };
    
    int note = noteNumber;
    switch (arpMode) {
        case kArpBach:
            note += arp1Offsets[arpIndex++ % arp1OffsetsLength];
            break;        
        case kArpSimple:
            note += arp2Offsets[arpIndex++ % arp2OffsetsLength];
            break;        
        case kArpLong:
            note += arp3Offsets[arpIndex++ % arp3OffsetsLength];
            break;
        case kArp4:
            note += arp4Offsets[arpIndex++ % arp4OffsetsLength];
            break;
        default:
            break;
    }
    self.envelopeMode = kAttack;
    self.frequency = midi[note];
}


- (void)setPlay:(int)note {
    self.note = note;
    arpIndex = 0;
}
- (void)setNote:(int)note {
    self.envelopeMode = kAttack;
    noteNumber = note;
    self.frequency = midi[note];
}

- (void)setPitch:(float)pitch {
    int x0 = -2;
    int x1 = 2;
    double freq0 = midi[noteNumber + x0];
    double freq1 = midi[noteNumber + x1];
    self.frequency = linearInterpolation(pitch, x0, x1, freq0, freq1);
}

- (void)setFrequency:(double)freq {
    frequency = freq;
    sawtooth.freq = freq;
    square.freq = freq;
    triangle.freq = freq;
    noise.freq = freq;
}

- (void)setLFO:(BOOL)enabled forMode:(LFOMode)mode {
    if (mode == kLFOFreq) {
        sawtooth.LFOEnabled = enabled;
        square.LFOEnabled = enabled;
        triangle.LFOEnabled = enabled;
    }
    else {
        LFOAmplitude = enabled;
    }
}
- (void)setLFOFreq:(double)value forMode:(LFOMode)mode {
    if (mode == kLFOFreq) {
        sawtooth.LFOFreq = value;
        square.LFOFreq = value;
        triangle.LFOFreq = value;
    }
    else {
        lfoFreq = value;
    }
}

- (void)setLFOAmount:(double)freq forMode:(LFOMode)mode {
    if (mode == kLFOFreq) {
        sawtooth.LFOAmount = freq;
        square.LFOAmount = freq;
        triangle.LFOAmount = freq;        }
    else {
        lfoAmount = freq;
    }
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
        elapsed = 0.0;
        active = YES;
        
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
