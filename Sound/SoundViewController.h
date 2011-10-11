//
//  SoundViewController.h
//  Sound
//
//  Created by Lucas Correia on 2011-09-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Synthesizer.h"

#define kC4Number 60
#define kLFOAmp 0
#define kLFOFreq 1

@interface SoundViewController : UIViewController {

    Synthesizer *synthesizer;
    UILabel *freqLabel;
    UISlider *freqSlider;
    UISwitch *lfoSwitch;
    UIScrollView *keysScrollView;
    
    NSMutableArray *keyboard;
    
    
    
}
@property (nonatomic, retain) Synthesizer *synthesizer;
@property (nonatomic, retain) IBOutlet UILabel *freqLabel;
@property (nonatomic, retain) IBOutlet UISlider *freqSlider;
@property (nonatomic, retain) IBOutlet UISwitch *lfoSwitch;
@property (nonatomic, retain) IBOutlet UIScrollView *keysScrollView;

- (IBAction)startButtonTapped:(id)sender;
- (IBAction)freqValueChanged:(id)sender;
- (IBAction)soundTypeChanged:(id)sender;
- (IBAction)ADSRSwitchChanged:(id)sender;
- (IBAction)LFOSwitchChanged:(id)sender;
- (IBAction)LFOFreqChanged:(id)sender;
- (IBAction)LFOAmountChanged:(id)sender;
- (IBAction)arpSwitchChanged:(id)sender;
- (IBAction)arpModeChanged:(id)sender;
- (IBAction)arpFreqChanged:(id)sender;
- (IBAction)changeKeysPage:(id)sender;
- (IBAction)pitchValueChanged:(id)sender;
- (IBAction)pitchValueStopped:(id)sender;

@end
