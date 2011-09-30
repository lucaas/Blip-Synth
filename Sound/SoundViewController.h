//
//  SoundViewController.h
//  Sound
//
//  Created by Lucas Correia on 2011-09-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Synthesizer.h"
@interface SoundViewController : UIViewController {

    Synthesizer *synthesizer;
    UILabel *freqLabel;
    UISlider *freqSlider;
    
    NSMutableArray *keyboard;
    
    float midi[16];
    
}
@property (nonatomic, retain) Synthesizer *synthesizer;
@property (nonatomic, retain) IBOutlet UILabel *freqLabel;
@property (nonatomic, retain) IBOutlet UISlider *freqSlider;

- (IBAction)startButtonTapped:(id)sender;
- (IBAction)freqValueChanged:(id)sender;
- (IBAction)soundTypeChanged:(id)sender;
- (IBAction)ADSRSwitchChanged:(id)sender;

@end
