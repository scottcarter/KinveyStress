//
//  NSData+Description.m
//  Contacts
//
//  Created by Scott Carter on 11/29/12.
//  Copyright (c) 2012 Scott Carter. All rights reserved.
//

#import "NSData+Description.h"

@implementation NSData (Description)

// Override the description method of NSData to return an empty string.
//
// When dumping nested structures of records, we don't want to get the default
// hex dump.
- (NSString *)description
{
    return @"<NSData hex dump suppressed in NSData+Description.m>";
}


@end




