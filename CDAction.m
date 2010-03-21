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

@implementation CDAction

// MARK: Object Creation

// init
- (id) init {
    return [self initWithType:nil text:nil controller:nil];
}

- (id) initWithType:(NSString *)actionType text:(NSString *)actionText controller:(CDAppController *)appController {
    if (self = [super init]) {
        type = actionType;
        text = actionText;
        controller = appController;
        types = [NSArray arrayWithObjects:
                                @"Shut Down", 
                                @"Restart", 
                                @"Sleep",   
                                @"Log Out", 
                                @"Dialog", 
                                @"Dialog + Beep", 
                                @"Shell Script", nil];
        
        scripts = [NSArray arrayWithObjects:
                                @"tell application \"System Events\" to shut down", 
                                @"tell application \"System Events\" to restart", 
                                @"tell application \"System Events\" to sleep",   
                                @"tell application \"System Events\" to log out", 
                                @"property parent : app \"Countdown\"\n%@", 
                                @"property parent : app \"Countdown\"\nbeep 1\n%@", nil];
        
    }
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"executing action at %@ with type '%@' and action text '%@'", [NSDate date], type, text];
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
        res = [NSString stringWithFormat:@"display alert \"%@\" message \"%@: %@\" buttons {\"OK\"} default button 1", title, timestamp, text];
    }
    else {
        res = [NSString stringWithFormat:@"display dialog \"%@: %@\" with title \"%@\" buttons {\"OK\"} with icon 1 default button 1", timestamp, text, title];
    }
    return res;
}

- (void) run {
    if (DEBUG) NSLog(@"%@", [self description]);
    [controller startStopCountdown:self];
    NSAppleScript * as = nil;
    NSDictionary * errInfo = nil;
    
    if ([type isEqualToString:[types objectAtIndex:CDActionShutDown]]) {
        as = [self compileAppleScript:[self.scripts objectAtIndex:CDActionShutDown] errorInfo:&errInfo];
    }
    else if ([type isEqualToString:[types objectAtIndex:CDActionRestart]]) {
        as = [self compileAppleScript:[self.scripts objectAtIndex:CDActionRestart] errorInfo:&errInfo];
    }
    else if ([type isEqualToString:[types objectAtIndex:CDActionSleep]]) {
        as = [self compileAppleScript:[self.scripts objectAtIndex:CDActionSleep] errorInfo:&errInfo];
    }
    else if ([type isEqualToString:[types objectAtIndex:CDActionLogOut]]) {
        as = [self compileAppleScript:[self.scripts objectAtIndex:CDActionLogOut] errorInfo:&errInfo];
    }
    else if ([type isEqualToString:[types objectAtIndex:CDActionDialog]]) {
        NSString * dialog = [self constructAppleScriptDialogString:YES];
        as = [self compileAppleScript:[NSString stringWithFormat:[self.scripts objectAtIndex:CDActionDialog], dialog] errorInfo:&errInfo];
    }
    else if ([type isEqualToString:[types objectAtIndex:CDActionDialogBeep]]) {
        NSString * dialog = [self constructAppleScriptDialogString:YES];
        as = [self compileAppleScript:[NSString stringWithFormat:[self.scripts objectAtIndex:CDActionDialogBeep], dialog] errorInfo:&errInfo];
    }
    
    if (as) {
        [as executeAndReturnError:&errInfo];
    } else if (errInfo) {
        NSLog(@"AppleScript compilation failed: %@", [errInfo descriptionInStringsFileFormat]);        
    } else {
        NSInteger result = system([text UTF8String]);
        NSLog(@"shell script returned %d", result);
    }
}



// MARK: Synthesized Properties

@synthesize type;
@synthesize text;
@synthesize controller;
@synthesize types;
@synthesize scripts;
@end
