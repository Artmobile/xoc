//
//  xocViewController.m
//  xoc
//
//  Created by Ilya Alberton on 3/13/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import "xocViewController.h"
#import "PlistHandler.h"

@implementation xocViewController


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    
    [caption release];
    caption = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [caption release];
        [super dealloc];
}

- (IBAction)onTouch:(id)sender {
    PlistHandler* handler = [[PlistHandler alloc] init];

    [caption setText:[handler inject:@"Hi there"]];
    
    [handler release];
}
@end
