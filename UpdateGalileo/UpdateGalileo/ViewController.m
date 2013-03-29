//
//  ViewController.m
//  UpdateGalileo
//
//  Created by Chris Harding on 3/3/13.
//  Copyright (c) 2013 Chris Harding. All rights reserved.
//

#import "ViewController.h"
#import <GalileoControl-private/GalileoControl+Private.h>

@interface ViewController () <GalileoDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Start waiting for Galileo to connect
    [self printInfo: @"Connect Galileo to begin"];
    [Galileo sharedGalileo].delegate = self;
    [[Galileo sharedGalileo] waitForConnection];
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
    [[Galileo sharedGalileo] waitForConnection];
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
    //[[[Galileo sharedGalileo] firmwareManager] checkForUpdateOnCompletion:nil];
    
    // Since the motrr app is not yet available, this TEMPORARY solution will update Galileo's firmware (without leaving the app) to the latest public release. Note that this method uses a private motrr framework and should not be copied by third party developers.
    [[[Galileo sharedGalileo] firmwareManager] getAvailableReleasesForGroup: @"public"
                                                               onCompletion:
     ^(NSArray* firmwareVersionStrings)
     {
         // Check if we returned any results at all
         if (firmwareVersionStrings != nil && [firmwareVersionStrings count] > 0) {
             
             // Get the most recent version
             unsigned int latestFirmwareVersion = 0;
             for (NSString* firmwareVersionString in firmwareVersionStrings) {
                 if ([firmwareVersionString intValue] > latestFirmwareVersion) latestFirmwareVersion = [firmwareVersionString intValue];
             }
             
             // Check to see if an update is available to the current version
             unsigned int currentFirmwareVersion = [[Galileo sharedGalileo] firmwareVersion];
             if (currentFirmwareVersion < latestFirmwareVersion) {
                 
                 [self printInfo: [NSString stringWithFormat:@"Update is available from current version %u to latest version %u", currentFirmwareVersion, latestFirmwareVersion]];
                 
                 // Prompt user to install update, this will require switching to the motrr LAUNCH app
                 [[[Galileo sharedGalileo] firmwareManager] downloadAndInstallRelease:[NSString stringWithFormat:@"%u", latestFirmwareVersion] onCompletion:nil];
             }
             else {
                 [self printInfo: [NSString stringWithFormat:@"Current version %u is already most recent available.", currentFirmwareVersion]];
             }
             
         }
     }
     ];
}



@end
