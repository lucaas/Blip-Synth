//
//  SoundViewController.m
//  Sound
//
//  Created by Lucas Correia on 2011-09-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundViewController.h"

@implementation SoundViewController
@synthesize synthesizer;
@synthesize freqLabel;
@synthesize freqSlider;
@synthesize lfoSwitch;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    /*
	// Do any additional setup after loading the view, typically from a nib.
    midi[0] = 261.626; // C4
    midi[1] = 277.183;
    midi[2] = 293.665;
    midi[3] = 311.127;
    midi[4] = 329.628;
    midi[5] = 349.228;
    midi[6] = 369.994;
    midi[7] = 391.995;
    midi[8] = 415.305;
    midi[9] = 440.000;
    midi[10] = 466.164;
    midi[11] = 493.883;
    midi[12] = 523.251;
    midi[13] = 554.365;
    midi[14] = 587.330;
    midi[15] = 622.254; // D5
    */
    
    // Set up buttons
    UIImage *keyImage = [UIImage imageNamed:@"key.png"];
    UIImage *keyPressedImage = [UIImage imageNamed:@"key-pressed.png"];
    int margin = 32;
    int width = 64;
    int height = 256;
    int top = 768-height-margin;
    for (int i=0; i < 15; ++i) {
        UIButton *key = [[[UIButton alloc] initWithFrame:CGRectMake(margin+i*width, top, width, height)] autorelease];
        [key setImage:keyImage forState:UIControlStateNormal];
        [key setImage:keyPressedImage forState:(UIControlStateHighlighted|UIControlStateSelected)];
        key.tag = i;
        [key addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchDown];
        [key addTarget:self action:@selector(keyUp:) forControlEvents:(UIControlEventTouchCancel | 
                                                                       UIControlEventTouchDragExit | 
                                                                       UIControlEventTouchUpInside | 
                                                                       UIControlEventTouchUpOutside)];
        [self.view addSubview:key];
    
    }
    
    // Set up ADSR sliders
    NSArray *adsrTexts = [NSArray arrayWithObjects:@"A", @"D", @"S", @"R", nil];
    for (int i=0; i < 4; ++i) {
        int left = 700;
        int margin = 8;
        int width = 32;
        int height = 192;
        int top = 150;
        
        int leftvalue = left+i*(width+margin);
        CGRect sliderFrame = CGRectMake(leftvalue, top, height, width);
        UISlider *slider = [[[UISlider alloc] initWithFrame:sliderFrame] autorelease];
        slider.tag = i;
        [slider addTarget:self action:@selector(ADSRChanged:) forControlEvents:UIControlEventValueChanged];
        CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * -0.5);
        slider.transform = trans;
        [self.view addSubview:slider];
        
        sliderFrame = slider.frame;
        CGRect labelFrame = CGRectMake(sliderFrame.origin.x, sliderFrame.origin.y + sliderFrame.size.height, width+margin, width);
        UILabel *label = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:width];
        label.text = [adsrTexts objectAtIndex:i];
        [self.view addSubview:label];
        
    }
    
    // Synth
    self.synthesizer = [[Synthesizer alloc] init];
}

- (void)viewDidUnload
{
    [self setFreqLabel:nil];
    [self setFreqSlider:nil];
    [self setLfoMode:nil];
    [self setLfoSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.synthesizer = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc {
    [lfoSwitch release];
    [super dealloc];
}

#pragma mark -
#pragma mark IBAction
- (IBAction)startButtonTapped:(id)sender {
    [synthesizer togglePlay];
}

- (IBAction)freqValueChanged:(UISlider *)sender {
    synthesizer.frequency = sender.value;
    freqLabel.text = [NSString stringWithFormat:@"Frequency %4.0f Hz", sender.value];
    
}

- (void)ADSRChanged:(UISlider *)sender {
    switch (sender.tag) {
        case ATTACK:
            synthesizer.attack = sender.value;
            break;        
        case DECAY:
            synthesizer.decay = sender.value;
            break;        
        case SUSTAIN:
            synthesizer.sustain = sender.value;
            break;        
        case RELEASE:
            synthesizer.release = sender.value;
            break;
    }
}

-(void)keyPressed:(UIButton *)sender {
    synthesizer.envelopeMode = kAttack;
    int noteNumber = sender.tag + kC4Number;
    synthesizer.note = noteNumber;
    //synthesizer.frequency = midi[sender.tag];
    freqLabel.text = [NSString stringWithFormat:@"Frequency %4.0f Hz", synthesizer.midi[noteNumber]];
    freqSlider.value = synthesizer.midi[noteNumber];
}

-(void)keyUp:(UIButton *)sender {
    synthesizer.envelopeMode = kRelease;
}

- (IBAction)soundTypeChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            synthesizer.waveType = kSinus;
            break;
        case 1:
            synthesizer.waveType = kSquare;
            break;
        case 2:
            synthesizer.waveType = kSawTooth;
            break;        
        case 3:
            synthesizer.waveType = kTriangle;
            break;        
        case 4:
            synthesizer.waveType = kNoise;
            break;
    }
}

- (IBAction)ADSRSwitchChanged:(UISwitch *)sender {
    synthesizer.isADSR = sender.on;
}

- (IBAction)LFOSwitchChanged:(UISwitch *)sender {
    [synthesizer setLFO:sender.on forMode:sender.tag];

}
- (IBAction)LFOFreqChanged:(UISlider *)sender {
    [synthesizer setLFOFreq:sender.value forMode:sender.tag];
}

- (IBAction)LFOAmountChanged:(UISlider *)sender {
    [synthesizer setLFOAmount:sender.value forMode:sender.tag];
}

- (IBAction)arpSwitchChanged:(UISwitch *)sender {
    synthesizer.arpEnabled = sender.on;
}

- (IBAction)arpModeChanged:(UISegmentedControl *)sender {
    synthesizer.arpMode = sender.selectedSegmentIndex;
}

- (IBAction)arpFreqChanged:(UISlider *)sender {
    synthesizer.arpFreq = sender.value;
}

@end
