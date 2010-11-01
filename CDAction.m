//
//  CDAction.m
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

#import "CDAction.h"
#import "CDAppController.h"
#import "NSString-BMScriptUtilities.h"
#import "SystemEvents.h"

const int CDActionNotFound = -1;

static CDActionType gDefaultActionTypes[] = {
    {CDActionShutDown,    @"Shut Down"},
    {CDActionRestart,     @"Restart"},
    {CDActionSleep,       @"Sleep"},
    {CDActionLogOut,      @"Log Out"},
    {CDActionDialog,      @"Dialog"},
    {CDActionDialogBeep,  @"Dialog + Beep"},
    {CDActionShellScript, @"Shell Script"},
};

// MARK: Helper Functions

CD_INLINE
NSString * MsecStamp(NSDate * now) {    
    NSString * msec = [[[NSString stringWithFormat:@"%.3f", 
                         (CGFloat)([now timeIntervalSinceReferenceDate] - (NSInteger)[now timeIntervalSinceReferenceDate])] 
                            componentsSeparatedByString:@"."] objectAtIndex:1];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%F" allowNaturalLanguage:NO];
    msec = [formatter stringFromDate:now];
    NSString * res = [NSString stringWithFormat:@"%@", msec];
    return res;
}

CD_INLINE
NSString * TimeStamp(NSDate * now) {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%H:%M:%S" allowNaturalLanguage:NO];
    NSString * res = [formatter stringFromDate:now];
    return res;
}

CD_INLINE
NSString * DateStamp(NSDate * now) {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d" allowNaturalLanguage:NO];
    NSString * res = [formatter stringFromDate:now];
    return res;
}

CD_INLINE
NSString * DateTimeMsecStamp(NSDate * now) {
    return [NSString stringWithFormat:@"%@ %@.%@", DateStamp(now), TimeStamp(now), MsecStamp(now)];
}

CD_INLINE
NSString * NSStringFromCDActionCode(CDActionCode code) { 
    return gDefaultActionTypes[code].text;
}

CD_INLINE
CDActionCode CDActionCodeFromNSString(NSString * typeString) {
    CDActionType *scan, *stop;
    scan = gDefaultActionTypes;
    stop = scan + (sizeof(gDefaultActionTypes) / sizeof(CDActionType));
    while (scan < stop) {
        if ([scan->text isEqualToString:typeString]) {
            return scan->code;
        }
        scan++;
    }
    return CDActionNotFound;
}

@interface CDAction (/*Private*/)

- (id) initWithActionCode:(CDActionCode)actionCode text:(NSString *)actionText controller:(CDAppController *)appController;

@end

@implementation CDAction


// MARK: Object Creation

+ (id) actionWithType:(NSString *)typeString text:(NSString *)actionText controller:(CDAppController *)appController {
    return [[self alloc] initWithType:typeString text:actionText controller:appController];
}

- (id) initWithType:(NSString *)typeString text:(NSString *)actionText controller:(CDAppController *)appController {
    CDActionCode _code = CDActionCodeFromNSString(typeString);
    if (_code != CDActionNotFound) {
        return [self initWithActionCode:_code text:actionText controller:appController];
    }
    return nil;
}

- (id) init {
    return [[CDAction alloc] initWithActionCode:-1 text:nil controller:nil];
}

// internal designated initializer
- (id) initWithActionCode:(CDActionCode)actionCode text:(NSString *)actionText controller:(CDAppController *)appController {
    if (self = [super init]) {
        code = actionCode;
        text = actionText;
        controller = appController;
    }
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"executing action   at %@ with type '%@' and text %@", 
            DateTimeMsecStamp([NSDate date]), NSStringFromCDActionCode(code), text];
}

// MARK: Methods

- (NSAppleScript *) compileAppleScript:(NSString *)script errorInfo:(NSDictionary **)errInfo {
    NSAppleScript * as = [[NSAppleScript alloc] initWithSource:script];
    [as compileAndReturnError:errInfo];
    return as;
}

- (NSString *) constructAppleScriptDialogString:(BOOL)makeAlert {
    NSString * res;
    NSString * title = @"Countdown";
    NSString * timestamp = TimeStamp([NSDate date]);
    if (makeAlert) {
        res = [NSString stringWithFormat:@"display alert \"%@\" message \"%@: %@\" "
                                         @"buttons {\"OK\"} default button 1", title, timestamp, [text quote]];
    }
    else {
        res = [NSString stringWithFormat:@"display dialog \"%@: %@\" with title \"%@\" "
                                         @"buttons {\"OK\"} with icon 1 default button 1", timestamp, [text quote], title];
    }
    return res;
}

- (void) run {
    NSAssert(controller, @"controller must not be nil");
    [controller startStopCountdown:self];

    NSLog(@"%@", [self description]);

    NSAppleScript * as = nil;
    NSDictionary * errInfo = nil;
    
    SystemEventsApplication * sysevents = [SBApplication applicationWithBundleIdentifier:@"com.apple.systemevents"];
    
    if (code == CDActionShutDown) {
        [sysevents shutDown];
    }
    else if (code == CDActionRestart) {
        [sysevents restart];
    }
    else if (code == CDActionSleep) {
        [sysevents sleep];
    }
    else if (code == CDActionLogOut) {
        [sysevents logOut];
    }
    else if (code == CDActionDialog) {
        NSString * dialog = [self constructAppleScriptDialogString:YES];
        as = [self compileAppleScript:[NSString stringWithFormat:@"property parent : app \"Countdown\"\n%@", dialog] 
                            errorInfo:&errInfo];
    }
    else if (code == CDActionDialogBeep) {
        NSString * dialog = [self constructAppleScriptDialogString:YES];
        as = [self compileAppleScript:[NSString stringWithFormat:@"property parent : app \"Countdown\"\nbeep 1\n%@", dialog] 
                            errorInfo:&errInfo];
    }
    else if (code == CDActionShellScript) {
        @try {
            int result = system([text UTF8String]);
            NSLog(@"shell script returned %d", result);
        }
        @catch (NSException * e) {
            NSLog(@"Shell script exception: %@ (%@)", [e reason], [e name]);
        }
    }
    
    // as will be set if code == CDActionDialog || code == CDActionDialogBeep
    if (as) {
        [as executeAndReturnError:&errInfo];
        if (errInfo) {
            NSLog(@"AppleScript compilation failed: %@", [errInfo descriptionInStringsFileFormat]);        
        }
    }
}

// MARK: Properties

@synthesize code;
@synthesize text;
@synthesize controller;
@end
