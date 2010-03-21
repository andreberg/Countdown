//
//  CDAppController.h
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

#import <Cocoa/Cocoa.h>

extern NSString * CDLogOutputVerboseKeyPath;
extern BOOL DEBUG;

@class CDAction, CDPrefsController;

@interface CDAppController : NSObject <NSApplicationDelegate> {
    IBOutlet NSWindow * mainWindow;
    IBOutlet NSButton * startButton;
    IBOutlet NSTextField * timeTextField;
    IBOutlet NSStepper * timeStepper;
    IBOutlet NSProgressIndicator * progressIndicator;

    NSTextView * textFieldEditor;
    NSTimer * timer;
    CGFloat timerCount;
    CGFloat timeInterval;     // granularity of the interval used for the timer math
    CGFloat updateInterval;   // granularity of log and progress indicator updates
    CGFloat timeTextFieldValue;
    NSString * timeUnit;
    NSDate * stopTime;
    CDAction * action;

    @public

    BOOL isCounting;
}

+ (CDAppController *) sharedAppController;

- (IBAction) startStopCountdown:(id)sender;

- (void) startCountdown;
- (void) stopCountdown;
- (void) logOutputVerboseChanged:(NSNotification *)notification;

// @property (nonatomic, assign) IBOutlet NSWindow *mainWindow;
// @property (nonatomic, retain) IBOutlet NSButton *startButton;
@property (nonatomic, retain) IBOutlet NSTextField *timeTextField;
@property (nonatomic, retain) IBOutlet NSStepper *timeStepper;
// @property (nonatomic, retain) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, assign) NSTextView * textFieldEditor;
@property (nonatomic, assign) CGFloat timeTextFieldValue;
@property (nonatomic, retain) NSTimer * timer;
@property (nonatomic, assign) CGFloat timerCount;
@property (nonatomic, assign) CGFloat updateInterval;
@property (nonatomic, assign) CGFloat timeInterval;
@property (nonatomic, retain) NSDate * stopTime;
@property (nonatomic, copy) NSString * timeUnit;
@property (nonatomic, retain) CDAction * action;
@property (nonatomic, assign) BOOL isCounting;

@end
