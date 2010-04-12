//
//  NSString-BMScriptUtilities.m
//  Countdown
//
//  Created by Andre Berg on 07.04.10.
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

#import "NSString-BMScriptUtilities.h"


@implementation NSString (BMScriptStringUtilities)

- (NSString *) quote {
    NSString * quotedResult = [self stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    quotedResult = [quotedResult stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    quotedResult = [quotedResult stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
    quotedResult = [quotedResult stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    quotedResult = [quotedResult stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    quotedResult = [quotedResult stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
    quotedResult = [quotedResult stringByReplacingOccurrencesOfString:@"%"  withString:@"%%"];
    return quotedResult;
}

- (NSString *) wrapSingleQuotes { 
    return [NSString stringWithFormat:@"'%@'", self]; 
}

- (NSString *) wrapDoubleQuotes {
    return [NSString stringWithFormat:@"\"%@\"", self]; 
}


- (NSString *) truncate {
#ifdef BM_NSSTRING_TRUNCATE_LENGTH
    NSUInteger len = BM_NSSTRING_TRUNCATE_LENGTH;
#else
    NSUInteger len = 20;
#endif
    if ([self length] < len) {
        return self;
    }
    return [self truncateToLength:len];
}

- (NSString *) truncateToLength:(NSUInteger)len {
    if ([self length] < len) {
        return self;
    }
    return [[self substringWithRange:(NSMakeRange(0, len))] stringByAppendingString:@"..."];
}

- (NSString *) truncateToLength:(NSUInteger)targetLength mode:(BMNSStringTruncateMode)mode indicator:(NSString *)indicatorString {
    
    NSString * res = nil;
    NSString * firstPart;
    NSString * lastPart;
    
    if (!indicatorString) {
        indicatorString = @"...";
    }
    
    NSUInteger stringLength = [self length];
    NSUInteger ilength = [indicatorString length];
    
    if (stringLength <= targetLength) {
        return self;
    } else if (stringLength <= 0 || (!self)) {
        return nil;
    } else {
        switch (mode) {
            case BMNSStringTruncateModeCenter:
                firstPart = [self substringToIndex:(targetLength/2)];
                lastPart = [self substringFromIndex:(stringLength-((targetLength/2))+ilength)];
                res = [NSString stringWithFormat:@"%@%@%@", firstPart, indicatorString, lastPart];                
                break;
            case BMNSStringTruncateModeStart:
                res = [NSString stringWithFormat:@"%@%@", indicatorString, [self substringFromIndex:((stringLength-targetLength)+ilength)]];
                break;
            case BMNSStringTruncateModeEnd:
                res = [NSString stringWithFormat:@"%@%@", [self substringToIndex:(targetLength-ilength)], indicatorString];
                break;
            default:
                ;
                NSException * myException = [NSException exceptionWithName:NSInvalidArgumentException 
                                                                    reason:[NSString stringWithFormat:@"[%@ %s] called with invalid value for 'mode' (mode = %d) ***",
                                                                            [self class], _cmd, mode]
                                                                  userInfo:nil];
                @throw myException;
                return res;
                break;
        };
    }
    return res;
}

- (NSInteger) countOccurrencesOfString:(NSString *)aString {
    NSInteger num = ((NSInteger)[[NSArray arrayWithArray:[self componentsSeparatedByString:aString]] count] - 1);
    if (num > 0) {
        return num;
    }
    return NSNotFound;
}

@end
