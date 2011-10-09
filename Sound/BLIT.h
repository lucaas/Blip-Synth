//
//  BLIT.h
//  Sound
//
//  Created by Lucas Correia on 2011-09-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kSampleRate 44100;
#define kMaxLFOAmount 40.0;

@interface BLIT : NSObject {
    int fs;                 // sample rate (hz)
    float freq;                // frequency (hz)
    float period;           // period of the bandlimited impulse train in samples
    float phase;            // Phase counter
    int sign;               // Sign of impulse
    BOOL bipolar;           // YES => bipolar impulses, NO => normal
    
    // LFO
    BOOL tremolo;           // YES => use LFO to generate tremolo
    double lfoAmount;
    double lfoFreq;
    
}
@property (nonatomic, readonly) float period;
@property (nonatomic, assign) float freq;
@property (nonatomic, assign) BOOL bipolar;

@property (nonatomic, assign) BOOL tremolo;
@property (nonatomic, assign) double lfoAmount;
@property (nonatomic, assign) double lfoFreq;



- (double)bspline3:(float) a;
- (double)lfoFreq;
- (double)nextValue;
@end
