//
//  NSDictionary+MD5.h
//  Contacts
//
//  Created by Scott Carter on 11/20/12.
//  Copyright (c) 2012 Scott Carter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSArray+MD5.h"
#import "NSString+MD5.h"
#import "NSDate+MD5.h"
#import "NSNumber+MD5.h"
#import "NSData+MD5.h"

@interface NSDictionary (MD5)

- (NSString *)MD5ExcludingKeysFromSet:(NSSet *)exclusionKeySet;
- (NSString *)stringExcludingKeysFromSet:(NSSet *)exclusionKeySet;

@end
