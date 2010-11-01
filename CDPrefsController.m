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
#import "CDAppController.h"
#import "CDAction.h"
#import "CDNumberDialingTextField.h"

NSString * CDActionTypeKey        = @"ActionType";
NSString * CDActionTextKey        = @"ActionText";
NSString * CDTimeUnitKey          = @"TimeUnit";
NSString * CDLastTimeValueKey     = @"LastTimeValue";
NSString * CDLogOutputVerboseKey  = @"LogOutputVerbose";
NSString * CDUpdateIntervalKey    = @"TimeUpdateInterval";
NSString * CDKeepWindowAfloatKey  = @"KeepWindowAfloat";

NSString * CDLogOutputVerboseChangedNotification              = @"LogOutputVerboseChangedNotification";
NSString * CDLogOutputVerboseChangedNotificationNewValueKey   = @"LogOutputVerboseChangedNotificationNewValue";
NSString * CDKeepWindowAfloatChangedNotification              = @"KeepWindowAfloatChangedNotification";
NSString * CDKeepWindowAfloatChangedNotificationNewValueKey   = @"KeepWindowAfloatChangedNotificationNewValue";

static CDPrefsController * sharedInstance = nil;

@implementation CDPrefsController

// FIXME: UpdateInterval text field needs delegate 
// which handles textShouldEndEditing to really update
// the model / user defaults

- (id) init {
    [self setupDefaults];
    logOutputVerbose = [DEFAULTS boolForKey:CDLogOutputVerboseKey];
    updateInterval = [DEFAULTS doubleForKey:CDUpdateIntervalKey];
    keepWindowAfloat = [DEFAULTS boolForKey:CDKeepWindowAfloatKey];
    return self;
}

- (void) awakeFromNib {
    if (actionChoices) {
        [actionChoices setAction:@selector(handleActionChoice:)];
    }
}

- (IBAction) handleActionChoice:(id)sender {
    if (actionTextField) {
        NSInteger srow = [actionChoices selectedRow];
        switch (srow) {
            case CDActionDialog:
                [actionTextField setEnabled:YES];
                break;
            case CDActionDialogBeep:
                [actionTextField setEnabled:YES];
                break;
            case CDActionShellScript:
                [actionTextField setEnabled:YES];
                break;
            default:
                [actionTextField setEnabled:NO];
                break;
        }
        
    }
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
        self.logOutputVerbose = NO;
    } else {
        self.logOutputVerbose = YES;
    }
    NSDictionary * info = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:logOutputVerbose] forKey:CDLogOutputVerboseChangedNotificationNewValueKey];
    [NCENTER postNotificationName:CDLogOutputVerboseChangedNotification object:self userInfo:info];
}

//- (IBAction) keepWindowAfloatClicked:(id)sender {
//    if ([sender state] == 0) {
//        self.keepWindowAfloat = NO;
//    } else {
//        self.keepWindowAfloat = YES;
//    }
//    NSDictionary * info = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:keepWindowAfloat] forKey:CDKeepWindowAfloatChangedNotificationNewValueKey];
//    [NCENTER postNotificationName:CDKeepWindowAfloatChangedNotification object:self userInfo:info];
//    [APP_CONTROLLER setMainWindowKeepAfloat:keepWindowAfloat];
//}

- (IBAction) savePrefsAndCloseWindow:(id)sender {
    [(NSUserDefaultsController *)DEFAULTS_CONTROLLER save:sender];
    [DEFAULTS synchronize];
    [self closeWindow:self];
}

- (IBAction) revertToDefaults:(id)sender {
    [(NSUserDefaultsController *)DEFAULTS_CONTROLLER revertToInitialValues:sender];
    [DEFAULTS synchronize];
}

- (void) didEndSheet:(NSPanel *)sheet {
	[sheet orderOut:self];
    if (!APP_CONTROLLER.isCounting) {
        [[APP_CONTROLLER timeTextField] becomeFirstResponder];
    }
}

// MARK: Methods

- (void) setupDefaults {
    NSString * defaultsPlist = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
    NSDictionary * defaultsDict = [NSDictionary dictionaryWithContentsOfFile:defaultsPlist];
    [DEFAULTS registerDefaults:defaultsDict];
    [DEFAULTS_CONTROLLER setInitialValues:defaultsDict];	
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

// MARK: Menu Validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    // don't show the preferences if countdown has begun
    if ([[menuItem title] isEqualToString:@"Preferences…"]) {
        if (APP_CONTROLLER.isCounting) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return [super validateMenuItem:menuItem];
    }
}

// MARK: Synthesized Properties

@synthesize logOutputVerbose;
@synthesize keepWindowAfloat;
@synthesize updateInterval;
@synthesize textFieldEditor;
@end
