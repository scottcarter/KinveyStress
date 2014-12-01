//
//  AddressBook.h
//  Contacts
//
//  Created by Scott Carter on 11/16/12.
//  Copyright (c) 2012 Scott Carter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AddressBook/AddressBook.h>



// FIXME: None
// TODO: None
#pragma mark -

// ==========================================================================
// Constants and Defines
// ==========================================================================
//
#pragma mark -
#pragma mark Constants and Defines


// Defined in AddressBook.m
FOUNDATION_EXPORT NSUInteger const AddressBookNumEntriesToPopulateBeforeSave;
FOUNDATION_EXPORT NSUInteger const AddressBookNumLoopsForPopulate;
FOUNDATION_EXPORT NSUInteger const AddressBookRandomSeedForPopulate;


typedef enum {
    RecordFieldsModificationDate,
    RecordFieldsAll,
    RecordFieldsAllExceptModificationDate
} recordFields;

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Forward Declarations
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
#pragma mark Forward Declarations

// None


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Protocols
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
#pragma mark -
#pragma mark Protocols

// None


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Public Interface
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
#pragma mark -
@interface AddressBook : NSObject



// ==========================================================================
// Properties
// ==========================================================================
//
#pragma mark -
#pragma mark  Properties

// None


// ==========================================================================
// Class method declarations
// ==========================================================================
//
#pragma mark -
#pragma mark Class method declarations



+ (NSArray *)getPersonRecordArrayWithFields:(recordFields)fields
                            withAddressBook:(ABAddressBookRef)addressBook_cf;


+ (NSDictionary *)getPersonRecordDictionaryForRecordId:(NSUInteger)recordId
                                       withAddressBook:(ABAddressBookRef)addressBook_cf
                                       forRecordFields:(recordFields)fields
                                        withRecordDict:(NSDictionary *)initialRecordDict;

+ (NSDictionary *)getPersonRecordDictionaryForRecord:(ABRecordRef)record_cf
                                     withAddressBook:(ABAddressBookRef)addressBook_cf
                                     forRecordFields:(recordFields)fields
                                      withRecordDict:(NSDictionary *)initialRecordDict;

+ (ABRecordRef)newPersonRecordUsingDictionary:(NSDictionary *)personDict
                              withAddressBook:(ABAddressBookRef)addressBook_cf
                                        error:(NSError **)error;

+ (BOOL)personRecordUsingDictionary:(NSDictionary *)personDict
                         withRecord:(ABRecordRef)record_cf
                              error:(NSError **)error;

+ (ABRecordRef)recordSaveValue:(CFTypeRef)value_cf
                   forRecordId:(NSUInteger)recordId
                   forProperty:(NSString *)property
                withPropertyID:(ABPropertyID)propertyID
               withAddressBook:(ABAddressBookRef)addressBook_cf
                         error:(NSError **)error;

+ (NSArray *)sortMultiValueArray:(NSArray *)arrToSort
                 forPropertyType:(ABPropertyType)propertyType;

+ (BOOL)emptyAddressBook:(id)sender
                   error:(NSError **)error;


// ==========================================================================
// Class method declarations for testing
// ==========================================================================
//
#pragma mark -
#pragma mark Class method declarations for testing


+ (BOOL)populateAddressBookWithSeed:(NSUInteger)randomSeed
                  allowSparseFields:(BOOL)allowSparseFields
              allowRandomDuplicates:(BOOL)allowRandomDuplicates
                        allowImages:(BOOL)allowImages
                numLoopsForPopulate:(NSUInteger)numLoopsForPopulate
     numEntriesToPopulateBeforeSave:(NSUInteger)numEntriesToPopulateBeforeSave
                     fixingProperty:(NSString *)property
                     withPropertyID:(ABPropertyID)propertyID
                          withValue:(CFTypeRef)value_cf
                              error:(NSError **)error;


+ (BOOL)removeRandomRecord:(id)sender
                     error:(NSError **)error;


// ==========================================================================
// Instance method declarations
// ==========================================================================
//
#pragma mark -
#pragma mark Instance method declarations

// None


// ==========================================================================
// C method declarations
// ==========================================================================
//

// None

@end







