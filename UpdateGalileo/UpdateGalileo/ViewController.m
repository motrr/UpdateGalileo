//
//  ViewController.m
//  UpdateGalileo
//
//  Created by Chris Harding on 3/3/13.
//  Copyright (c) 2013 Chris Harding. All rights reserved.
//

#import "ViewController.h"
#import <GalileoControl/GalileoControl.h>

@interface ViewController () <GalileoDelegate, FirmwareManagerDelegate>

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
    [[[Galileo sharedGalileo] firmwareManager] setDelegate:self];
    [[[Galileo sharedGalileo] firmwareManager] checkForUpdate];
}


#pragma -
#pragma mark FirmwareManagerDelegate methods

- (void) checkForUpdateComplete: (BOOL) isUpdateAvailable
{
    if (isUpdateAvailable)  {
        [self printInfo:@"Found update, prompting user to install..."];
        [[[Galileo sharedGalileo] firmwareManager] promptUserToInstallUpdate];
    }
    else                    [self printInfo:@"No updates available"];
}

- (void) performUpdateComplete: (BOOL) wasUpdateSuccessful
{
    [self printInfo:@"Update completed succesfully"];
}

@end
