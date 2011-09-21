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

- (id)init
{
    self = [super init];
    if (self) {
        fs = kSampleRate;
        freq = 440;
        period = fs/freq;
        periodFrac = period - (int)period;
        phase = period/4;
        impulseSampleIndex = 100;
        sign = 1;
        bipolar = NO;
    }
    
    return self;
}


- (float)nextValue {
    
    // Phase counter, trigger blit
    if ((--phase) < 0) {
        
        if (bipolar) {
            sign *= -1;
            period = fs/freq/2.0;
        }
        else {
            period = fs/freq;
        }
        
        periodFrac = period - (int)period;
        phase += period;
        
        impulseSampleIndex = -1;
    }
    
    // Blit triggered
    if (impulseSampleIndex <= 2) {
        float value = sign * [self bspline3:(impulseSampleIndex-periodFrac)];
        ++impulseSampleIndex;
        return value;
    }
    
    return 0;
        
}

- (float)bspline3:(float) a {
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



/*
 clear fs f T Ts D0 phase blit m;
 len = 5.0;
 
 fs = 44100; % sample rate (Hz)
 N = floor(len*fs);
 
 f = 110; % frequency (Hz)
 T = 1/f; % period (s)
 Ts = 1/fs; % sample period
 D0 = T / Ts; % period of the bandlimited impulse train in samples
 
 phase = D0/4; % phase counter
 m = 100;     % init variables
 blit = zeros(1,N);
 positive = -1;
 
 for n = 1:N
 
 f = f + (5000-110)/N; % frequency (Hz)
 T = 1/f; % period (s)
 Ts = 1/fs; % sample period
 D0 = T / Ts; % period of the bandlimited impulse train in samples
 
 phase = phase - 1;
 if (phase < 0)
 phase = phase + D0/2;
 m = -1;
 positive = -1 * positive;
 end
 
 if  m <= 2
 D = D0;
 Dint = floor(D); % int part of m*D0
 d = D - Dint; % frac part of m*d0
 %blit(n) = blit(n) + bspline3(n - Dint - d);
 blit(n) = blit(n) + positive*bspline3(m - d);
 m = m + 1;
 end
 end
 figure;
 subplot(2,1,1);
 stem(1:floor(2*D0), blit(1:floor(2*D0)));
 subplot(2,1,2);
 freqplot(blit,fs);
*/