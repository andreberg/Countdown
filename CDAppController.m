//
//  CDAppController.m
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

#import "CDAppController.h"
#import "CDAction.h"
#import "CDPrefsController.h"
#import "CDNumberDialingTextField.h"

NSString * CDLogOutputVerboseKeyPath = @"logOutputVerbose";

static CDAppController * sharedInstance = nil;
BOOL DEBUG = NO;

@implementation CDAppController

// init
- (id)init {
    if (self = [super init]) {
//         mainWindow = <#(NSWindow *)newMainWindow#>;
//         startButton = <#(NSButton *)newStartButton#>;
//         timeTextField = <#(NSTextField *)newTimeTextField#>;
//         timeStepper = <#(NSStepper *)newTimeStepper#>;
//         progressIndicator = <#(NSProgressIndicator *)newProgressIndicator#>;
        isCounting = NO;
        timer = nil;
        textFieldEditor = nil;
        timeTextFieldValue = 0.0;
        timerCount = 0.0;
        updateInterval = 0.0;
        timeInterval = 0.0;
        stopTime = nil;
        timeUnit = @"";
        action = nil;
    }
    return self;
}

- (void) awakeFromNib {
//     timeStepper = timeStepper
//     timeTextField = timeTextField
//     textFieldEditor = nil
    DEBUG = [PREFS logOutputVerbose];    
    [CENTER addObserver:self selector:@selector(logOutputVerboseChanged:) name: CDLogOutputVerboseChangedNotification object:PREFS];
    
}

// MARK: Singleton Creation

+ (void) initialize {
    if (sharedInstance == nil)
        sharedInstance = [[self alloc] init];
}

+ (id) sharedAppController {
    // Already set by +initialize.
    return sharedInstance;
}

+ (id) allocWithZone: (NSZone *) zone {
    // Usually already set by +initialize.
    if (sharedInstance) {
        // The caller expects to receive a new object, so implicitly retain it
        // to balance out the eventual release message.
        return [sharedInstance retain];
    } else {
        // When not already set, +initialize is our caller.
        // It's creating the shared instance, let this go through.
        return [super allocWithZone: zone];
    }
}


// MARK: Singleton Overrides 

- (id) copyWithZone: (NSZone *) zone {
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

// MARK: Countdown Engine

- (IBAction) startStopCountdown:(id)sender {
    self.action = [[CDAction alloc] initWithType:[DEFAULTS stringForKey:CDActionTypeKey] text:[DEFAULTS stringForKey:CDActionTextKey] controller:self];
    
    if ([startButton.title isEqualToString:@"Start"]) {
        [self startCountdown];
        [startButton setTitle:@"Stop"];
        [timeTextField setEnabled:NO];
        [timeStepper setEnabled:NO];
    }
    else {
        [self stopCountdown];
        [startButton setTitle:@"Start"];
        [timeTextField setEnabled:YES];        
        [timeStepper setEnabled:YES];
    } 
}

- (void) startCountdown {
    NSLog(@"starting countdown at %@", DateTimeMsecStamp([NSDate date]));
    self.isCounting = YES;
    timerCount = 0.0;
    
    timeTextFieldValue = [timeTextField doubleValue];
    timeInterval = timeTextFieldValue;
    timeUnit = [DEFAULTS stringForKey:CDTimeUnitKey];
    
    NSString * cdui = [DEFAULTS stringForKey:CDUpdateIntervalKey];    
    CGFloat ui = atof([cdui UTF8String]);  
    updateInterval = ui;
    
    NSLog(@"cdui = %@, updateInterval = %f", cdui, updateInterval);
    
    if ([timeUnit isEqualToString:@"minutes"]) {
        timeInterval *= 60.0;
    }
    
    if (DEBUG) {
        NSLog(@"using time unit %@", timeUnit);
        NSLog(@"target interval = %02.02f s", timeInterval);
    }
  
    self.stopTime = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date] 
                                          interval:updateInterval 
                                            target:self 
                                          selector:@selector(updateCountdownAndCheckStopCondition:) 
                                          userInfo:nil 
                                           repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [progressIndicator setDoubleValue:100.0];
}

- (void) stopCountdown {
    [timer invalidate];
    [timeTextField setDoubleValue:timeTextFieldValue];
    NSLog(@"stopping countdown at %@", DateTimeMsecStamp([NSDate date]));
    isCounting = NO;
}


- (void) updateCountdownAndCheckStopCondition:(NSTimer *)theTimer {
    NSComparisonResult cmp = [self.stopTime compare:[NSDate date]];
    if (cmp < 0) {
        [progressIndicator setDoubleValue:0.0];
        [timeTextField setDoubleValue:timeTextFieldValue];
        [timer invalidate];
        [action run];
    }
    else {
        CGFloat pvalue = 100.0 - ((timerCount/timeInterval) * 100.0);
        NSString * pvaluestr = [NSString stringWithFormat:@"%02.02f", pvalue];
        if (DEBUG) NSLog(@"%@ %%", pvaluestr);
        timerCount += updateInterval;
        [progressIndicator setDoubleValue:pvalue];
        [timeTextField setDoubleValue:pvalue];
//         NSLog(@"pvalue = %f, pvaluestr = %@", pvalue, pvaluestr);
    }
}

// MARK: Notifications

- (void) logOutputVerboseChanged:(NSNotification *)notification {
    if (DEBUG) NSLog(@"log output verbose changed");
    CGFloat newValue = [[[notification userInfo] objectForKey:CDLogOutputVerboseChangedNotificationNewValueKey] boolValue];
    if (newValue) {
        if (DEBUG) NSLog(@"setting DEBUG to true");
        DEBUG = YES;
    }
    else {
        if (DEBUG) NSLog(@"setting DEBUG to false");
        DEBUG = NO;
    }
}

// MARK: NSApplicationDelegate Protocol

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void) applicationWillTerminate:(NSNotification *)notification {
    [CENTER removeObserver:self name:CDLogOutputVerboseChangedNotification object:PREFS];
}

// MARK: NSWindow Delegate

- (id) windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)client {
    if ([client isKindOfClass:[CDNumberDialingTextField class]]) {
        if (!self.textFieldEditor) {
            self.textFieldEditor = [[CDNumberDialingTextFieldEditor alloc] init];
            [self.textFieldEditor setFieldEditor:YES];
        }
        return self.textFieldEditor;
    }
    return nil;
}

// MARK: Synthesized Properties

// @synthesize mainWindow;
// @synthesize startButton;
@synthesize timeTextField;
@synthesize timeStepper;
// @synthesize progressIndicator;

@synthesize timer;
@synthesize timerCount;
@synthesize timeInterval;
@synthesize timeTextFieldValue;
@synthesize textFieldEditor;
@synthesize updateInterval;
@synthesize stopTime;
@synthesize timeUnit;
@synthesize action;
@synthesize isCounting;

@end
