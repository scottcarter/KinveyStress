//
//  NSString+MD5.h
//  Contacts
//
//  Created by Scott Carter on 11/20/12.
//  Copyright (c) 2012 Scott Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (MD5)

- (NSString *)MD5;
- (NSString *)string;

@end
