//
//  BLIT.m
//  Sound
//
//  Created by Lucas Correia on 2011-09-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BLIT.h"

@implementation BLIT
@synthesize period;
@synthesize freq;
@synthesize bipolar;
@synthesize tremolo;
@synthesize lfoFreq;
@synthesize lfoAmount;

- (id)init
{
    self = [super init];
    if (self) {
        fs = kSampleRate;
        freq = 440;
        period = fs/freq;
        phase = period/4;

        sign = 1;
        bipolar = NO;
        tremolo = NO;
        
        lfoFreq = 10.0; // Hz
        lfoAmount = 0.5; // Hz deviation +/-
    }
    
    return self;
}

- (double)lfoFreq {
    // LFO, FREQ
    static int sampleNumber = 0;
    ++sampleNumber;
    return freq + lfoAmount*40.0*sin(2*M_PI*sampleNumber*lfoFreq/fs);
}

- (double)nextValue {
    
    double newFreq = freq;
    if (tremolo) {
        newFreq = [self lfoFreq];
    }
    
    // Phase counter, trigger blit
    if ((--phase) < -2) {
        
        if (bipolar) {
            sign *= -1;
            period = fs/newFreq/2.0;
        }
        else {
            period = fs/newFreq;
        }
        
        //periodFrac = period - (int)period;
        phase += period;
    }
    
    // Blit triggered
    if (phase <= 2) {
        double value = sign * [self bspline3:(phase)];
        return value;
    }
    
    return 0.0;
        
}

- (double)bspline3:(float) a {
    if (a < -2 || a >= 2)
        return 0;
    else if (a < -1)
        return (1.0/6.0) * pow((2+a),3);
    else if (a < 0)
        return (2.0/3.0) - pow(a,2) - (1.0/2.0)*pow(a,3);
    else if (a < 1)
        return (2.0/3.0) - pow(a,2) + (1.0/2.0)*pow(a,3);
    else // a = [1,2[
        return (1.0/6.0) * pow((2-a),3);
}


@end
