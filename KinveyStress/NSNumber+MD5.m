//
//  NSNumber+MD5.m
//  Contacts
//
//  Created by Scott Carter on 11/20/12.
//  Copyright (c) 2012 Scott Carter. All rights reserved.
//

#import "NSNumber+MD5.h"

@implementation NSNumber (MD5)

- (NSString *)MD5
{
    // NSLog(@"stringValue of NSNumber=%@",[self stringValue]);
    
    return [[self stringValue] MD5];
    
}

- (NSString *)string
{
    return [self stringValue];
}

@end


