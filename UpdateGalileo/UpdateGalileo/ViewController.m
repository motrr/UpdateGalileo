//  Created by Chris Harding on 3/3/13.
//  Copyright (c) 2013 Chris Harding. All rights reserved.
//

#import "ViewController.h"
#import <GalileoControl/GalileoControl.h>

@interface ViewController () <GCGalileoDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Start waiting for Galileo to connect
    [self printInfo: @"Connect Galileo to begin"];
    [GCGalileo sharedGalileo].delegate = self;
    [[GCGalileo sharedGalileo] waitForConnection];
}

- (void) printInfo: (NSString*) infoString
{
    NSString *newInfoString = [self.infoTextView.text stringByAppendingFormat:@"%@\n", infoString];
    [self.infoTextView performSelectorOnMainThread:@selector(setText:) withObject:newInfoString waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark GalileoDelegate methods

- (void) galileoDidConnect
{
    [self enableUI];
    [self printInfo: @"Galileo connected"];
}

- (void) enableUI
{
    self.checkButton.enabled = true;
}

- (void) galileoDidDisconnect
{
    [self disableUI];
    [self printInfo: @"Galileo disconnected"];
    [[GCGalileo sharedGalileo] waitForConnection];
}

- (void) disableUI
{
    self.checkButton.enabled = false;
}


#pragma -
#pragma mark Button handler

- (IBAction)checkForUpdates:(id)sender
{
    [self printInfo: @"Checking for updates..."];
    
    // Check for updates and if available, launch the motrr app to install them
    [[[GCGalileo sharedGalileo] firmwareManager] checkForUpdate:
        ^(GCFirmwareUpdateCheckOutcome outcome)
        {
            switch (outcome) {
                case GCFirmwareUpdateCheckOutcomeConnectionUnavailable:
                    [self printInfo:@"Connection unavailable."];
                    break;
                    
                case GCFirmwareUpdateCheckOutcomeAlreadyUpToDate:
                    [self printInfo:@"Firmware is already up to date."];
                    break;
                    
                case GCFirmwareUpdateCheckOutcomeUpdateAvailable: {
                    [[[GCGalileo sharedGalileo] firmwareManager] promptUserToUpdate:^(){
                        [self printInfo:@"Update check complete."];
                    }];
                    break;
                }
                    
                case GCFirmwareUpdateDeviceUnavailable:
                    [self printInfo:@"Device unavailable."];
                    break;
                    
                default:
                    [self printInfo:@"Unknown GCFirmwareUpdateCheckOutcome returned."];
                    break;
            }
        }
     ];
}

@end
