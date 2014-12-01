//
//  NSDictionary+MD5.m
//  Contacts
//
//  Created by Scott Carter on 11/20/12.
//  Copyright (c) 2012 Scott Carter. All rights reserved.
//

#import "NSDictionary+MD5.h"

#import "Project.h"

@implementation NSDictionary (MD5)


// We compute the MD5 checksum on a Dictionary as the MD5 checksum of the
// string concatentation of the MD5 checksums of each element value, including the key as well.
//
// We exclude any keys/value where the key is contained in exclusionKeySet
//
- (NSString *)MD5ExcludingKeysFromSet:(NSSet *)exclusionKeySet
{
    NSString *resultStr = @"";
    
    NSString *concatenateStr = @"";
    
    
    NSArray *sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    for(NSString *key in sortedKeys) {
        
        // If Dictionary key is contained in exclusionKeySet then continue
        if([exclusionKeySet containsObject:key]){
            continue;
        }
        
        id obj = [self objectForKey:key];
   
        // Include the key in the MD5 calculation.  Doesn't need to be hashed as we
        // calculate a final hash at the end before returning.
        concatenateStr = [concatenateStr stringByAppendingString:(NSString *)key];
        
        
        NSString *md5HashStr = @"";
        
        if([obj isKindOfClass:[NSArray class]]) {
            //NLOG("===> Dive into array for key=%@",key)
            NSArray *arr = (NSArray *)obj;
            md5HashStr = [arr MD5ExcludingKeysFromSet:exclusionKeySet];
        }
        
        else if([obj isKindOfClass:[NSDictionary class]]) {
            //NLOG("===> Dive into dictionary for key=%@",key)
            NSDictionary *dict = (NSDictionary *)obj;
            md5HashStr = [dict MD5ExcludingKeysFromSet:exclusionKeySet];
        }
        
        else if([obj isKindOfClass:[NSString class]]) {
            NSString *str = (NSString *)obj;
            md5HashStr = [str MD5];
            
            // NLOG("key=%@ str=%@  md5HashStr=%@",key,str,md5HashStr)
        }
        
        else if([obj isKindOfClass:[NSDate class]]) {
            NSDate *date = (NSDate *)obj;
            md5HashStr = [date MD5];
            
            // NLOG("key=%@ date=%@  md5HashStr=%@",key,date,md5HashStr)
        }
        
        else if([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *num = (NSNumber *)obj;
            md5HashStr = [num MD5];
            
            // NLOG("key=%@ num=%@  md5HashStr=%@",key,num,md5HashStr)
        }
        
        else if([obj isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)obj;
            md5HashStr = [data MD5];
        }
        
        else {
            EXCEPTION_LOG("MD5 not defined for class %@",NSStringFromClass([obj class]))
        }
        
        
        // NLOG("key=%@ md5HashStr = %@",key, md5HashStr)
        
        concatenateStr = [concatenateStr stringByAppendingString:md5HashStr];
    }
    
    
    
    // Crunch all our concatenated substring hashes into one MD5 hash
    resultStr = [concatenateStr MD5];
    
    return resultStr;
}


// Get a concatenated string of what we would normally use for an MD5 calculation for debugging.
//
// We exclude any keys/value where the key is contained in exclusionKeySet
//
- (NSString *)stringExcludingKeysFromSet:(NSSet *)exclusionKeySet
{
    NSString *concatenateStr = @"";
    
    
    NSArray *sortedKeys = [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    
    for(NSString *key in sortedKeys) {
    
        // If Dictionary key is contained in exclusionKeySet then continue
        if([exclusionKeySet containsObject:key]){
            continue;
        }
        
        id obj = [self objectForKey:key];
        
        // Include the key.  
        concatenateStr = [concatenateStr stringByAppendingString:(NSString *)key];
        
        
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






