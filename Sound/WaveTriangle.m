//
//  WaveTriangle.m
//  Sound
//
//  Created by Lucas Correia on 2011-09-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WaveTriangle.h"

@implementation WaveTriangle

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        blit.bipolar = YES;
        prev = -0.5;
        prev2 = 0;
    }
    
    return self;
}

/*
 u[n] = x[n] + leak * u[n-1]
 y[n] = u[n] + leak * y[n-1]
 o[n] = const * y[n]
 */
- (float)nextValue {
    float sample = [blit nextValue];
    float scaling = 2 * 4.0f / [blit period]; // *2 since bipolar blit has period = period/2

    prev = sample + (1-kLeakRate) * prev;
    prev2 = prev + (1-kLeakRate) * prev2;
    return scaling*prev2;
}

@end
