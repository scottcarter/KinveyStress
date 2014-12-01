//
//  NSDate+MD5.m
//  Contacts
//
//  Created by Scott Carter on 11/20/12.
//  Copyright (c) 2012 Scott Carter. All rights reserved.
//

#import "NSDate+MD5.h"

@implementation NSDate (MD5)


// Note that we first get the number of seconds (NSNumber) since 1/1/1970 and then
// compute the hash on that value.  This number of seconds is easier to work
// with than a NSDate object when interfacing to Parse.com.
//
// We store dates at Parse as an NSNumber for easier hashing and to avoid any rounding
// issues that Parse may introduce.
// https://www.parse.com/questions/nsdate-truncated-from-its-native-timeintervalsincereferencedate-which-seems-to-include-nanoseconds
//
// See also PFObject+Utils.m
//
- (NSString *)MD5
{
    NSTimeInterval interval = [self timeIntervalSince1970];
    NSNumber *intervalNum = [NSNumber numberWithDouble:interval];
    
    // NSLog(@"interval=%f intervalNum=%@",interval,intervalNum);
    
    //return [[self description] MD5];
    return [intervalNum MD5];
    
}

- (NSString *)string
{
    NSTimeInterval interval = [self timeIntervalSince1970];
    NSNumber *intervalNum = [NSNumber numberWithDouble:interval];
    
    NSString *intervalStr = [NSString stringWithFormat:@"%@",intervalNum];
    
    return intervalStr;
}


@end


