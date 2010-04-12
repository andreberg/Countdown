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
#import "NSDate-Utilities.h"

NSString * CDLogOutputVerboseKeyPath = @"logOutputVerbose";

static CDAppController * sharedInstance = nil;
BOOL DEBUG = NO;

@implementation CDAppController

// init
- (id)init {
    if (self = [super init]) {
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
    DEBUG = [PREFS_CONTROLLER logOutputVerbose];    
    [NCENTER addObserver:self selector:@selector(logOutputVerboseChanged:) name: CDLogOutputVerboseChangedNotification object:PREFS_CONTROLLER];
    
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
    if ([startButton.title isEqualToString:@"Start"]) {
        self.action = [CDAction actionWithType:[DEFAULTS stringForKey:CDActionTypeKey] 
                                          text:[DEFAULTS stringForKey:CDActionTextKey] 
                                    controller:self];
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
    self.timerCount = 0.0;
    
    self.timeTextFieldValue = [timeTextField doubleValue];
    self.timeInterval = timeTextFieldValue;
    self.timeUnit = [DEFAULTS stringForKey:CDTimeUnitKey];
    if ([timeUnit isEqualToString:@"minutes"]) {
        self.timeInterval *= 60.0;
    }
    
    CGFloat ui = 0.0;
    NSString * uiStr = [DEFAULTS stringForKey:CDUpdateIntervalKey];
    NSScanner * doubleScanner = [NSScanner scannerWithString:uiStr];
    BOOL success = [doubleScanner scanDouble:&ui];
    if (!success) {
        if (DEBUG) NSLog(@"Warning: doubleScanner failed scanning [defaults stringForKey:CDUpdateIntervalKey]");
        ui = atof([uiStr UTF8String]);
    }
    
    NSAssert(ui > 0.0, @"ui must be greater than 0");
    self.updateInterval = ui;
    
    if (DEBUG) {
        NSLog(@"updateInterval string = %@, updateInterval float = %f", uiStr, updateInterval);
        NSLog(@"using time unit %@", timeUnit);
        NSLog(@"target interval = %02.02f s", timeInterval);
    }
  
    self.stopTime = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date] 
                                          interval:updateInterval 
                                            target:self 
                                          selector:@selector(updateCountdown:) 
                                          userInfo:nil 
                                           repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [progressIndicator setDoubleValue:100.0];
}

- (void) stopCountdown {
    [timer invalidate];
    [timeTextField setDoubleValue:timeTextFieldValue];
    NSLog(@"stopping countdown at %@", DateTimeMsecStamp([NSDate date]));
    self.isCounting = NO;
}


- (void) updateCountdown:(NSTimer *)theTimer {
    NSComparisonResult cmp = [stopTime compare:[NSDate date]];
    if (cmp < 0) {
        [progressIndicator setDoubleValue:0.0];
        [timeTextField setDoubleValue:timeTextFieldValue];
        [timer invalidate];
        [action run];
        [[NSGarbageCollector defaultCollector] collectIfNeeded];
    } else {
        CGFloat pvalue = 100.0 - ((timerCount/timeInterval) * 100.0);
        NSString * pvaluestr = [NSString stringWithFormat:@"%02.3f", pvalue];
        
//         NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//         NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
//         NSDateComponents * components = [gregorian components:unitFlags
//                                                      fromDate:[NSDate date]
//                                                        toDate:stopTime 
//                                                       options:0];
//         NSInteger hours = [components hour];
//         NSInteger minutes = [components minute];
//         NSInteger seconds = [components second] + 1;  // need to add 1 since the NSTimer fire event 
//                                                       // will happen on the next avilable second
//         
//         NSString * displaystr = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
        
        NSString * displaystr = [stopTime stringForOffsetFromDate:[NSDate dateWithSecondsBeforeNow:1] formatterTemplate:@"HH:mm:ss"];
        
        if (DEBUG) {
            NSLog(@"%@%%", pvaluestr);
        }
        
        self.timerCount += updateInterval;
        
        [progressIndicator setDoubleValue:pvalue];
        [timeTextField setStringValue:displaystr];
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
    [NCENTER removeObserver:self name:CDLogOutputVerboseChangedNotification object:PREFS_CONTROLLER];
}

// MARK: NSWindow Delegate

- (id) windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)client {
    if ([client isKindOfClass:[CDNumberDialingTextField class]]) {
        if (!textFieldEditor) {
            self.textFieldEditor = [[CDNumberDialingTextFieldEditor alloc] init];
            [textFieldEditor setFieldEditor:YES];
        }
        return self.textFieldEditor;
    }
    return nil;
}


- (void) windowDidBecomeMain:(NSNotification *)notification {
    [timeTextField becomeFirstResponder];
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
