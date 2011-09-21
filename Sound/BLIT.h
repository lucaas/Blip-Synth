//
//  BLIT.h
//  Sound
//
//  Created by Lucas Correia on 2011-09-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kSampleRate 44100;

@interface BLIT : NSObject {
    int fs;                 // sample rate (hz)
    float freq;                // frequency (hz)
    float period;           // period of the bandlimited impulse train in samples
    float periodFrac;      // Fractional part of period
    float phase;            // Phase counter
    int impulseSampleIndex;                  // impulse sample number
    int sign;               // Sign of impulse
    BOOL bipolar;           // YES => bipolar impulses, NO => normal
    
}
@property (nonatomic, readonly) float period;
@property (nonatomic, assign) float freq;
@property (nonatomic, assign) BOOL bipolar;


- (float)bspline3:(float) a;
- (float)nextValue;

@end
