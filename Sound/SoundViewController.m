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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
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
        [self.view addSubview:key];
    
    }
    
    // Synth
    self.synthesizer = [[Synthesizer alloc] init];
}

- (void)viewDidUnload
{
    [self setFreqLabel:nil];
    [self setFreqSlider:nil];
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

- (IBAction)startButtonTapped:(id)sender {
    [synthesizer togglePlay];
}

- (IBAction)freqValueChanged:(UISlider *)sender {
    synthesizer.frequency = sender.value;
    freqLabel.text = [NSString stringWithFormat:@"Frequency %4.0f Hz", sender.value];
    
}

-(void)keyPressed:(UIButton *)sender {
    synthesizer.frequency = midi[sender.tag];
    freqLabel.text = [NSString stringWithFormat:@"Frequency %4.0f Hz", midi[sender.tag]];
    freqSlider.value = midi[sender.tag];
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
    }
}
- (void)dealloc {
    [super dealloc];
}
@end
