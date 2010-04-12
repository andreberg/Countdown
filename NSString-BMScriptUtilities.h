//
//  NSString-BMScriptUtilities.h
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

#import <Cocoa/Cocoa.h>


#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
/*!A category on NSString providing compatibility for missing methods on 10.4 (Tiger). */
@interface NSString (BMScriptNSString10_4Compatibility)
/*!
 * An implementation of the 10.5 (Leopard) method of NSString. 
 * Replaces all occurrences of a string with another string with the ability to define the search range and other comparison options.
 * @param target the string to replace
 * @param replacement the string to replace target with
 * @param options on 10.5 this parameter is of type NSStringCompareOptions an untagged enum. On 10.4 you can use the following options:
 *  - 1  (NSCaseInsensitiveSearch)
 *  - 2  (NSLiteralSearch: Exact character-by-character equivalence)
 *  - 4  (NSBackwardsSearch: Search from end of source string)
 *  - 8  (NSAnchoredSearch: Search is limited to start (or end, if NSBackwardsSearch) of source string)
 *  - 64 (NSNumericSearch: Numbers within strings are compared using numeric value, that is, Foo2.txt < Foo7.txt < Foo25.txt)
 * @param searchRange an NSRange defining the location and length the search should be limited to
 * @deprecated Deprecated in 10.5 (Leopard) in favor of NSString's own implementation.
 */
- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(unsigned)options range:(NSRange)searchRange; DEPRECATED_IN_MAC_OS_X_VERSION_10_5_AND_LATER
/*!
 * An implementation of the 10.5 (Leopard) method of NSString. Replaces all occurrences of a string with another string. 
 * Calls stringByReplacingOccurrencesOfString:withString:options:range: with default options 0 and searchRange the full length of the searched string.
 * @deprecated Deprecated in 10.5 (Leopard) in favor of NSString's own implementation.
 */
- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement; DEPRECATED_IN_MAC_OS_X_VERSION_10_5_AND_LATER
@end
#endif

/*!
 * A category on NSString providing some handy utility functions
 * for end user display of strings. 
 */
@interface NSString (BMScriptStringUtilities)
/*! String truncation modes￼￼ */
typedef enum {
    /*! <string_start> ... <string_end>. */
    BMNSStringTruncateModeCenter = 0,
    /*! ... <string_end>. */
    BMNSStringTruncateModeStart = 1,
    /*! <string_start> ... */
    BMNSStringTruncateModeEnd = 2
} BMNSStringTruncateMode;

/*!
 * Replaces all occurrences of newlines, carriage returns, backslashes, single/double quotes and percentage signs with their escaped versions 
 * @return the quoted string
 */ 
- (NSString *) quote;
/*!
 * Truncates a string to 20 characters and adds an ellipsis ("...").
 * @return the truncated string
 */ 
- (NSString *) truncate;
/*! 
 * Truncates a string to len characters plus ellipsis.
 * @param len new length. ellipsis will be added.
 * @return the truncated string
 */ 
- (NSString *) truncateToLength:(NSUInteger)len;
/*! 
 * Truncates a string to len characters while giving control over where the
 * indicator should appear: start, middle or end.
 * The indicator itself is also specifyable.
 * @param len new length including ellipsis.
 * @param mode the truncate mode. start, center or end.
 * @param indidcator the indicator string (typically an ellipsis sysmbol, if nil an NSString containing 3 periods will be used)
 * @return the truncated string
 */ 
- (NSString *) truncateToLength:(NSUInteger)length mode:(BMNSStringTruncateMode)mode indicator:(NSString *)indicatorString;
/*!
 * Counts the number of occurrences of a string in another string 
 * @param aString the string to count occurrences of
 * @return NSInteger with the amount of occurrences
 */
- (NSInteger) countOccurrencesOfString:(NSString *)aString;
/*!
 * Returns a string wrapped with single quotes. 
 */
- (NSString *) wrapSingleQuotes;
/*!
 * Returns a string wrapped with double quotes. 
 */
- (NSString *) wrapDoubleQuotes;
@end

