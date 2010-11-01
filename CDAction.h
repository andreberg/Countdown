//
//  CDAction.h
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
#import "SystemEvents.h"

@class CDAppController;
@class SBApplication, SystemEventsApplication;

typedef enum  {
    CDActionShutDown = 0,
    CDActionRestart,
    CDActionSleep,
    CDActionLogOut,
    CDActionDialog,
    CDActionDialogBeep,
    CDActionShellScript
} CDActionCode;

extern const int CDActionNotFound; 

typedef struct CDActionType {
    CDActionCode code;
    NSString * text;
} CDActionType;

FOUNDATION_EXPORT NSString * MsecStamp(NSDate * now);
FOUNDATION_EXPORT NSString * TimeStamp(NSDate * now);
FOUNDATION_EXPORT NSString * DateStamp(NSDate * now);
FOUNDATION_EXPORT NSString * DateTimeMsecStamp(NSDate * now);
FOUNDATION_EXPORT NSString * NSStringFromCDActionCode(CDActionCode code);

@interface CDAction : NSObject {
    CDActionCode code;
    NSString * text;
    CDAppController * controller;
}

+ (id) actionWithType:(NSString *)typeString text:(NSString *)actionText controller:(CDAppController *)appController;
- (id) initWithType:(NSString *)typeString text:(NSString *)actionText controller:(CDAppController *)appController;

- (void) run;

- (NSAppleScript *) compileAppleScript:(NSString *)script errorInfo:(NSDictionary **)errInfo;
- (NSString *) constructAppleScriptDialogString:(BOOL)makeAlert;
- (NSString *) description;

@property (nonatomic, assign) CDActionCode code;
@property (nonatomic, copy) NSString * text;
@property (nonatomic, retain) CDAppController * controller;
@end
