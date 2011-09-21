//
//  WaveSawtooth.m
//  Sound
//
//  Created by Lucas Correia on 2011-09-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WaveSawtooth.h"

@implementation WaveSawtooth

- (id)init
{
    self = [super init];
    if (self) {
        prev = 0;
    }
    
    return self;
}



- (float)nextValue {
    float sample = [blit nextValue];
    float offset = 1.0 / blit.period;
    prev = (1-kLeakRate) * prev + sample - offset;
    return prev;
    
}



- (void) dealloc {
    [blit release];
    [super dealloc];
}

@end
