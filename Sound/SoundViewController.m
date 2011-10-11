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
@synthesize lfoSwitch;
@synthesize keysScrollView;
@synthesize holdSwitch;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];

    
    // Set up buttons
    UIImage *keyLeftImage = [UIImage imageNamed:@"key-left.png"];
    UIImage *keyLeftPressedImage = [UIImage imageNamed:@"pressed-left.png"];
    UIImage *keyRightImage = [UIImage imageNamed:@"key-right.png"];
    UIImage *keyRightPressedImage = [UIImage imageNamed:@"pressed-right.png"];
    UIImage *keyBothImage = [UIImage imageNamed:@"key-both.png"];
    UIImage *keyBothPressedImage = [UIImage imageNamed:@"pressed-both.png"];
    UIImage *keyNoneImage = [UIImage imageNamed:@"key-none.png"];
    UIImage *keyNonePressedImage = [UIImage imageNamed:@"pressed-none.png"];
    UIImage *keyBlackImage = [UIImage imageNamed:@"key-black.png"];
    UIImage *keyBlackPressedImage = [UIImage imageNamed:@"pressed-black.png"];
    int width = 64;
    int height = 256;
    int top = 0;
    int firstKey = 21; // A0
    int lastKey = 108; // C8
    int numKeys = lastKey - firstKey;
    NSArray *labels = [NSArray arrayWithObjects:@"C1",@"C2",@"C3",@"C4",@"C5",@"C6",@"C7",@"C8", nil];
    for (int i=0; i <= numKeys; ++i) {
        UIButton *key = [[[UIButton alloc] initWithFrame:CGRectMake(i*width, top, width, height)] autorelease];

        int kn = i % 12;
        if (kn == 1 || kn == 4 || kn == 6 || kn == 9 || kn == 11) {
            [key setImage:keyBlackImage forState:UIControlStateNormal];
            [key setImage:keyBlackPressedImage forState:(UIControlStateHighlighted|UIControlStateSelected)];
        }
        else if (kn == 0 || kn == 5 || kn == 10) {
            [key setImage:keyBothImage forState:UIControlStateNormal];
            [key setImage:keyBothPressedImage forState:(UIControlStateHighlighted|UIControlStateSelected)];
        }
        else if (kn == 2 || kn == 7) {
            [key setImage:keyLeftImage forState:UIControlStateNormal];
            [key setImage:keyLeftPressedImage forState:(UIControlStateHighlighted|UIControlStateSelected)];
        }       
        else if (kn == 3 || kn == 8) {
            [key setImage:keyRightImage forState:UIControlStateNormal];
            [key setImage:keyRightPressedImage forState:(UIControlStateHighlighted|UIControlStateSelected)];
        }
        else {
            [key setImage:keyNoneImage forState:UIControlStateNormal];
            [key setImage:keyNonePressedImage forState:(UIControlStateHighlighted|UIControlStateSelected)];
            
        }
        
        if (kn == 3) {
            // Create the label and set its text
            CGRect labelFrame = CGRectMake(0, 192, 64, 64);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont boldSystemFontOfSize:24.0f];
            label.textColor = [UIColor darkGrayColor];
            label.textAlignment = UITextAlignmentCenter;
            [label setText:[labels objectAtIndex:(int)(i/12)]];
            [key addSubview:label];
        }
        
        key.tag = i + firstKey;
        [key addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchDown];
        [key addTarget:self action:@selector(keyUp:) forControlEvents:(UIControlEventTouchCancel | 
                                                                       UIControlEventTouchDragExit | 
                                                                       UIControlEventTouchUpInside | 
                                                                       UIControlEventTouchUpOutside)];
        [self.keysScrollView addSubview:key];
    
    }
    keysScrollView.contentSize = CGSizeMake((numKeys+1)*width, height);
    keysScrollView.contentMode = UIViewContentModeTop;
    CGRect frame = keysScrollView.frame;
    frame.origin.x = frame.size.width * 3;
    frame.origin.y = 0;
    [keysScrollView scrollRectToVisible:frame animated:YES];
    
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
    [self setLfoSwitch:nil];
    [self setKeysScrollView:nil];
    [self setHoldSwitch:nil];
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
    [keysScrollView release];
    [holdSwitch release];
    [super dealloc];
}

#pragma mark -
#pragma mark IBAction
- (IBAction)startButtonTapped:(id)sender {
    [synthesizer togglePlay];
}

- (IBAction)freqValueChanged:(UISlider *)sender {
    float offset = sender.value/(sender.maximumValue - sender.minimumValue) * keysScrollView.contentSize.width;
    if (offset > keysScrollView.contentSize.width - keysScrollView.frame.size.width)
        offset = keysScrollView.contentSize.width - keysScrollView.frame.size.width;
    keysScrollView.contentOffset = CGPointMake(offset, 0);
    //synthesizer.frequency = sender.value;
    //freqLabel.text = [NSString stringWithFormat:@"Frequency %4.0f Hz", sender.value];    
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
    int noteNumber = sender.tag;
    synthesizer.play = noteNumber;
}

-(void)keyUp:(UIButton *)sender {
    if (holdSwitch.on == NO)
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

- (IBAction)changeKeysPage:(UISegmentedControl *)sender {
    
    int direction = 1;
    if (sender.selectedSegmentIndex == 0)
        direction = -1;
    
    sender.selectedSegmentIndex = -1;
    
    float x = keysScrollView.contentOffset.x + direction * 64 * 12;
    float maxOffsetX = keysScrollView.contentSize.width - keysScrollView.frame.size.width;
    x = (x < 0) ? 0 : x;
    x = (x > maxOffsetX) ? maxOffsetX : x;
    
    [keysScrollView setContentOffset:CGPointMake(x, 0) animated:YES];

}

- (IBAction)pitchValueChanged:(UISlider *)sender {
    synthesizer.pitch = sender.value;
}

- (IBAction)pitchValueStopped:(UISlider *)sender {
    sender.value = 0.0;
    synthesizer.pitch = sender.value;

}

@end
