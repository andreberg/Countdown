//
//  CDPrefsController.m
//  Countdown
//
//  Created by Andre Berg on 20.03.10.
//  Copyright 2010 Berg Media. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "CDPrefsController.h"

NSString * CDActionTypeKey = @"ActionType";
NSString * CDActionTextKey = @"ActionText";
NSString * CDTimeUnitKey = @"TimeUnit";
NSString * CDLastTimerValueKey = @"LastTimeValue";
NSString * CDLogOutputVerboseKey = @"LogOutputVerbose";
NSString * CDUpdateIntervalKey = @"TimeUpdateInterval";

NSString * CDLogOutputVerboseChangedNotification = @"LogOutputVerboseChangedNotification";
NSString * CDLogOutputVerboseChangedNotificationNewValueKey = @"newValue";

static CDPrefsController * sharedInstance = nil;

@implementation CDPrefsController

- (id) init {
    [self initWithWindowNibName:@"Preferences"];
    [self setupDefaults];
    logOutputVerbose = [DEFAULTS boolForKey:CDLogOutputVerboseKey];
    updateInterval = [DEFAULTS doubleForKey:CDUpdateIntervalKey];    
    return self;
}

- (void) awakeFromNib {
}

// MARK: Singleton Creation

+ (void) initialize {
    if (sharedInstance == nil) {
        sharedInstance = [[self alloc] init];
    }
}

+ (id) sharedPrefsController {
    // Already set by +initialize.
    return sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone {
    // Usually already set by +initialize.
    if (sharedInstance) {
        // The caller expects to receive a new object, so implicitly retain it
        // to balance out the eventual release message.
        return [sharedInstance retain];
    } else {
        // When not already set, +initialize is our caller.
        // It's creating the shared instance, let this go through.
        return [super allocWithZone:zone];
    }
}

// MARK: Singleton Overrides

- (id) copyWithZone:(NSZone *)zone {
    return self;
}
- (id) retain {
    return self;
}
- (NSUInteger) retainCount {
    return UINT_MAX; // denotes an object that cannot be released
}
- (void) release {
    // do nothing
}
- (id) autorelease {
    return self;
}

// MARK: Actions

- (IBAction) showWindow:(id)sender {
    if (![self window]) {
        [NSBundle loadNibNamed:@"Preferences" owner:self];
    }
    [NSApp beginSheet:[self window] modalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(didEndSheet:) contextInfo:nil];
}

- (IBAction) closeWindow:(id)sender {
	[NSApp endSheet:[self window]];
}

- (IBAction) logOutputVerboseClicked:(id)sender {
    if ([sender state] == 0) {
        logOutputVerbose = NO;
    } else {
        logOutputVerbose = YES;
    }
    NSDictionary * info = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:logOutputVerbose] forKey:CDLogOutputVerboseChangedNotificationNewValueKey];
    [CENTER postNotificationName:CDLogOutputVerboseChangedNotification object:PREFS userInfo:info];
}

- (IBAction) savePrefsAndCloseWindow:(id)sender {
    [DEFAULTS_CONTROLLER save:sender];
    [DEFAULTS synchronize];
    [NSApp endSheet:self.window];
}

- (void) didEndSheet:(NSPanel *)sheet {
	[sheet orderOut:self];
}

// MARK: Methods

- (void) setupDefaults {
    NSString * defaultsPlist = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
    NSDictionary * defaultsDict = [NSDictionary dictionaryWithContentsOfFile:defaultsPlist];
    [DEFAULTS registerDefaults:defaultsDict];
    [DEFAULTS_CONTROLLER setInitialValues:defaultsDict];	
}

// MARK: Synthesized Properties

@synthesize logOutputVerbose;
@synthesize updateInterval;
@end
