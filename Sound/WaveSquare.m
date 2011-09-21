//
//  WaveSquare.m
//  Sound
//
//  Created by Lucas Correia on 2011-09-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WaveSquare.h"

@implementation WaveSquare

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        blit.bipolar = YES;
        prev = -0.5;
    }
    
    return self;
}


- (float)nextValue {
    float sample = [blit nextValue];
    prev = (1-kLeakRate) * prev + sample;
    return prev;
    
}


@end
