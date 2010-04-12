//
//  CDNumberDialingTextField.m
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

#import "CDNumberDialingTextField.h"
#import "CDAppController.h"
#import "CDPrefsController.h"

@implementation CDNumberDialingTextFieldEditor

- (void) keyDown:(NSEvent *)event {
    NSString * characters = [event characters];
    
    NSTextField * timeTextField = [APP_CONTROLLER timeTextField];
    NSStepper * timeStepper = [APP_CONTROLLER timeStepper];
    
    if (DEBUG) {
        NSLog(@"timeTextField = %@", timeTextField);
        NSLog(@"timeStepper = %@", timeStepper);        
    }
        
    if ([characters length]) {
        unichar character = [characters characterAtIndex:0];
        if (character == NSLeftArrowFunctionKey) {
            if (DEBUG) NSLog(@"LEFT pressed");
        } else if (character == NSRightArrowFunctionKey) {
            if (DEBUG) NSLog(@"RIGHT pressed");
        } else if (character == NSUpArrowFunctionKey) {
            if (DEBUG) NSLog(@"UP pressed");
            if ([event modifierFlags] & NSAlternateKeyMask) {
                [timeTextField setDoubleValue:([timeTextField doubleValue] + 0.1)];
            } else if (([event modifierFlags] & NSShiftKeyMask) || 
                       ([event modifierFlags] & NSCommandKeyMask)) {
                [timeTextField setDoubleValue:([timeTextField doubleValue] + 10.0)];
            } else {
                [timeTextField setDoubleValue:([timeTextField doubleValue] + 1.0)];
            }
            [timeStepper takeDoubleValueFrom:timeTextField];
        } else if (character == NSDownArrowFunctionKey) {
            if (DEBUG) NSLog(@"DOWN pressed");
            //NSLog(@"modifierFlags = %d", [event modifierFlags]);
            if ([event modifierFlags] & NSAlternateKeyMask) {
                [timeTextField setDoubleValue:([timeTextField doubleValue] - 0.1)];
            } else if (([event modifierFlags] & NSShiftKeyMask) || 
                       ([event modifierFlags] & NSCommandKeyMask)) {
                [timeTextField setDoubleValue:([timeTextField doubleValue] - 10.0)];
            } else if ([event modifierFlags] & (NSShiftKeyMask & NSAlternateKeyMask)) {
                [timeTextField setDoubleValue:([timeTextField doubleValue] - 100)];
            } else {
                [timeTextField setDoubleValue:([timeTextField doubleValue] - 1.0)];
            }
            [timeStepper takeDoubleValueFrom:timeTextField];            
        }
    }
    [super keyDown:event];
}

@end

@implementation CDNumberDialingTextField


- (void) awakeFromNib {
    [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
}

- (void) mouseEntered:(NSEvent *)event {
    // NSLog(@"mouse entered %@", [event description]);
    if (![APP_CONTROLLER isCounting]) {
        [self becomeFirstResponder];
        [self takeDoubleValueFrom:timeStepper];
    }
    [super mouseEntered:event];
}

- (void) mouseExited:(NSEvent *)event {
    // NSLog(@"mouse exited %@", [event description]);
    if (![APP_CONTROLLER isCounting]) {
        [timeStepper takeDoubleValueFrom:self];
    }
    [super mouseEntered:event];
}


- (void) scrollWheel:(NSEvent *)event {
    // NSLog(@"scroll wheel %@", [event description])
    if (![self isEnabled]) {
        return;
    }
    [self becomeFirstResponder];
    CGFloat dy;
    NSUInteger mf;
    
    dy = [event deltaY];
    mf = [event modifierFlags];

    if (mf & NSCommandKeyMask) {
        dy *= 10.0;
    } else if (mf & NSAlternateKeyMask) {
        dy *= 0.1;
    }
    
    dy = [self doubleValue] + dy;
    [self setDoubleValue:dy];
    [timeStepper setDoubleValue:dy];
    [super scrollWheel:event];
    if (dy > 0) {
        [DEFAULTS setValue:[NSNumber numberWithFloat:dy] forKey:CDLastTimeValueKey];
    }
}

@end
