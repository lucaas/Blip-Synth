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
@synthesize phaseLabel;

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
    self.synthesizer = [[Synthesizer alloc] init];
}

- (void)viewDidUnload
{
    [self setFreqLabel:nil];
    [self setPhaseLabel:nil];
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

- (IBAction)phaseValueChanged:(UISlider *)sender {
    synthesizer.theta = sender.value * 2 * M_PI;
    phaseLabel.text = [NSString stringWithFormat:@"Phase %1.1f", sender.value];
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
    [freqLabel release];
    [phaseLabel release];
    [super dealloc];
}
@end
