//
//  Wave.h
//  Sound
//
//  Created by Lucas Correia on 2011-09-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLIT.h"

#define kLeakRate 0.01

@interface Wave : NSObject {
    BLIT *blit;
    float prev;
}


- (void)setFreq:(float)freq;
- (float)nextValue;

- (void)setLFOEnabled:(BOOL)enabled;
- (void)setLFOFreq:(double)freq;
- (void)setLFOAmount:(double)freq;

@end
