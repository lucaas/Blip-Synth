//
//  WaveNoise.h
//  Sound
//
//  Created by Lucas Correia on 2011-09-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaveNoise : NSObject {
    float white;
    float b0;
    float b1;
    float b2;
    float prevs[16];

    
    float freq;

}
@property (nonatomic, assign) float freq;

- (float)nextValue;
- (float)pinkNoise;
- (float)brownNoise;
- (float)whiteNoise;
@end
