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

@implementation CDNumberDialingTextFieldEditor

- (void) keyDown:(NSEvent *)event {
    NSString * characters = [event characters];
    
    NSTextField * timeTextField = [[CDAppController sharedAppController] timeTextField];
    NSStepper * timeStepper = [[CDAppController sharedAppController] timeStepper];
    
    NSLog(@"timeTextField = %@", timeTextField);
    NSLog(@"timeStepper = %@", timeStepper);
    
    if ([characters length]) {
        unichar character = [characters characterAtIndex:0];
        if (character == NSLeftArrowFunctionKey) {
            NSLog(@"LEFT pressed");
        } else if (character == NSRightArrowFunctionKey) {
            NSLog(@"RIGHT pressed");
        } else if (character == NSUpArrowFunctionKey) {
            NSLog(@"UP pressed");
            [timeTextField setDoubleValue:([timeTextField doubleValue] + 1.0)];
            [timeStepper takeDoubleValueFrom:timeTextField];
        } else if (character == NSDownArrowFunctionKey) {
            NSLog(@"DOWN pressed");
            [timeTextField setDoubleValue:([timeTextField doubleValue] - 1.0)]; 
            [timeStepper takeDoubleValueFrom:timeTextField];            
        }
    }
    [super keyDown:event];
}


@end


@implementation CDNumberDialingTextField


- (void) awakeFromNib {
    [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:YES];
}

- (void) mouseEntered:(NSEvent *)event {
    // NSLog(@"mouse entered %@", [event description]);
    if (![[CDAppController sharedAppController] isCounting]) {
        [self becomeFirstResponder];
    }
    //[super mouseEntered:event];
}

- (void) mouseExited:(NSEvent *)event {
    // NSLog(@"mouse exited %@", [event description]);
    if (![[CDAppController sharedAppController] isCounting]) {
        [timeStepper takeDoubleValueFrom:self];
    }
    //[super mouseEntered:event];
}

- (void) scrollWheel:(NSEvent *)event {
    // NSLog(@"scroll wheel %@", [event description])
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
    
    [self setDoubleValue:([self doubleValue] + dy)];
    [timeStepper setDoubleValue:([timeStepper doubleValue] + dy)];
    //[super scrollWheel:event];

}

@end
