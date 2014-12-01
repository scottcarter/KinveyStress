//
//  NSArray+MD5.m
//  Contacts
//
//  Created by Scott Carter on 11/20/12.
//  Copyright (c) 2012 Scott Carter. All rights reserved.
//

#import "NSArray+MD5.h"

#import "Project.h"

@implementation NSArray (MD5)


// We compute the MD5 checksum on an array as the MD5 checksum of the
// string concatentation of the MD5 checksums of each element.
//
// We exclude any keys/value where the key is contained in exclusionKeySet
//
- (NSString *)MD5ExcludingKeysFromSet:(NSSet *)exclusionKeySet
{
    NSString *resultStr = @"";
    
    NSString *concatenateStr = @"";
    
    for (id obj in self) {
        
        
        if([obj isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)obj;
            concatenateStr = [concatenateStr stringByAppendingString:[arr MD5ExcludingKeysFromSet:exclusionKeySet]];
        }
        
        else if([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)obj;
            concatenateStr = [concatenateStr stringByAppendingString:[dict MD5ExcludingKeysFromSet:exclusionKeySet]];
        }
        
        else if([obj isKindOfClass:[NSString class]]) {
            NSString *str = (NSString *)obj;
            concatenateStr = [concatenateStr stringByAppendingString:[str MD5]];
        }
        
        else if([obj isKindOfClass:[NSDate class]]) {
            NSDate *date = (NSDate *)obj;
            concatenateStr = [concatenateStr stringByAppendingString:[date MD5]];
        }
        
        else if([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *num = (NSNumber *)obj;
            concatenateStr = [concatenateStr stringByAppendingString:[num MD5]];
        }
        
        else if([obj isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)obj;
            concatenateStr = [concatenateStr stringByAppendingString:[data MD5]];
        }
        
        else {
            EXCEPTION_LOG("MD5 not defined for class %@",NSStringFromClass([obj class]))
        }
    }
    
    // Crunch all our concatenated substring hashes into one MD5 hash
    resultStr = [concatenateStr MD5];
    
    return resultStr;
}


// Get a concatenated string of what we would normally use for an MD5 calculation for debugging.
//
// We exclude any keys/value where the key is contained in exclusionKeySet
//
- (NSString *)stringExcludingKeysFromSet:(NSSet *)exclusionKeySet;
{
    NSString *concatenateStr = @"";
    
    for (id obj in self) {
        if([obj isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)obj;
            concatenateStr = [concatenateStr stringByAppendingString:[arr stringExcludingKeysFromSet:exclusionKeySet]];
        }
        
        else if([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)obj;
            concatenateStr = [concatenateStr stringByAppendingString:[dict stringExcludingKeysFromSet:exclusionKeySet]];
        }
        
        else if([obj isKindOfClass:[NSString class]]) {
            NSString *str = (NSString *)obj;
            concatenateStr = [concatenateStr stringByAppendingString:[str string]];
        }
        
        else if([obj isKindOfClass:[NSDate class]]) {
            NSDate *date = (NSDate *)obj;
            concatenateStr = [concatenateStr stringByAppendingString:[date string]];
        }
        
        else if([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *num = (NSNumber *)obj;
            concatenateStr = [concatenateStr stringByAppendingString:[num string]];
        }
        
        // Method not defined for NSData
//        else if([obj isKindOfClass:[NSData class]]) {
//            NSData *data = (NSData *)obj;
//            concatenateStr = [concatenateStr stringByAppendingString:[data string]];
//        }
        
        else {
            EXCEPTION_LOG("string method not defined for class %@",NSStringFromClass([obj class]))
        }
    }
    
    return concatenateStr;
}

@end
