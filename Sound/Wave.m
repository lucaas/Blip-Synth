//
//  Wave.m
//  Sound
//
//  Created by Lucas Correia on 2011-09-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Wave.h"

@implementation Wave

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        blit = [[BLIT alloc] init];
        prev = 0;
    }
    
    return self;
}


- (void)setFreq:(float)freq {
    blit.freq = freq;
}

- (void)setLFOEnabled:(BOOL)enabled {
    blit.tremolo = enabled;
}

- (void)setLFOAmount:(double)freq {
    blit.lfoAmount = freq;
}

- (void)setLFOFreq:(double)freq {
    blit.lfoFreq = freq;
}

@end
