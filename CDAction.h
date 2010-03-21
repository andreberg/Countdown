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


@class CDAppController;

enum CDActionTypes {
    CDActionShutDown = 0,
    CDActionRestart,
    CDActionSleep,
    CDActionLogOut,
    CDActionDialog,
    CDActionDialogBeep,
    CDActionShellScript
};

static NSString * MsecStamp(NSDate * now) {    
    NSString * msec = [[[NSString stringWithFormat:@"%.3f", 
                         (CGFloat)([now timeIntervalSinceReferenceDate] - (NSInteger)[now timeIntervalSinceReferenceDate])] 
                                componentsSeparatedByString:@"."] objectAtIndex:1];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%F" allowNaturalLanguage:NO];
    msec = [formatter stringFromDate:now];
    NSString * res = [NSString stringWithFormat:@"%@", msec];
    return res;
}

static NSString * TimeStamp(NSDate * now) {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%H:%M:%S" allowNaturalLanguage:NO];
    NSString * res = [formatter stringFromDate:now];
    return res;
}

static NSString * DateStamp(NSDate * now) {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d" allowNaturalLanguage:NO];
    NSString * res = [formatter stringFromDate:now];
    return res;
}

static NSString * DateTimeMsecStamp(NSDate * now) {
    return [NSString stringWithFormat:@"%@ %@.%@", DateStamp(now), TimeStamp(now), MsecStamp(now)];
}

@interface CDAction : NSObject {

    NSString * type;
    NSString * text;

    CDAppController * controller;

    NSArray * types;    // all action types, indexed by enum CDActionTypes
    NSArray * scripts;  // all AppleScript sources, indexed by enum CDActionTypes
}

- (id) initWithType:(NSString *)actionType text:(NSString *)actionText controller:(NSObject *)appController;
- (NSString *) description;
- (void) run;
- (NSAppleScript *) compileAppleScript:(NSString *)script errorInfo:(NSDictionary **)errInfo;
- (NSString *) constructAppleScriptDialogString:(BOOL)makeAlert;



@property (nonatomic, copy) NSString * type;
@property (nonatomic, copy) NSString * text;
@property (nonatomic, retain) NSObject * controller;
@property (nonatomic, retain) NSArray * types;
@property (nonatomic, retain) NSArray * scripts;
@end
