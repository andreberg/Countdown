//
//  CDPrefsController.h
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

extern NSString * CDActionTypeKey;
extern NSString * CDActionTextKey;
extern NSString * CDTimeUnitKey;
extern NSString * CDLastTimerValueKey;
extern NSString * CDLogOutputVerboseKey;
extern NSString * CDUpdateIntervalKey;

extern NSString * CDLogOutputVerboseChangedNotification;
extern NSString * CDLogOutputVerboseChangedNotificationNewValueKey;


@interface CDPrefsController : NSWindowController {
    IBOutlet NSObject * appController;
    BOOL logOutputVerbose;
    CGFloat updateInterval;
}

+ (id) sharedPrefsController; 

- (IBAction) showWindow:(id)sender;
- (IBAction) closeWindow:(id)sender;
- (IBAction) logOutputVerboseClicked:(id)sender;
- (IBAction) savePrefsAndCloseWindow:(id)sender;

- (void) didEndSheet:(NSPanel *)sheet;
- (void) setupDefaults;

@property (nonatomic, assign) BOOL logOutputVerbose;
@property (nonatomic, assign) CGFloat updateInterval;
@end
