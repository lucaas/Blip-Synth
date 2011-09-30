//
//  WaveNoise.m
//  Sound
//
//  Created by Lucas Correia on 2011-09-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WaveNoise.h"

@implementation WaveNoise
@synthesize freq;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        white = 0;
        b0 = 0;
        b1 = 0;
        b2 = 0;
        
        for (int i = 0; i < 16; ++i) {
            prevs[i] = 0;
        }
    }
    
    return self;
}

- (float) nextValue {
    /*
     [self whiteNoise];
    int amount = (int)16*((freq - 250) / (650-250));
    amount = (amount > 15) ? 15 : amount;
    amount = (amount < 1) ? 1 : amount;
    amount = 16 - amount;
    int i = 0;
    float sum = 0;
    for (; i < amount - 1; ++i) {
        prevs[i] = prevs[i+1];
        sum += 0.9 * prevs[i];
    }
    sum = (sum > 1) ? 1 : sum;
    sum = (sum < -1) ? -1 : sum;
    sum = sum + 1.0f/amount *white;
    prevs[i+1] = sum;
    //NSLog(@"noise sum: %d, %f", i, sum);
    return sum;
    */
    
    if (freq < 300)
        return [self brownNoise];
    if (freq < 450)
        return [self pinkNoise];
    else
        return [self whiteNoise];
     
    
    
}
- (float)brownNoise {
    [self whiteNoise];
    return b0 = 0.9 * b0 + 0.5 * white;
}

- (float)whiteNoise {
    return white = (((float) rand() / RAND_MAX) * 2.0f) - 1.0f;
}

- (float)pinkNoise {
    //white = 2.0f*(arc4random_uniform(INT32_MAX)/(float)(INT32_MAX)) - 1.0f; // uniform [-1,1]
    [self whiteNoise];
    b0 = 0.99765 * b0 + white * 0.0990460;
    b1 = 0.96300 * b1 + white * 0.2965164;
    b2 = 0.57000 * b2 + white * 1.0526913;
   return b0 + b1 + b2 + white * 0.1848;
    //NSLog(@"pink: %1.2f , white: %1.2f", pink, white);
}
@end
