//
//  AddressBook.m
//  Contacts
//
//  Created by Scott Carter on 11/16/12.
//  Copyright (c) 2012 Scott Carter. All rights reserved.
//

#import "AddressBook.h"

#import "Project.h"

#import "Types.h"


/*
 Description:
 
 
 */


// Total number of entries to populate will be AddressBookNumEntriesToPopulateBeforeSave * AddressBookNumLoopsForPopulate
NSUInteger const AddressBookNumEntriesToPopulateBeforeSave = 500; // 125 // Keep peak memory allocation under 11 MB

NSUInteger const AddressBookNumLoopsForPopulate = 1;            // 40
NSUInteger const AddressBookRandomSeedForPopulate = 4;


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Private Interface
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
@interface AddressBook ()

// ==========================================================================
// Properties
// ==========================================================================
//
#pragma mark -
#pragma mark Properties

// None

@end



// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Implementation
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
#pragma mark -
@implementation AddressBook

// ==========================================================================
// Constants and Defines
// ==========================================================================
//
#pragma mark -
#pragma mark Constants and Defines

#define ARRAY_LENGTH(a) ( sizeof ( a ) / sizeof ( *a ) )



// ==========================================================================
// Instance variables.  Could also be in interface section.
// ==========================================================================
//
#pragma mark -
#pragma mark Instance variables

// None


// ==========================================================================
// Synthesize public properties
// ==========================================================================
//
#pragma mark -
#pragma mark Synthesize public properties

// None


// ==========================================================================
// Synthesize private properties
// ==========================================================================
//
#pragma mark -
#pragma mark Synthesize private properties

// None


// ==========================================================================
// Getters and Setters
// ==========================================================================
//
#pragma mark -
#pragma mark Getters and Setters

// None


// ==========================================================================
// Actions
// ==========================================================================
//
#pragma mark -
#pragma mark Actions

// None



// ==========================================================================
// Initializations
// ==========================================================================
//
#pragma mark -
#pragma mark Initializations

// None


// ==========================================================================
// Protocol methods
// ==========================================================================
//
#pragma mark -
#pragma mark Protocol methods

// None




// ==========================================================================
// Class methods
// ==========================================================================
//
#pragma mark -
#pragma mark Class methods



// Remove all entries from Address Book
+ (BOOL)emptyAddressBook:(id)sender
                   error:(NSError **)error
{
    ABAddressBookRef addressBook_cf = ABAddressBookCreateWithOptions(NULL, nil);
    
    CFErrorRef error_cf = NULL;
    
    CFArrayRef peopleArr_cf = ABAddressBookCopyArrayOfAllPeople(addressBook_cf);
    
    NSArray *people = (NSArray *)CFBridgingRelease(peopleArr_cf);
    NSUInteger peopleCount = [people count];
    
    
    ABRecordRef record_cf = NULL;
    
    for (int i=0; i<peopleCount; i++){
        record_cf = CFBridgingRetain([people objectAtIndex:i]);
        
        if(!ABAddressBookRemoveRecord(addressBook_cf, record_cf, &error_cf)){
            
            // To test an error injection, use the following and replace the above if with if(1)
            // error_cf = CFErrorCreateWithUserInfoKeysAndValues (NULL,CFSTR("INJECT Address Book remove record error"),10,NULL,NULL,0);
            
            if(error != NULL){
                NSError *addressBookRemoveRecordError = CFBridgingRelease(error_cf);
                
                NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Address Book remove record failed", @""),
                                                  NSUnderlyingErrorKey : addressBookRemoveRecordError};
                *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookRemoveRecordError userInfo:errorDictionary];
                ERROR_LOG("%@",*error)
            }
            
            if(addressBook_cf){
                CFRelease(addressBook_cf);
            }
            if(record_cf){
                CFRelease(record_cf);
            }
            return NO;
        }
        
        CFRelease(record_cf);
    }
    
    if(peopleCount > 0) {
        if(!ABAddressBookSave(addressBook_cf,&error_cf)) {
            
            // To test an error injection, use the following and replace the above if with if(1)
            // error_cf = CFErrorCreateWithUserInfoKeysAndValues (NULL,CFSTR("INJECT Address Book save error"),10,NULL,NULL,0);
            
            if(error != NULL){
                NSError *addressBookSaveError = CFBridgingRelease(error_cf);
                
                NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Address Book save failed", @""),
                                                  NSUnderlyingErrorKey : addressBookSaveError};
                *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookSaveError userInfo:errorDictionary];
                ERROR_LOG("%@",*error)
            }
            
            if(addressBook_cf){
                CFRelease(addressBook_cf);
            }
            return NO;
        }
    }
    
    if(addressBook_cf){
        CFRelease(addressBook_cf);
    }
    
    return YES;
    
}


// Get a Foundation array of labels and values.
// Examples are phone numbers and e-mail addresses in AddressBook
//
// Reference:
// http://stackoverflow.com/questions/8965608/get-label-names-for-abperson-properties
//
+ (NSArray *)getMultiValueArrayforProperty:(ABPropertyID)property
                          forPropertyType:(ABPropertyType)propertyType
                               withRecord:(ABRecordRef)record_cf
                                  withMappingDict:(NSDictionary *)mappingDict
{
    
    ABMutableMultiValueRef multiValueArr_cf = ABRecordCopyValue(record_cf, property);
    CFIndex multiValueArrCount = ABMultiValueGetCount(multiValueArr_cf);
    
    // We will have an array of dictionaries, where each dictionary has a label and value.
    NSMutableArray *multiValueMutableArr = [[NSMutableArray alloc] initWithCapacity:multiValueArrCount];
    
    for(int arrIndex = 0; arrIndex < multiValueArrCount; arrIndex++) {
   
        CFStringRef arrLabel_cf = ABMultiValueCopyLabelAtIndex(multiValueArr_cf, arrIndex);
        
        // converts "_$!<Work>!$_" to "work" and "_$!<Mobile>!$_" to "mobile" etc.
        NSString *arrLocalizedLabel = CFBridgingRelease(ABAddressBookCopyLocalizedLabel( arrLabel_cf ));

        // We support string and date types
        id arrValue;
        if(propertyType ==  kABMultiDateTimePropertyType) {
            arrValue = (NSDate *)CFBridgingRelease(ABMultiValueCopyValueAtIndex( multiValueArr_cf, arrIndex ));
            
            NSDate *nullDate = [NSDate dateWithTimeIntervalSince1970:NullDateSeconds];
            arrValue = arrValue ? arrValue : nullDate;
            
        }
        
        else if(propertyType == kABMultiStringPropertyType) {
            arrValue = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex( multiValueArr_cf, arrIndex ));
            arrValue = arrValue ? arrValue : @"";
        }
        
        else if(propertyType == kABMultiDictionaryPropertyType) {
            NSDictionary *cfDict = (NSDictionary *)CFBridgingRelease(ABMultiValueCopyValueAtIndex( multiValueArr_cf, arrIndex ));
            
            NSMutableDictionary *detailMutableDict = [[NSMutableDictionary alloc] init];
            
            // Our mappingDict has information on how to map CF keys to our Foundation keys
            [mappingDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *cfKey = (NSString *)obj; // The Core Foundation key in Address Book
                NSString *fKey = (NSString *)key; // Foundation key for our own data structure
                NSString *value = [cfDict objectForKey:cfKey]; // Get Address Book value
                
                value = value ? value : @"";
                
                // Here we extracted value from CF dictionary and inserted into new dictionary using our own key.
                [detailMutableDict setValue:value forKey:fKey];
            }];
            
            arrValue = [[NSDictionary alloc] initWithDictionary:detailMutableDict];
        }
        
        else {
            EXCEPTION_LOG("Unsupported property type")
        }
     

        NSDictionary *recordEntryDict = [[NSDictionary alloc] initWithObjectsAndKeys:arrLocalizedLabel ? arrLocalizedLabel : @"",@"label",arrValue,@"value",nil];
        
        [multiValueMutableArr addObject:recordEntryDict];
        
        
        // Release reference.  Make sure label isn't NULL ("").  For SocialProfile services, the label is actually "".
        if(arrLabel_cf){
            CFRelease(arrLabel_cf);
        }
    }
    
    if(multiValueArr_cf) {
        CFRelease(multiValueArr_cf);
    }
    
    // Sort the array and return it.
    NSArray *multiValueArr = [self sortMultiValueArray:multiValueMutableArr forPropertyType:propertyType];
    return multiValueArr;
}




// Helper routine for getMultiValueArrayforProperty:forPropertyType:withRecord:withMappingDict:
//
+ (NSArray *)sortMultiValueArray:(NSArray *)arrToSort
                 forPropertyType:(ABPropertyType)propertyType
{
    // Sort the array on the concatentation of label and stringified value
    NSArray *sortedArray = [arrToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *dict1 = (NSDictionary *)obj1;
        NSDictionary *dict2 = (NSDictionary *)obj2;
        
        NSString *label1 = [dict1 objectForKey:@"label"];
        NSString *label2 = [dict2 objectForKey:@"label"];
        
        NSString *value1 = @"";
        NSString *value2 = @"";
        if(propertyType ==  kABMultiDateTimePropertyType) {
            value1 = [[dict1 objectForKey:@"value"] description];
            value2 = [[dict2 objectForKey:@"value"] description];
        }
        
        else if(propertyType == kABMultiStringPropertyType) {
            value1 = [dict1 objectForKey:@"value"];
            value2 = [dict2 objectForKey:@"value"];
        }
        
        else if(propertyType == kABMultiDictionaryPropertyType) {
            // Get the detailed dictionary, sort the keys and get the string value associated with key
            NSDictionary *detailDict1 = [dict1 objectForKey:@"value"];
            for(NSString *detailKey in [[detailDict1 allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
                value1 = [value1 stringByAppendingString:[detailDict1 objectForKey:detailKey]];
            }
            
            NSDictionary *detailDict2 = [dict2 objectForKey:@"value"];
            for(NSString *detailKey in [[detailDict2 allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
                value2 = [value2 stringByAppendingString:[detailDict2 objectForKey:detailKey]];
            }
        }
        
        else {
            EXCEPTION_LOG("Unsupported propertyType")
        }
        
        NSString *compare1 = [label1 stringByAppendingString:value1];
        NSString *compare2 = [label2 stringByAppendingString:value2];
        
        return [compare1 compare:compare2];
    }];

    return sortedArray;
}




+ (NSArray *)getPersonRecordArrayWithFields:(recordFields)fields
                            withAddressBook:(ABAddressBookRef)addressBook_cf
{

    CFArrayRef peopleArr_cf = ABAddressBookCopyArrayOfAllPeople(addressBook_cf);
    
    
    NSArray *people = (NSArray *)CFBridgingRelease(peopleArr_cf);
    NSUInteger peopleCount = [people count];

    
    NSMutableArray *personRecordMutableArr = [[NSMutableArray alloc] initWithCapacity:peopleCount];
    
    ABRecordRef record_cf = NULL;
    
    for (int i=0; i<peopleCount; i++){
        
        // Get a person record
        record_cf = CFBridgingRetain([people objectAtIndex:i]);
        
        ABRecordID recordId_cf = ABRecordGetRecordID(record_cf);
        
        // Get record for this person in Foundation structure
        NSDictionary *personRecordDict;
        
        // Include everything, or everything except modification date
        if( (fields == RecordFieldsAll) || (fields == RecordFieldsAllExceptModificationDate) ) {
            NSDictionary *initialRecordDict = [[NSDictionary alloc] init]; // Here we start with empty dictionary
            
            personRecordDict = [self getPersonRecordDictionaryForRecordId:(NSUInteger)recordId_cf withAddressBook:addressBook_cf forRecordFields:fields withRecordDict:initialRecordDict];
        }
        
        // fields == RecordFieldsModificationDate
        // Only modificationDate and recordId
        else {
            NSDate *nullDate = [NSDate dateWithTimeIntervalSince1970:NullDateSeconds];
            
            NSDate *modificationDate = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonModificationDateProperty));
            modificationDate =  modificationDate ? modificationDate : nullDate;

            NSNumber *recordIdNum = [NSNumber numberWithUnsignedInteger:(NSUInteger)recordId_cf];
            
            personRecordDict = [[NSDictionary alloc] initWithObjectsAndKeys:modificationDate, @"modificationDate", recordIdNum, @"addressBookRecordId", nil];
        }
        
        CFRelease(record_cf);
        
        // Add to our person record arrary
        [personRecordMutableArr addObject:personRecordDict];
    }
    
    
    NSArray *personRecordArr = [[NSArray alloc] initWithArray:personRecordMutableArr];
    
    return personRecordArr;
}


// Get a dictionary for Address Book information using recordId
//
+ (NSDictionary *)getPersonRecordDictionaryForRecordId:(NSUInteger)recordId
                                       withAddressBook:(ABAddressBookRef)addressBook_cf
                                       forRecordFields:(recordFields)fields
                                        withRecordDict:(NSDictionary *)initialRecordDict
{
    
    ABRecordRef record_cf = ABAddressBookGetPersonWithRecordID(addressBook_cf, (ABRecordID)recordId);
    
    return [self getPersonRecordDictionaryForRecord:record_cf withAddressBook:addressBook_cf forRecordFields:fields withRecordDict:initialRecordDict];
    
}



// Get a dictionary for Address Book information using record_cf
//
+ (NSDictionary *)getPersonRecordDictionaryForRecord:(ABRecordRef)record_cf
                                     withAddressBook:(ABAddressBookRef)addressBook_cf
                                     forRecordFields:(recordFields)fields
                                      withRecordDict:(NSDictionary *)initialRecordDict
{
    
    NSMutableDictionary *personRecordMutableDict = [[NSMutableDictionary alloc] initWithDictionary:initialRecordDict];
    

    NSDictionary *personRecordDict;
    
    NSDate *nullDate = [NSDate dateWithTimeIntervalSince1970:NullDateSeconds];

    ABRecordID recordId_cf = ABRecordGetRecordID(record_cf);
    NSUInteger recordId = (NSUInteger)recordId_cf;
    
    
    // ----------------------------------
    // Add the recordId
    // ----------------------------------
    //
    [personRecordMutableDict setObject:[NSNumber numberWithUnsignedInteger:recordId] forKey:@"addressBookRecordId"];
    
    
    // ----------------------------------
    // Modification Date
    // ----------------------------------
    //
    
    // Do we exclude modification date?
    if(fields != RecordFieldsAllExceptModificationDate) { // i.e. fields = RecordFieldsModificationDate | RecordFieldsAll
        NSDate *modificationDate = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonModificationDateProperty));
        [personRecordMutableDict setObject:modificationDate ? modificationDate : nullDate forKey:@"modificationDate"];
    }

    // Do we only include modification date?
    if(fields == RecordFieldsModificationDate) {
        personRecordDict = [[NSDictionary alloc] initWithDictionary:personRecordMutableDict];
        return personRecordDict;
    }
    
    // -------------------------------------------
    // Image Properties
    // -------------------------------------------
    //
    
    
    NSData *imageOriginal = CFBridgingRelease(ABPersonCopyImageDataWithFormat(record_cf, kABPersonImageFormatOriginalSize));
    
    if(!imageOriginal) {
        // Represent an empty image with a single byte = 0
        imageOriginal = [NSData dataWithData:[NSMutableData dataWithLength:1]];
    }

   
    NSData *imageThumbnail = CFBridgingRelease(ABPersonCopyImageDataWithFormat(record_cf, kABPersonImageFormatThumbnail));
    
    if(!imageThumbnail) {
        imageThumbnail = [NSData dataWithData:[NSMutableData dataWithLength:1]];
    }

    [personRecordMutableDict setObject:imageThumbnail forKey:@"imageThumbnail"];
    [personRecordMutableDict setObject:imageOriginal forKey:@"imageOriginal"];
    
    
    
    // -------------------------------------------
    // Person Kind Property
    // -------------------------------------------
    // kABPersonKindProperty of type kABIntegerPropertyType
    //
    // Values are one of:
    // kABPersonKindPerson
    // kABPersonKindOrganization
    NSNumber *personKind = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonKindProperty));
    [personRecordMutableDict setObject:personKind forKey:@"personKind"];
    
    
    // -------------------------------------------
    // Personal Information Properties
    // -------------------------------------------
    //
    // First and last name may be needed for sorting and these can't be null.
    // We won't use null for other properties either.
    //
    NSString *firstName = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonFirstNameProperty));
    [personRecordMutableDict setObject:firstName ? firstName : @"" forKey:@"firstName"];
    
    NSString *middleName = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonMiddleNameProperty));
    [personRecordMutableDict setObject:middleName ? middleName : @"" forKey:@"middleName"];
    
    NSString *lastName = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonLastNameProperty));
    [personRecordMutableDict setObject:lastName ? lastName : @"" forKey:@"lastName"];
    
    NSString *prefix = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonPrefixProperty));
    [personRecordMutableDict setObject:prefix ? prefix : @"" forKey:@"prefix"];
    
    NSString *suffix = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonSuffixProperty));
    [personRecordMutableDict setObject:suffix ? suffix : @"" forKey:@"suffix"];
    
    NSString *nickname = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonNicknameProperty));
    [personRecordMutableDict setObject:nickname ? nickname : @"" forKey:@"nickname"];
    
    NSString *firstNamePhonetic = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonFirstNamePhoneticProperty));
    [personRecordMutableDict setObject:firstNamePhonetic ? firstNamePhonetic : @"" forKey:@"firstNamePhonetic"];
    
    NSString *lastNamePhonetic = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonLastNamePhoneticProperty));
    [personRecordMutableDict setObject:lastNamePhonetic ? lastNamePhonetic : @"" forKey:@"lastNamePhonetic"];
    
    // Note: The middle name phonetic property doesn't seem to be accessible from Apple's Contacts app.
    NSString *middleNamePhonetic = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonMiddleNamePhoneticProperty));
    [personRecordMutableDict setObject:middleNamePhonetic ? middleNamePhonetic : @"" forKey:@"middleNamePhonetic"];
    
    NSString *organization = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonOrganizationProperty));
    [personRecordMutableDict setObject:organization ? organization : @"" forKey:@"organization"];
    
    NSString *jobTitle = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonJobTitleProperty));
    [personRecordMutableDict setObject:jobTitle ? jobTitle : @"" forKey:@"jobTitle"];
    
    NSString *department = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonDepartmentProperty));
    [personRecordMutableDict setObject:department ? department : @"" forKey:@"department"];
    
    NSString *note = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonNoteProperty));
    [personRecordMutableDict setObject:note ? note : @"" forKey:@"note"];
    
    
    // Personal dates
    //
    NSDate *birthday = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonBirthdayProperty));
    [personRecordMutableDict setObject:birthday ? birthday : nullDate forKey:@"birthday"];
    
    
    NSDate *creationDate = CFBridgingRelease(ABRecordCopyValue(record_cf, kABPersonCreationDateProperty));
    [personRecordMutableDict setObject:creationDate ? creationDate : nullDate forKey:@"creationDate"];
   
 
    
    // --------------------------------------------
    // Date properties
    // --------------------------------------------
    
    NSArray *dateArr = [self getMultiValueArrayforProperty:kABPersonDateProperty forPropertyType:kABMultiDateTimePropertyType withRecord:record_cf withMappingDict:nil];
    [personRecordMutableDict setObject:dateArr forKey:@"date"];

    
    // --------------------------------------------
    // URL Properties
    // --------------------------------------------
    //
    // Add url array to our person record dictionary
    NSArray *urlArr = [self getMultiValueArrayforProperty:kABPersonURLProperty forPropertyType:kABMultiStringPropertyType withRecord:record_cf withMappingDict:nil];
    [personRecordMutableDict setObject:urlArr forKey:@"url"];
    

    // --------------------------------------------
    // Related Name Properties
    // --------------------------------------------
    //
    // Add related array to our person record dictionary
    NSArray *relatedArr = [self getMultiValueArrayforProperty:kABPersonRelatedNamesProperty forPropertyType:kABMultiStringPropertyType withRecord:record_cf withMappingDict:nil];
    [personRecordMutableDict setObject:relatedArr forKey:@"related"];
    

    
    // --------------------------------------------
    // Phone Number Properties
    // --------------------------------------------
    //
    // Add phone number array to our person record dictionary
    NSArray *phoneNumberArr = [self getMultiValueArrayforProperty:kABPersonPhoneProperty forPropertyType:kABMultiStringPropertyType withRecord:record_cf withMappingDict:nil];
    [personRecordMutableDict setObject:phoneNumberArr forKey:@"phone"];

    
    
    // --------------------------------------------
    // Email Properties
    // --------------------------------------------
    //
    // Add email address array to our person record dictionary
    NSArray *emailAddressArr = [self getMultiValueArrayforProperty:kABPersonEmailProperty forPropertyType:kABMultiStringPropertyType withRecord:record_cf withMappingDict:nil];
    [personRecordMutableDict setObject:emailAddressArr forKey:@"email"];
    

    // -----------------------------------------------
    // Address Properties
    // -----------------------------------------------
    //
    NSDictionary *addressKeyMappingDict = [self mappingDictForAddressKey];
    
    NSArray *addressArr = [self getMultiValueArrayforProperty:kABPersonAddressProperty forPropertyType:kABMultiDictionaryPropertyType withRecord:record_cf withMappingDict:addressKeyMappingDict];
    [personRecordMutableDict setObject:addressArr forKey:@"address"];
    
    
    // -----------------------------------------------
    // Instant Messaging Properties
    // -----------------------------------------------
    //
    NSDictionary *instantMessagingKeyMappingDict = [self mappingDictForInstantMessagingKey];
    
    NSArray *instantMessagingArr = [self getMultiValueArrayforProperty:kABPersonInstantMessageProperty forPropertyType:kABMultiDictionaryPropertyType withRecord:record_cf withMappingDict:instantMessagingKeyMappingDict];
    [personRecordMutableDict setObject:instantMessagingArr forKey:@"instantMessaging"];
    

    // -----------------------------------------------
    // Social Profile Properties
    // -----------------------------------------------
    //
    NSDictionary *socialProfileKeyMappingDict = [self mappingDictForSocialProfileKey];
    
    NSArray *socialProfileArr = [self getMultiValueArrayforProperty:kABPersonSocialProfileProperty forPropertyType:kABMultiDictionaryPropertyType withRecord:record_cf withMappingDict:socialProfileKeyMappingDict];
    [personRecordMutableDict setObject:socialProfileArr forKey:@"socialProfile"];
    


    

    personRecordDict = [[NSDictionary alloc] initWithDictionary:personRecordMutableDict copyItems:YES];
    
    return personRecordDict;
}


// Mapping dictionary to translate Foundation keys to CF keys for Address properties
+ (NSDictionary *)mappingDictForAddressKey
{
    return [[NSDictionary alloc] initWithObjectsAndKeys:(NSString *)CFBridgingRelease(kABPersonAddressStreetKey),@"street",(NSString *)CFBridgingRelease(kABPersonAddressCityKey),@"city",(NSString *)CFBridgingRelease(kABPersonAddressStateKey),@"state",(NSString *)CFBridgingRelease(kABPersonAddressZIPKey),@"zip",(NSString *)CFBridgingRelease(kABPersonAddressCountryKey),@"country",(NSString *)CFBridgingRelease(kABPersonAddressCountryCodeKey), @"countryCode",nil];
}


// Mapping dictionary to translate Foundation keys to CF keys for Instant Messaging properties
+ (NSDictionary *)mappingDictForInstantMessagingKey
{
    return [[NSDictionary alloc] initWithObjectsAndKeys:(NSString *)CFBridgingRelease(kABPersonInstantMessageUsernameKey),@"username",(NSString *)CFBridgingRelease(kABPersonInstantMessageServiceKey),@"service",nil];
}


// Mapping dictionary to translate Foundation keys to CF keys for Social Profile properties
+ (NSDictionary *)mappingDictForSocialProfileKey
{
    return [[NSDictionary alloc] initWithObjectsAndKeys:(NSString *)CFBridgingRelease(kABPersonSocialProfileURLKey),@"url",(NSString *)CFBridgingRelease(kABPersonSocialProfileServiceKey),@"service",kABPersonSocialProfileUsernameKey,@"username",kABPersonSocialProfileUserIdentifierKey,@"identifier",nil];
}



// Add a new record to Address Book using the information in personDict
//
// Caller retains ownership of Core Foundation object returned, so method is prefixed with "new"
//
+ (ABRecordRef)newPersonRecordUsingDictionary:(NSDictionary *)personDict
                              withAddressBook:(ABAddressBookRef)addressBook_cf
                                        error:(NSError **)error
{
    CFErrorRef error_cf = NULL;
    
    ABRecordRef record_cf = ABPersonCreate();
    
    
    // Set properties in record_cf using personDict
    if(![self personRecordUsingDictionary:personDict withRecord:record_cf error:error]){
        if(record_cf){
            CFRelease(record_cf);
        }
        return NULL;
    }
    

    // Add the record
    if(!ABAddressBookAddRecord(addressBook_cf, record_cf, &error_cf)){
        
        // To test an error injection, use the following and replace the above if with if(1)
        // error_cf = CFErrorCreateWithUserInfoKeysAndValues (NULL,CFSTR("INJECT Address Book add record error"),10,NULL,NULL,0);
        
        if(error != NULL){
            NSError *addressBookAddRecordError = CFBridgingRelease(error_cf);
            
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Address Book add record failed", @""),
                                              NSUnderlyingErrorKey : addressBookAddRecordError};
            *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookAddRecordError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        
        if(record_cf){
            CFRelease(record_cf);
        }
        return NULL;
    }
    
    return record_cf;
}


// Test to see if passed string is empty.  If it is return NULL, else return the string.
+ (CFStringRef)nullIfStringEmpty:(CFStringRef)str_cf
{
    CFComparisonResult result = CFStringCompare (str_cf,CFSTR(""), 0);
    
    if(result == kCFCompareEqualTo){
        return NULL;
    }
    return str_cf;
}



// Set properties in record_cf using personDict
//
//
// We use nullIfStringEmpty for the single line string properties. Thus if a string is empty,
// we set the corresponding property to NULL to remove the property from the database.
// This is particularly important for the properties that determine sorting - firstName, firstNamePhonetic,
// lastName, lastNamePhonetic.   If we instead injected an empty string "" to say lastNamePhonetic
// (which has higher sort priority than lastName) when sorting by lastName, the associated record
// would end up in the "#" section - unsorted.
//
// For birthday, we compare against our nullDate reference.  If it matches, we set the birthday property
// to NULL to remove it.
//
+ (BOOL)personRecordUsingDictionary:(NSDictionary *)personDict
                         withRecord:(ABRecordRef)record_cf
                              error:(NSError **)error
{

    NSDate *nullDate = [NSDate dateWithTimeIntervalSince1970:NullDateSeconds];
    
    
    CFErrorRef error_cf = NULL;
    
    // ----------------------------------
    // Modification Date
    // ----------------------------------
    //
    CFDataRef modificationDate_cf = (CFDataRef)CFBridgingRetain([personDict objectForKey:@"modificationDate"]);
    if(![self recordSetValue:modificationDate_cf forRecord:record_cf forProperty:@"modificationDate" withPropertyID:kABPersonModificationDateProperty error:error]){
        
        CFRelease(modificationDate_cf);
        return NO;
    }
    
    CFRelease(modificationDate_cf);
    
    
    // -------------------------------------------
    // Image Properties
    // -------------------------------------------
    
    // Set Original image if it isn't empty.  We have defined an empty image as containing a single 0 byte.
    //
    if(![[personDict objectForKey:@"imageOriginal"] isEqualToData:[NSData dataWithData:[NSMutableData dataWithLength:1]]]){
        CFDataRef profileImageData_cf = (CFDataRef)CFBridgingRetain([personDict objectForKey:@"imageOriginal"]);
        
        
        if(!ABPersonSetImageData(record_cf, profileImageData_cf, &error_cf)){
            if(error != NULL){
                NSError *addressBookSetImageError = CFBridgingRelease(error_cf);
                
                NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Can't set image", @""),
                                                  NSUnderlyingErrorKey : addressBookSetImageError};
                *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookSetImageError userInfo:errorDictionary];
                ERROR_LOG("%@",*error)
            }
            
            if(profileImageData_cf){
                CFRelease(profileImageData_cf);
            }
            return NO;
        }
        
        CFRelease(profileImageData_cf);
    }
    
    
    // -------------------------------------------
    // Person Kind Property
    // -------------------------------------------
    //
    CFNumberRef personKind_cf = (CFNumberRef)CFBridgingRetain([personDict objectForKey:@"personKind"]);
    
    if(![self recordSetValue:personKind_cf forRecord:record_cf forProperty:@"personKind" withPropertyID:kABPersonKindProperty error:error]){
        CFRelease(personKind_cf);
        return NO;
    }
    
    CFRelease(personKind_cf);
    
    // -------------------------------------------
    // Personal Information Properties
    // -------------------------------------------
    //
    // We don't directly set creationDate here.  It should get set automatically
    // upon record creation.
    
    CFStringRef firstName_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"firstName"]);
    firstName_cf = [self nullIfStringEmpty:firstName_cf];
    if(![self recordSetValue:firstName_cf forRecord:record_cf forProperty:@"firstName" withPropertyID:kABPersonFirstNameProperty error:error]){
        CFRelease(firstName_cf);
        return NO;
    }
    if(firstName_cf){
        CFRelease(firstName_cf);
    }
    
    CFStringRef middleName_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"middleName"]);
    middleName_cf = [self nullIfStringEmpty:middleName_cf];
    if(![self recordSetValue:middleName_cf forRecord:record_cf forProperty:@"middleName" withPropertyID:kABPersonMiddleNameProperty error:error]){
        CFRelease(middleName_cf);
        return NO;
    }
    if(middleName_cf){
        CFRelease(middleName_cf);
    }
    
    
    CFStringRef lastName_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"lastName"]);
    lastName_cf = [self nullIfStringEmpty:lastName_cf];
    if(![self recordSetValue:lastName_cf forRecord:record_cf forProperty:@"lastName" withPropertyID:kABPersonLastNameProperty error:error]){
        CFRelease(lastName_cf);
        return NO;
    }
    if(lastName_cf){
        CFRelease(lastName_cf);
    }

    
    CFStringRef prefix_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"prefix"]);
    prefix_cf = [self nullIfStringEmpty:prefix_cf];
    if(![self recordSetValue:prefix_cf forRecord:record_cf forProperty:@"prefix" withPropertyID:kABPersonPrefixProperty error:error]){
        CFRelease(prefix_cf);
        return NO;
    }
    if(prefix_cf){
        CFRelease(prefix_cf);
    }
    
    
    CFStringRef suffix_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"suffix"]);
    suffix_cf = [self nullIfStringEmpty:suffix_cf];
    if(![self recordSetValue:suffix_cf forRecord:record_cf forProperty:@"suffix" withPropertyID:kABPersonSuffixProperty error:error]){
        CFRelease(suffix_cf);
        return NO;
    }
    if(suffix_cf){
        CFRelease(suffix_cf);
    }
    
    
    CFStringRef nickname_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"nickname"]);
    nickname_cf = [self nullIfStringEmpty:nickname_cf];
    if(![self recordSetValue:nickname_cf forRecord:record_cf forProperty:@"nickname" withPropertyID:kABPersonNicknameProperty error:error]){
        CFRelease(nickname_cf);
        return NO;
    }
    if(nickname_cf){
        CFRelease(nickname_cf);
    }
    
    
    
    CFStringRef firstNamePhonetic_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"firstNamePhonetic"]);
    firstNamePhonetic_cf = [self nullIfStringEmpty:firstNamePhonetic_cf];
    if(![self recordSetValue:firstNamePhonetic_cf forRecord:record_cf forProperty:@"firstNamePhonetic" withPropertyID:kABPersonFirstNamePhoneticProperty error:error]){
        CFRelease(firstNamePhonetic_cf);
        return NO;
    }
    if(firstNamePhonetic_cf){
        CFRelease(firstNamePhonetic_cf);
    }
    
    
    CFStringRef lastNamePhonetic_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"lastNamePhonetic"]);
    lastNamePhonetic_cf = [self nullIfStringEmpty:lastNamePhonetic_cf];
    if(![self recordSetValue:lastNamePhonetic_cf forRecord:record_cf forProperty:@"lastNamePhonetic" withPropertyID:kABPersonLastNamePhoneticProperty error:error]){
        CFRelease(lastNamePhonetic_cf);
        return NO;
    }
    if(lastNamePhonetic_cf){
        CFRelease(lastNamePhonetic_cf);
    }
    
    
    CFStringRef middleNamePhonetic_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"middleNamePhonetic"]);
    middleNamePhonetic_cf = [self nullIfStringEmpty:middleNamePhonetic_cf];
    if(![self recordSetValue:middleNamePhonetic_cf forRecord:record_cf forProperty:@"middleNamePhonetic" withPropertyID:kABPersonMiddleNamePhoneticProperty error:error]){
        CFRelease(middleNamePhonetic_cf);
        return NO;
    }
    if(middleNamePhonetic_cf){
        CFRelease(middleNamePhonetic_cf);
    }
    
    
    // If you set kABPersonKindProperty to kABPersonKindOrganization, you cannot set kABPersonOrganizationProperty
    // or you will get a memory leak.  See newRandomPerson method for more info.  I'm going to ignore this for
    // now here, since the leak doesn't appear in iOS 6.0 and the Apple Contacts app has no way to designate a record
    // as an organization.
    //
    CFStringRef organization_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"organization"]);
    organization_cf = [self nullIfStringEmpty:organization_cf];
    if(![self recordSetValue:organization_cf forRecord:record_cf forProperty:@"organization" withPropertyID:kABPersonOrganizationProperty error:error]){
        CFRelease(organization_cf);
        return NO;
    };
    if(organization_cf){
        CFRelease(organization_cf);
    }
    
    
    CFStringRef jobTitle_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"jobTitle"]);
    jobTitle_cf = [self nullIfStringEmpty:jobTitle_cf];
    if(![self recordSetValue:jobTitle_cf forRecord:record_cf forProperty:@"jobTitle" withPropertyID:kABPersonJobTitleProperty error:error]){
        CFRelease(jobTitle_cf);
        return NO;
    }
    if(jobTitle_cf){
        CFRelease(jobTitle_cf);
    }
    
    
    CFStringRef department_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"department"]);
    department_cf = [self nullIfStringEmpty:department_cf];
    if(![self recordSetValue:department_cf forRecord:record_cf forProperty:@"department" withPropertyID:kABPersonDepartmentProperty error:error]){
        CFRelease(department_cf);
        return NO;
    }
    if(department_cf){
        CFRelease(department_cf);
    }
    
    
    CFStringRef note_cf = (CFStringRef)CFBridgingRetain([personDict objectForKey:@"note"]);
    note_cf = [self nullIfStringEmpty:note_cf];
    if(![self recordSetValue:note_cf forRecord:record_cf forProperty:@"note" withPropertyID:kABPersonNoteProperty error:error]){
        CFRelease(note_cf);
        return NO;
    }
    if(note_cf){
        CFRelease(note_cf);
    }
    
    
    
    // Personal dates
    //
    CFDataRef birthday_cf = NULL;
    NSDate *birthday = [personDict objectForKey:@"birthday"];
    if(![birthday isEqualToDate:nullDate]){
        birthday_cf = (CFDataRef)CFBridgingRetain(birthday);
    }
    
    if(![self recordSetValue:birthday_cf forRecord:record_cf forProperty:@"birthday" withPropertyID:kABPersonBirthdayProperty error:error]){
        CFRelease(birthday_cf);
        return NO;
    }
    if(birthday_cf){
        CFRelease(birthday_cf);
    }

    
    // --------------------------------------------
    // Date Properties
    // --------------------------------------------
    //
    if(![self recordSetMultiValue:[personDict objectForKey:@"date"] forRecord:record_cf forProperty:@"date" withPropertyID:kABPersonDateProperty withPropertyType:kABMultiDateTimePropertyType error:error]){
        return NO;
    }
    
    
    // --------------------------------------------
    // Url Properties
    // --------------------------------------------
    //
    if(![self recordSetMultiValue:[personDict objectForKey:@"url"] forRecord:record_cf forProperty:@"url" withPropertyID:kABPersonURLProperty withPropertyType:kABMultiStringPropertyType error:error]){
        return NO;
    }
    
    
    // --------------------------------------------
    // Related Properties
    // --------------------------------------------
    //
    if(![self recordSetMultiValue:[personDict objectForKey:@"related"] forRecord:record_cf forProperty:@"related" withPropertyID:kABPersonRelatedNamesProperty withPropertyType:kABMultiStringPropertyType error:error]){
        return NO;
    }
    
    
    // --------------------------------------------
    // Phone Number Properties
    // --------------------------------------------
    //
    if(![self recordSetMultiValue:[personDict objectForKey:@"phone"] forRecord:record_cf forProperty:@"phone" withPropertyID:kABPersonPhoneProperty  withPropertyType:kABMultiStringPropertyType error:error]){
        return NO;
    }
    
    
    
    // --------------------------------------------
    // Email Address Properties
    // --------------------------------------------
    //
    if(![self recordSetMultiValue:[personDict objectForKey:@"email"] forRecord:record_cf forProperty:@"email" withPropertyID:kABPersonEmailProperty   withPropertyType:kABMultiStringPropertyType error:error]){
        return NO;
    }
    
    
    // -----------------------------------------------
    // Address Properties
    // -----------------------------------------------
    //
    NSDictionary *addressKeyMappingDict = [self mappingDictForAddressKey];
    if(![self recordSetMultiValueDictForRecord:[personDict objectForKey:@"address"] forRecord:record_cf forProperty:@"address" withPropertyID:kABPersonAddressProperty withMappingDict:addressKeyMappingDict error:error]){
        return NO;
    }
    
    
    // -----------------------------------------------
    // Instant Messaging Properties
    // -----------------------------------------------
    //
    NSDictionary *instantMessagingKeyMappingDict = [self mappingDictForInstantMessagingKey];
    if(![self recordSetMultiValueDictForRecord:[personDict objectForKey:@"instantMessaging"] forRecord:record_cf forProperty:@"instantMessaging" withPropertyID:kABPersonInstantMessageProperty withMappingDict:instantMessagingKeyMappingDict error:error]){
        return NO;
    }
    
    
    // -----------------------------------------------
    // Social Profile Properties
    // -----------------------------------------------
    //
    NSDictionary *socialProfileKeyMappingDict = [self mappingDictForSocialProfileKey];
    if(![self recordSetMultiValueDictForRecord:[personDict objectForKey:@"socialProfile"] forRecord:record_cf forProperty:@"socialProfile" withPropertyID:kABPersonSocialProfileProperty withMappingDict:socialProfileKeyMappingDict error:error]){
        return NO;
    }
    
    return YES;
}


// Set a simple value in a record
+ (BOOL)recordSetValue:(CFTypeRef)value_cf
             forRecord:(ABRecordRef)record_cf
           forProperty:(NSString *)property
            withPropertyID:(ABPropertyID)propertyID
                 error:(NSError **)error
{
    
    CFErrorRef error_cf = NULL;
    
    if(!ABRecordSetValue(record_cf, propertyID, value_cf, &error_cf)) {
        
        if(error != NULL){
            NSError *addressBookRecordSetValueError = CFBridgingRelease(error_cf);
            
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABRecordSetValue", @""),
                                              NSUnderlyingErrorKey : addressBookRecordSetValueError};
            *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookRecordSetValueError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        return NO;
    }
    
    return YES;
}


// Save a change in a simple value to the Address Book.
// Lookup the record using recordId
+ (ABRecordRef)recordSaveValue:(CFTypeRef)value_cf
           forRecordId:(NSUInteger)recordId
           forProperty:(NSString *)property
        withPropertyID:(ABPropertyID)propertyID
       withAddressBook:(ABAddressBookRef)addressBook_cf
                         error:(NSError **)error
{
    ABRecordRef record_cf = ABAddressBookGetPersonWithRecordID(addressBook_cf, (ABRecordID)recordId);
    
    CFErrorRef error_cf = NULL;
    
    if(!ABRecordSetValue(record_cf, propertyID, value_cf, &error_cf)) {
        
        if(error != NULL){
            NSError *addressBookRecordSetValueError = CFBridgingRelease(error_cf);
            
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABRecordSetValue", @""),
                                              NSUnderlyingErrorKey : addressBookRecordSetValueError};
            *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookRecordSetValueError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        return NULL;
    }
    
    if(!ABAddressBookSave(addressBook_cf,&error_cf)) {
        
        if(error != NULL){
            NSError *addressBookSaveError = CFBridgingRelease(error_cf);
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Address Book save failed", @""),
                                              NSUnderlyingErrorKey : addressBookSaveError};
            *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookSaveError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        return NULL;
    }
    
    return record_cf;
}



// Set a multi value in a record for string and datetime property types
+ (BOOL)recordSetMultiValue:(NSArray *)dictionaryArr
                  forRecord:(ABRecordRef)record_cf
                             forProperty:(NSString *)property
                          withPropertyID:(ABPropertyID)propertyID
                        withPropertyType:(ABPropertyType)propertyType
                      error:(NSError **)error
{
    CFErrorRef error_cf = NULL;
    
    ABMutableMultiValueRef multiValue_cf = ABMultiValueCreateMutable(propertyType);
    
    if( (propertyType == kABMultiDateTimePropertyType) || (propertyType == kABMultiStringPropertyType) ) {
        
        for (NSDictionary *dict in dictionaryArr) {
            CFStringRef label_cf = (CFStringRef)CFBridgingRetain([dict objectForKey:@"label"]);
            
            CFTypeRef value_cf;
            
            if(propertyType == kABMultiDateTimePropertyType) {
                CFDateRef date_cf = (CFDateRef)CFBridgingRetain([dict objectForKey:@"value"]);
                value_cf = date_cf;
            }
            else {
                CFStringRef string_cf = (CFStringRef)CFBridgingRetain([dict objectForKey:@"value"]);
                value_cf = string_cf;
            }
            
            if(!ABMultiValueAddValueAndLabel(multiValue_cf, value_cf, label_cf, NULL)) {
                if(error != NULL){
                    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABMultiValueAddValueAndLabel", @"")};
                    *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookMultiValueAddValueAndLabelError userInfo:errorDictionary];
                    ERROR_LOG("%@",*error)
                }
                if(value_cf){
                    CFRelease(value_cf);
                }
                if(label_cf){
                    CFRelease(label_cf);
                }
                if(multiValue_cf){
                    CFRelease(multiValue_cf);
                }
                return NO;
            }
            
            if(value_cf){
                CFRelease(value_cf);
            }
            if(label_cf){
                CFRelease(label_cf);
            }
        }
        
    }
    
    else {
        EXCEPTION_LOG("Unsupported property type")
    }
    
    
    
    if(!ABRecordSetValue(record_cf, propertyID, multiValue_cf, &error_cf)) {
        if(error != NULL){
            NSError *addressBookRecordSetValueError = CFBridgingRelease(error_cf);
            
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABRecordSetValue", @""),
                                              NSUnderlyingErrorKey : addressBookRecordSetValueError};
            *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookRecordSetValueError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        if(multiValue_cf){
            CFRelease(multiValue_cf);
        }
        return NO;
    }
    
    if(multiValue_cf){
        CFRelease(multiValue_cf);
    }
    
    return YES;
}


// Set a multi value in a record for string and datetime property types
+ (BOOL)recordSetMultiValueDictForRecord:(NSArray *)dictionaryArr
                               forRecord:(ABRecordRef)record_cf
                                 forProperty:(NSString *)property
                              withPropertyID:(ABPropertyID)propertyID
                                    withMappingDict:(NSDictionary *)mappingDict
                                   error:(NSError **)error
{
    CFErrorRef error_cf = NULL;
    
    CFIndex mappingDictKeyCount = (CFIndex)[mappingDict count];
    
    
    ABMutableMultiValueRef multiValue_cf = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
 
    // Loop over each Foundation dictionary in array
    for (NSDictionary *dict in dictionaryArr) {
        CFStringRef label_cf = (CFStringRef)CFBridgingRetain([dict objectForKey:@"label"]); // Label for this Foundation dictionary
        
        NSDictionary *detailDict = [dict objectForKey:@"value"]; // Foundation detail dictionary
        
        CFMutableDictionaryRef detailDict_cf = CFDictionaryCreateMutable(kCFAllocatorDefault,mappingDictKeyCount,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);  // New Core Foundation detail dictionary
        
        // Our mappingDict has information on how to map CF keys to our Foundation keys
        [mappingDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            CFStringRef key_cf = (CFStringRef)CFBridgingRetain(obj); // The Core Foundation key in Address Book.  obj is an NSString
            NSString *key_f = (NSString *)key; // Foundation key for our own data structure
            
            // Get value from Foundation Dictionary using Foundation key.  Retain and cast to CF value.
            CFStringRef value_cf = (CFStringRef)CFBridgingRetain([detailDict objectForKey:key_f]);
            
            CFDictionaryAddValue (detailDict_cf, key_cf, value_cf);   // Add to CF detail dictionary.
            
            if(key_cf) {
                CFRelease(key_cf);
            }
            if(value_cf){
                CFRelease(value_cf);
            }
        }];

        
        if(!ABMultiValueAddValueAndLabel(multiValue_cf, detailDict_cf, label_cf, NULL)) {
            if(error != NULL){
                NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABMultiValueAddValueAndLabel", @"")};
                *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookMultiValueAddValueAndLabelError userInfo:errorDictionary];
                ERROR_LOG("%@",*error)
            }
            if(label_cf){
                CFRelease(label_cf);
            }
            if(detailDict_cf){
                CFRelease(detailDict_cf);
            }
            if(multiValue_cf) {
                CFRelease(multiValue_cf);
            }
            return NO;
        }
        
        if(label_cf){
            CFRelease(label_cf);
        }
        if(detailDict_cf){
            CFRelease(detailDict_cf);
        }
        
    }
    
    if(!ABRecordSetValue(record_cf, propertyID, multiValue_cf, &error_cf)) {
        if(error != NULL){
            NSError *addressBookRecordSetValueError = CFBridgingRelease(error_cf);
            
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABRecordSetValue", @""),
                                              NSUnderlyingErrorKey : addressBookRecordSetValueError};
            *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookRecordSetValueError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        if(multiValue_cf){
            CFRelease(multiValue_cf);
        }
        return NO;
    }
    
    
    // Release objects
    if(multiValue_cf) {
        CFRelease(multiValue_cf);
    }
    
    return YES;
    
}



// ==========================================================================
// Class methods for testing
// ==========================================================================
//
#pragma mark -
#pragma mark Class methods for testing



// Populate some dummy entries in AddressBook for testing
//
// We allow a single property to be fixed at the supplied value for testing if property != @""
//
// If allowSparseFields=YES, not all fields of a record need to be populated every time.
//
+ (BOOL)populateAddressBookWithSeed:(NSUInteger)randomSeed
                  allowSparseFields:(BOOL)allowSparseFields
              allowRandomDuplicates:(BOOL)allowRandomDuplicates
                        allowImages:(BOOL)allowImages
                numLoopsForPopulate:(NSUInteger)numLoopsForPopulate
     numEntriesToPopulateBeforeSave:(NSUInteger)numEntriesToPopulateBeforeSave
                        fixingProperty:(NSString *)property
                     withPropertyID:(ABPropertyID)propertyID
                          withValue:(CFTypeRef)value_cf
                              error:(NSError **)error
{
    
    
    // Set the seed for the random number generator for repeatable randomness.
    srandom((unsigned int)randomSeed);
  
    // Make several iterations of adding Address Book records and then saving.
    // We do this to keep peak memory allocations low.
    //
    // An @autoreleasepool is effective at releasing memory used in the process between
    // iterations.  Without this, the memory usage would grow with each iteration.
    // It would eventually be released at the end of the current run loop.
    //
    // An alternative to using @autoreleasepool is to use NSTimer to call
    // populateAddressBookForLoopIndex recursively.   This has the effect of
    // starting each iteration at a new run loop
    //
    
    // We need an intermediate NSError object to pass into the @autoreleasepool.  Can't pass in NSError **error without
    // seeing a BAD ACCESS crash.   I verified that this was the case by trying this with and without @autoreleasepool
    //
    BOOL loopSuccess = YES;
    NSError *tempError = nil;
    
    for(NSInteger loopIndex =0; loopIndex < numLoopsForPopulate; loopIndex ++){
        @autoreleasepool {
            if(![self populateAddressBookForLoopIndex:loopIndex allowSparseFields:allowSparseFields allowRandomDuplicates:allowRandomDuplicates allowImages:allowImages numLoopsForPopulate:numLoopsForPopulate numEntriesToPopulateBeforeSave:numEntriesToPopulateBeforeSave fixingProperty:property withPropertyID:propertyID withValue:value_cf error:&tempError]){
                loopSuccess = NO;
                break;
            }
        }
    }

    if(!loopSuccess){
        *error = tempError;
        return NO;
    }
    
    return YES;
}


// Handle one loop of populating Address Book entries.
// Called by populateAddressBook
+ (BOOL) populateAddressBookForLoopIndex:(NSInteger)loopIndex
                       allowSparseFields:(BOOL)allowSparseFields
                   allowRandomDuplicates:(BOOL)allowRandomDuplicates
                             allowImages:(BOOL)allowImages
                     numLoopsForPopulate:(NSUInteger)numLoopsForPopulate
          numEntriesToPopulateBeforeSave:(NSUInteger)numEntriesToPopulateBeforeSave
                          fixingProperty:(NSString *)property
                          withPropertyID:(ABPropertyID)propertyID
                               withValue:(CFTypeRef)value_cf
                                   error:(NSError **)error
{
    PLOG_POPULATE("Starting loop %d of %d for %d new entries",loopIndex,numLoopsForPopulate,numEntriesToPopulateBeforeSave)
    
    CFErrorRef error_cf = NULL;
    
    
    ABAddressBookRef addressBook_cf = ABAddressBookCreateWithOptions(NULL, nil);
    
    CFArrayRef peopleArr_cf = [self newRandomPeopleWithCount:numEntriesToPopulateBeforeSave allowSparseFields:allowSparseFields allowImages:allowImages fixingProperty:property withPropertyID:propertyID withValue:value_cf error:error];
    if(!peopleArr_cf){
        if(addressBook_cf){
            CFRelease(addressBook_cf);
        }
        return NO;
    }
    
    PLOG_RETAIN("retain count on peopleArr_cf = %ld",CFGetRetainCount(peopleArr_cf))
    
    CFIndex peopleArrCount = CFArrayGetCount(peopleArr_cf);
    
    ABRecordRef record_cf = NULL;
    
    for (int i=0; i<peopleArrCount; i++){
        
        record_cf = CFArrayGetValueAtIndex(peopleArr_cf, i);
        PLOG_RETAIN("i=%d retain count on record_cf=%ld",i,CFGetRetainCount(record_cf))
        
               
        if(!ABAddressBookAddRecord(addressBook_cf, record_cf, &error_cf)){  // addressBook_cf owns record_cf.  +2 on record_cf
            if(error != NULL){
                NSError *addressBookAddRecordError = CFBridgingRelease(error_cf);
                NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Address Book add record failed", @""),
                                                  NSUnderlyingErrorKey : addressBookAddRecordError};
                *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookAddRecordError userInfo:errorDictionary];
                ERROR_LOG("%@",*error)
            }
            
            if(peopleArr_cf) {
                CFRelease(peopleArr_cf);
            }
            if(addressBook_cf){
                CFRelease(addressBook_cf);
            }
            return NO;
        }
        
        
        // Randomly duplicate an Address Book entry that we just added so that we can test our duplicate record handler
        // (we eliminate duplicate records)
        NSUInteger percentage = 5;   // What percentage of the time to add duplicate entry.
        if(allowRandomDuplicates && ((random() % 100) < percentage)   ){
            PLOG_POPULATE("Adding duplicate entry for index %d in peopleArr_cf",i)
            
            // Get dictionary of record_cf content
            NSDictionary *personDict = [self getPersonRecordDictionaryForRecord:record_cf withAddressBook:addressBook_cf forRecordFields:RecordFieldsAll withRecordDict:@{}];
            
            // Create a new record and get its pointer
            ABRecordRef dupRecord_cf = [self newPersonRecordUsingDictionary:personDict withAddressBook:addressBook_cf error:error];
            if(!dupRecord_cf){
                if(peopleArr_cf) {
                    CFRelease(peopleArr_cf);
                }
                if(addressBook_cf){
                    CFRelease(addressBook_cf);
                }
                return NO;
            }
            
            
            if(!ABAddressBookAddRecord(addressBook_cf, dupRecord_cf, &error_cf)){
                if(error != NULL){
                    NSError *addressBookAddRecordError = CFBridgingRelease(error_cf);
                    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Address Book add record failed", @""),
                                                      NSUnderlyingErrorKey : addressBookAddRecordError};
                    *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookAddRecordError userInfo:errorDictionary];
                    ERROR_LOG("%@",*error)
                }
                
                if(peopleArr_cf) {
                    CFRelease(peopleArr_cf);
                }
                if(addressBook_cf){
                    CFRelease(addressBook_cf);
                }
                if(dupRecord_cf){
                    CFRelease(dupRecord_cf);
                }
                return NO;
            }
            
            CFRelease(dupRecord_cf);
        }

        
    }
    

    if(peopleArrCount > 0) {
        
        if(!ABAddressBookSave(addressBook_cf,&error_cf)) {
            if(error != NULL){
                NSError *addressBookSaveError = CFBridgingRelease(error_cf);
                NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Address Book save failed", @""),
                                                  NSUnderlyingErrorKey : addressBookSaveError};
                *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookSaveError userInfo:errorDictionary];
                ERROR_LOG("%@",*error)
            }
            
            if(peopleArr_cf) {
                CFRelease(peopleArr_cf);
            }
            if(addressBook_cf){
                CFRelease(addressBook_cf);
            }
            return NO;
        }
    }
    
    
    if(peopleArr_cf) {
        CFRelease(peopleArr_cf);
    }
    if(addressBook_cf){
        CFRelease(addressBook_cf);
    }
    return YES;
}



// Helper for populateAddressBook
//
// Create an array of people records with random information
//
// Caller retains ownership of Core Foundation object, so method is prefixed with "new"
//
+ (CFArrayRef)newRandomPeopleWithCount:(NSUInteger)numberOfRecords
                     allowSparseFields:(BOOL)allowSparseFields
                           allowImages:(BOOL)allowImages
                        fixingProperty:(NSString *)property
                        withPropertyID:(ABPropertyID)propertyID
                             withValue:(CFTypeRef)value_cf
                                 error:(NSError **)error
{
    CFMutableArrayRef peopleMutableArr_cf = CFArrayCreateMutable (kCFAllocatorDefault,0,&kCFTypeArrayCallBacks);
    
    CFErrorRef error_cf = NULL;
    ABRecordRef record_cf = NULL;
    
    for (NSUInteger peopleIndex=0; peopleIndex < numberOfRecords; peopleIndex++) {
        record_cf = [self newRandomPersonWithSparseFields:allowSparseFields allowImages:allowImages error:error];  // +1 retain on record_cf
        if(!record_cf){
            CFRelease(peopleMutableArr_cf);
            return NULL;
        }
        
        PLOG_RETAIN("retain count on record_cf from getRandomPersonRecord = %ld",CFGetRetainCount(record_cf))
        
        // Fixing a property?
        if(![property isEqualToString:@""]){
            if(!ABRecordSetValue(record_cf, propertyID, value_cf, &error_cf)) {
                
                if(error != NULL){
                    NSError *addressBookRecordSetValueError = CFBridgingRelease(error_cf);
                    
                    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABRecordSetValue", @""),
                                                      NSUnderlyingErrorKey : addressBookRecordSetValueError};
                    *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookRecordSetValueError userInfo:errorDictionary];
                    ERROR_LOG("%@",*error)
                }
                CFRelease(record_cf);
                CFRelease(peopleMutableArr_cf);
                return NULL;
            }
        }
        
        CFArrayAppendValue (peopleMutableArr_cf, record_cf);
        
        CFRelease(record_cf);
    }
    
    
    PLOG_RETAIN("retain count on record_cf after loop = %ld\n\n\n",CFGetRetainCount(record_cf))

    CFArrayRef peopleArr_cf = CFArrayCreateCopy(kCFAllocatorDefault, peopleMutableArr_cf);
    CFRelease(peopleMutableArr_cf);
    return peopleArr_cf;
}





// Helper for getArrayOfRandomPeopleWithCount:withSeed:
//
// Create a random person record
//
// Caller retains ownership of Core Foundation object, so method is prefixed with "new"
//
+ (ABRecordRef)newRandomPersonWithSparseFields:(BOOL)allowSparseFields
                                   allowImages:(BOOL)allowImages
                                         error:(NSError **)error
{
    CFErrorRef error_cf = NULL;
    
    ABRecordRef record_cf = ABPersonCreate();
    
    CFDataRef profileImageData_cf = NULL;
    CFMutableArrayRef nameArr_cf = NULL;
    CFMutableArrayRef addressArr_cf = NULL;
    CFArrayRef selectionArr_cf = NULL;  // Array that we can populate with various types
    CFDictionaryRef formatOptions_cf = NULL; 
    CFArrayRef dateLabelArr_cf = NULL;  
    CFMutableArrayRef dateArr_cf = NULL;
    CFArrayRef urlLabelArr_cf = NULL; 
    CFArrayRef urlArr_cf = NULL; 
    CFArrayRef relatedNameLabelArr_cf = NULL; 
    CFArrayRef phoneLabelArr_cf = NULL; 
    CFArrayRef phoneArr_cf = NULL; 
    CFArrayRef emailLabelArr_cf = NULL; 
    CFArrayRef emailArr_cf = NULL; 
    CFArrayRef addressKeyArr_cf = NULL; 
    CFArrayRef addressLabelArr_cf = NULL; 
    CFArrayRef instantMessagingKeyArr_cf = NULL;  
    CFArrayRef instantMessagingLabelArr_cf = NULL; 
    CFArrayRef socialProfileKeyArr_cf = NULL; 
    CFArrayRef socialProfileLabelArr_cf = NULL; 
    
    
    
    // In order to handle the many possible cases of errors within this method (notably the
    // calls to recordSetTestValueForRecord) with the required calls to CFRelease if an error is detected,
    // we are going to use a concise approach.   We enclose the entire method contents within a do ... while(1)
    // and use a BOOL errorDetected to note an error (default being an error condition=YES).   If we break without setting
    // errorDetected to NO, then return NULL.
    //
    BOOL errorDetected = YES;  // Error by default.
    
    
    do {
        
        // -------------------------------------------
        // Initialization of some random data
        // -------------------------------------------
        //
        
        
        // Populate arrays of labels
        //
        // Date
        CFTypeRef dateLabels_cf[] =  {CFSTR("anniversary"),CFSTR("other"),CFSTR("Christmas"),CFSTR("Easter"),CFSTR("groundhog")};
        dateLabelArr_cf = CFArrayCreate (kCFAllocatorDefault,dateLabels_cf,ARRAY_LENGTH(dateLabels_cf), &kCFTypeArrayCallBacks);
        
        // URL
        CFTypeRef urlLabels_cf[] =  {CFSTR("home page"),CFSTR("home"),CFSTR("work"),CFSTR("other"),CFSTR("school")};
        urlLabelArr_cf = CFArrayCreate (kCFAllocatorDefault,urlLabels_cf,ARRAY_LENGTH(urlLabels_cf), &kCFTypeArrayCallBacks);
        
        // Related Name
        CFTypeRef relatedNameLabels_cf[] =  {CFSTR("mother"),CFSTR("father"),CFSTR("parent"),CFSTR("brother"),CFSTR("sister")};
        relatedNameLabelArr_cf = CFArrayCreate (kCFAllocatorDefault,relatedNameLabels_cf,ARRAY_LENGTH(relatedNameLabels_cf), &kCFTypeArrayCallBacks);
        
        // Phone Number
        CFTypeRef phoneLabels_cf[] =  {CFSTR("Mobile"),CFSTR("Home"),CFSTR("Work"),CFSTR("School"),CFSTR("home fax")};
        phoneLabelArr_cf = CFArrayCreate (kCFAllocatorDefault,phoneLabels_cf,ARRAY_LENGTH(phoneLabels_cf), &kCFTypeArrayCallBacks);
        
        // Email
        CFTypeRef emailLabels_cf[] =  {CFSTR("home"),CFSTR("work"),CFSTR("other"),CFSTR("School"),CFSTR("church")};
        emailLabelArr_cf = CFArrayCreate (kCFAllocatorDefault,emailLabels_cf,ARRAY_LENGTH(emailLabels_cf), &kCFTypeArrayCallBacks);
        
        // Address
        CFTypeRef addressLabels_cf[] =  {CFSTR("home"),CFSTR("work"),CFSTR("other"),CFSTR("School"),CFSTR("church")};
        addressLabelArr_cf = CFArrayCreate (kCFAllocatorDefault,addressLabels_cf,ARRAY_LENGTH(addressLabels_cf), &kCFTypeArrayCallBacks);
        
        // instantMessaging
        CFTypeRef instantMessagingLabels_cf[] =  {kABPersonInstantMessageServiceYahoo, kABPersonInstantMessageServiceJabber, kABPersonInstantMessageServiceMSN, kABPersonInstantMessageServiceICQ, kABPersonInstantMessageServiceAIM, kABPersonInstantMessageServiceQQ,kABPersonInstantMessageServiceGoogleTalk, kABPersonInstantMessageServiceSkype, kABPersonInstantMessageServiceFacebook,  kABPersonInstantMessageServiceGaduGadu};
        instantMessagingLabelArr_cf = CFArrayCreate (kCFAllocatorDefault,instantMessagingLabels_cf,ARRAY_LENGTH(instantMessagingLabels_cf), &kCFTypeArrayCallBacks);
        
        
        // SocialProfile
        // Note that kABPersonSocialProfileServiceSinaWeibo, while in Apple docs, is invalid
        CFTypeRef socialProfileLabels_cf[] =  {kABPersonSocialProfileServiceTwitter, kABPersonSocialProfileServiceGameCenter, kABPersonSocialProfileServiceFacebook, kABPersonSocialProfileServiceMyspace, kABPersonSocialProfileServiceLinkedIn, kABPersonSocialProfileServiceFlickr};
        socialProfileLabelArr_cf = CFArrayCreate (kCFAllocatorDefault,socialProfileLabels_cf,ARRAY_LENGTH(socialProfileLabels_cf), &kCFTypeArrayCallBacks);
        
        
        
        // Empty dictionary for formatOptions which is currently not implemented in CFStringCreateWithFormatAndArguments
        formatOptions_cf = CFDictionaryCreate (kCFAllocatorDefault,NULL,NULL,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
        
        
        // Populate an array of names.  We'll seed with some base names and then add some numbers as a suffix to expand
        // the array.
        CFTypeRef names_cf[] =  {CFSTR("Adam"),CFSTR("Glenn"),CFSTR("Samantha"), CFSTR("Scott"),CFSTR("Valerie"),CFSTR("Zachary")};
        CFStringRef name_cf;
        nameArr_cf = CFArrayCreateMutable (kCFAllocatorDefault,0,&kCFTypeArrayCallBacks);
        
        for(int i=0; i < 100; i++) {
            CFIndex nameIndex_cf = random() % ARRAY_LENGTH(names_cf);
            
            // Note: See also
            // https://developer.apple.com/library/mac/#documentation/CoreFoundation/Conceptual/CFStrings/Articles/CreatingAndCopying.html
            // for usage of CFStringCreateWithFormatAndArguments
            //
            name_cf = CFStringCreateWithFormat(kCFAllocatorDefault,formatOptions_cf,CFSTR("%@%ld"),names_cf[nameIndex_cf],random() % 1000);
            
            CFArrayAppendValue (nameArr_cf, name_cf);
            
            CFRelease(name_cf);
        }
        
        // Populate an array of addresses
        CFTypeRef addresses_cf[] =  {CFSTR("10 Mockingbird Lane"),CFSTR("5321 Grand Tour Heights"),CFSTR("10A Lovers Lane"), CFSTR("Grand Rock Terrace Apt. 2"),CFSTR("89 Sunset Boulevard"),CFSTR("12 Metro Place Way")};
        CFStringRef address_cf;
        addressArr_cf = CFArrayCreateMutable (kCFAllocatorDefault,0,&kCFTypeArrayCallBacks);
        
        for(int i=0; i < ARRAY_LENGTH(addresses_cf); i++) {
            address_cf = CFStringCreateWithFormat(kCFAllocatorDefault,formatOptions_cf,CFSTR("%@"),addresses_cf[i]);
            
            CFArrayAppendValue (addressArr_cf, address_cf);
            
            CFRelease(address_cf);
        }
        
        
        
        // Populate an array of dates
        // http://developer.apple.com/library/ios/#documentation/CoreFoundation/Reference/CFDateRef/Reference/reference.html
        //
        // An absolute time of 32,000,000 is about 1 year.  Reference is Jan 1 2001 00:00:00 GMT  
        CFDateRef date_cf;
        dateArr_cf = CFArrayCreateMutable (kCFAllocatorDefault,0,&kCFTypeArrayCallBacks);
        
        for(int i=0; i<101; i++){
            
            
            // Note: The following comments were applicable to an app that used this
            //       class and interfaced with a Ruby on Rails site.
            //
            // We need to handle dates carefully.
            //
            // The timestamps pulled from a date set in Address Book are at noon of the selected day,
            // exactly 12 hours more than a similar timestamp that we get from Ruby parsing the same date.
            //
            // We compensate in the Rails site by adding these 12 hours to timestamp for
            // any date originating from Ruby parsing/processing.   The timestamps from this app or the Rails
            // site must match in order for the MD5 hash (used in creating primaryRecordId) to match.
            //
            // For testing purposes then, we need to make sure that any generated dates are for noon - matching
            // dates generated in the Contacts app for Address Book.
            //
            
            //    0 = midnight of 1st day of Reference date = Jan. 1, 2001
            //    86400 = midnight of second day of Reference date.
            //    129,600 = noon of second day of Reference date.
            //
            double generatedTimeFloat = (random() % 640000000) - 320000000;   // Centered around our reference
            
            
            // Convert to integer for processing.  Floats are dangerous to work with for precise results:
            // http://stackoverflow.com/questions/2257209/round-with-floor-problem-in-objective-c/17074309
            //
            NSInteger generatedTime = (NSInteger)generatedTimeFloat;
            
            
            NSInteger noonDate = floor(generatedTime/86400) * 86400 + 43200;

            // NLOG("generatedTime=%d  noonDate=%d",generatedTime,noonDate)

            
            date_cf = CFDateCreate (kCFAllocatorDefault, noonDate);
            
            //NSLog(@"date_cf=%@",date_cf);
            
            CFArrayAppendValue (dateArr_cf, date_cf);
            CFRelease(date_cf);
        }
        
        
        // Populate an array of URLs
        CFTypeRef url_cf[] =  {CFSTR("http://www.cnn.com"),CFSTR("http://www.google.com"),CFSTR("http://msnbc.com"),CFSTR("http://foxnews.com")};
        urlArr_cf = CFArrayCreate (kCFAllocatorDefault,url_cf,ARRAY_LENGTH(url_cf), &kCFTypeArrayCallBacks);
        
        // Populate an array of Phone numbers
        CFTypeRef phone_cf[] =  {CFSTR("1 617 342-2337"),CFSTR("507-2387"),CFSTR("123876712"),CFSTR("552-128-7127")};
        phoneArr_cf = CFArrayCreate (kCFAllocatorDefault,phone_cf,ARRAY_LENGTH(phone_cf), &kCFTypeArrayCallBacks);
        
        // Populate an array of E-mail addresses
        CFTypeRef email_cf[] =  {CFSTR("jsmith@aol.com"),CFSTR("Johnny_Carp@yahoo.com"),CFSTR("billybob@thorton.com"),CFSTR("nevermind@okay.com")};
        emailArr_cf = CFArrayCreate (kCFAllocatorDefault,email_cf,ARRAY_LENGTH(email_cf), &kCFTypeArrayCallBacks);
        
        
        // -------------------------------------------
        // Image Properties
        // -------------------------------------------
        //
        
        // Set a picture 66% of the time
        //
        // Always set a picture if allowSparseFields == NO
        if(allowImages && ( ((random() % 100) < 67) || (allowSparseFields == NO) ) ) {
            
            CGSize imageViewSize = CGSizeMake(100.0, 100.0);
            
            NSString *imageLabel = CFArrayGetValueAtIndex(nameArr_cf, random() % ARRAY_LENGTH(names_cf));
            
            UIImage *profileImage = [self imageFromText:imageLabel withSize:imageViewSize withBorderWidth:10.0 withFontSize:16.0];
            
            
            
            // Note:  Both UIImagePNGRepresentation UIImageJPEGRepresentation seem to cause heap leaks.
            //        Not sure of a good solution.
            // References:
            // http://bit.ly/Ro3oDP
            // http://bit.ly/Ro3oUo
            // http://bit.ly/ZcYFXH
            //
            //NSData *profileImageDataRef = UIImagePNGRepresentation(profileImage);
            NSData *profileImageDataRef = UIImageJPEGRepresentation(profileImage, 1.0); // 1.0 = least compression, best quality
            
            profileImageData_cf = (CFDataRef)CFBridgingRetain(profileImageDataRef);
            
            if(!ABPersonSetImageData(record_cf, profileImageData_cf, &error_cf)){
                if(error != NULL){
                    NSError *addressBookSetImageError = CFBridgingRelease(error_cf);
                    
                    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Can't set image", @""),
                                                      NSUnderlyingErrorKey : addressBookSetImageError};
                    *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookSetImageError userInfo:errorDictionary];
                    ERROR_LOG("%@",*error)
                }
                
                break;
            }
            
        }
        
        
        // For reference
        //    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        //    imageView.frame = CGRectMake(20, 20, imageViewSize.width, imageViewSize.height);
        //    [self addSubview:imageView];
        
        
        // -------------------------------------------
        // Person Type Property
        // -------------------------------------------
        // kABPersonKindProperty of type kABIntegerPropertyType
        //
        // Values are one of:
        // kABPersonKindPerson
        // kABPersonKindOrganization
        
        // Note:  If you set kABPersonKindProperty to kABPersonKindOrganization, you cannot set kABPersonOrganizationProperty
        //        or you will get a memory leak.  Bug filed with Apple.  For test case see:
        //        https://github.com/scottcarter/AddressBookOrganizationBug.git
        //
        //  The problem of course is that you probably only want to set kABPersonOrganizationProperty if it IS
        //  an organization type record.
        //
        //  If we did set the type to kABPersonKindOrganization AND set kABPersonOrganizationProperty (leak)
        //  we see that the organization name is in boldface in the Apple Contacts app.
        //
        
        CFTypeRef personKind_cf[1];  // An array of 1 element to hold kABPersonKindProperty value.
        
        NSUInteger isKindPerson = random() % 2; // 0 or 1
        
        if(isKindPerson){
            personKind_cf[0] = kABPersonKindPerson;
        } else {
            personKind_cf[0] = kABPersonKindOrganization;
        }
        
        selectionArr_cf = CFArrayCreate (kCFAllocatorDefault,personKind_cf,ARRAY_LENGTH(personKind_cf), &kCFTypeArrayCallBacks);
        
        if(![self recordSetTestValueForRecord:record_cf forProperty:@"personKind" withPropertyID:kABPersonKindProperty withSelectionArr:selectionArr_cf error:error]){
            break;
        }
        
        
        
        // -------------------------------------------
        // Personal Information Properties
        // -------------------------------------------
        //
        if(![self recordSetTestValueForRecord:record_cf forProperty:@"firstName" withPropertyID:kABPersonFirstNameProperty withSelectionArr:nameArr_cf error:error]){
            break;
        }
        
        // Populate middle name half the time.
        //
        // Always populate middle name if allowSparseFields == NO
        if( ((random() % 2) == 1)  || (allowSparseFields == NO) ){
            if(![self recordSetTestValueForRecord:record_cf forProperty:@"middleName" withPropertyID:kABPersonMiddleNameProperty withSelectionArr:nameArr_cf error:error]){
                break;
            }
        }
        
        if(![self recordSetTestValueForRecord:record_cf forProperty:@"lastName" withPropertyID:kABPersonLastNameProperty withSelectionArr:nameArr_cf error:error]){
            break;
        }
        if(![self recordSetTestValueForRecord:record_cf forProperty:@"prefix" withPropertyID:kABPersonPrefixProperty withSelectionArr:nameArr_cf error:error]){
            break;
        }
        if(![self recordSetTestValueForRecord:record_cf forProperty:@"suffix" withPropertyID:kABPersonSuffixProperty withSelectionArr:nameArr_cf error:error]){
            break;
        }
        
        
        if( ((random() % 2) == 1) || (allowSparseFields == NO) ){
            if(![self recordSetTestValueForRecord:record_cf forProperty:@"nickname" withPropertyID:kABPersonNicknameProperty withSelectionArr:nameArr_cf error:error]){
                break;
            }
        }
        
        
        if(![self recordSetTestValueForRecord:record_cf forProperty:@"firstNamePhonetic" withPropertyID:kABPersonFirstNamePhoneticProperty withSelectionArr:nameArr_cf error:error]){
            break;
        }
        if(![self recordSetTestValueForRecord:record_cf forProperty:@"lastNamePhonetic" withPropertyID:kABPersonLastNamePhoneticProperty withSelectionArr:nameArr_cf error:error]){
            break;
        }
        if(![self recordSetTestValueForRecord:record_cf forProperty:@"middleNamePhonetic" withPropertyID:kABPersonMiddleNamePhoneticProperty withSelectionArr:nameArr_cf error:error]){
            break;
        }
        
        // Only set the kABPersonOrganizationProperty property for a Person type record.  This seems backwards, but
        // avoids the memory leak mentioned previously above.
        if(isKindPerson){
            if(![self recordSetTestValueForRecord:record_cf forProperty:@"organization" withPropertyID:kABPersonOrganizationProperty withSelectionArr:nameArr_cf error:error]){
                break;
            }
        }
        
        if(![self recordSetTestValueForRecord:record_cf forProperty:@"jobTitle" withPropertyID:kABPersonJobTitleProperty withSelectionArr:nameArr_cf error:error]){
            break;
        }
        if(![self recordSetTestValueForRecord:record_cf forProperty:@"department" withPropertyID:kABPersonDepartmentProperty withSelectionArr:nameArr_cf error:error]){
            break;
        }
        if(![self recordSetTestValueForRecord:record_cf forProperty:@"note" withPropertyID:kABPersonNoteProperty withSelectionArr:nameArr_cf error:error]){
            break;
        }
        
        // Personal dates
        //
        
        // Set the birthday half the time.
        //
        // Always set the birthday if allowSparseFields == NO
        if( ((random() % 2) == 1)  || (allowSparseFields == NO) ) {
            if(![self recordSetTestValueForRecord:record_cf forProperty:@"birthday" withPropertyID:kABPersonBirthdayProperty withSelectionArr:dateArr_cf error:error]){
                break;
            }
        }
        
        
        // Let Address Book record creation set the creation date for us.
        // if(![self recordSetTestValueForRecord:record_cf forProperty:@"creationDate" withPropertyID:kABPersonCreationDateProperty withSelectionArr:dateArr_cf error:error]){
        //    break;
        // }
        
        
        
        // --------------------------------------------
        // Date properties
        // --------------------------------------------
        //
        if(![self recordSetTestMultiValueForRecord:record_cf forProperty:@"date" withPropertyID:kABPersonDateProperty withPropertyType:kABMultiDateTimePropertyType withLabelArr:dateLabelArr_cf withSelectionArr:dateArr_cf error:error]){
            break;
        }
        
        
        // --------------------------------------------
        // URL Properties
        // --------------------------------------------
        //
        if(![self recordSetTestMultiValueForRecord:record_cf forProperty:@"url" withPropertyID:kABPersonURLProperty withPropertyType:kABMultiStringPropertyType withLabelArr:urlLabelArr_cf withSelectionArr:urlArr_cf error:error]){
            break;
        }
 
        
        // --------------------------------------------
        // Related Name Properties
        // --------------------------------------------
        //
        if(![self recordSetTestMultiValueForRecord:record_cf forProperty:@"related" withPropertyID:kABPersonRelatedNamesProperty withPropertyType:kABMultiStringPropertyType withLabelArr:relatedNameLabelArr_cf withSelectionArr:nameArr_cf error:error]){
            break;
        }
        

        
        // --------------------------------------------
        // Phone Number Properties
        // --------------------------------------------
        //
        if(![self recordSetTestMultiValueForRecord:record_cf forProperty:@"phone" withPropertyID:kABPersonPhoneProperty withPropertyType:kABMultiStringPropertyType withLabelArr:phoneLabelArr_cf withSelectionArr:phoneArr_cf error:error]){
            break;
        }
                
        
        // --------------------------------------------
        // Email Properties
        // --------------------------------------------
        //
        if(![self recordSetTestMultiValueForRecord:record_cf forProperty:@"email" withPropertyID:kABPersonEmailProperty withPropertyType:kABMultiStringPropertyType withLabelArr:emailLabelArr_cf withSelectionArr:emailArr_cf error:error]){
            break;
        }
        

        
        // -----------------------------------------------
        // Address Properties
        // -----------------------------------------------
        //
        
        CFTypeRef addressKeys_cf[] =  {kABPersonAddressStreetKey,kABPersonAddressCityKey,kABPersonAddressStateKey,kABPersonAddressZIPKey,kABPersonAddressCountryKey,kABPersonAddressCountryCodeKey};
        addressKeyArr_cf = CFArrayCreate (kCFAllocatorDefault,addressKeys_cf,ARRAY_LENGTH(addressKeys_cf), &kCFTypeArrayCallBacks);
        
        // Populate the address half the time.
        //
        // Always set the address if allowSparseFields == NO
        if( ((random() % 2) == 1) || (allowSparseFields == NO) ){
            if(![self recordSetTestMultiValueDictForRecord:record_cf forProperty:@"address" withPropertyID:kABPersonAddressProperty withLabelArr:addressLabelArr_cf withSelectionArr:addressArr_cf withKeys:addressKeyArr_cf error:error]){
                break;
            }
        }
        
        
        
        // -----------------------------------------------
        // Instant Messaging Properties
        // -----------------------------------------------
        //
        CFTypeRef instantMessagingKeys_cf[] =  {kABPersonInstantMessageUsernameKey,kABPersonInstantMessageServiceKey};
        instantMessagingKeyArr_cf = CFArrayCreate (kCFAllocatorDefault,instantMessagingKeys_cf,ARRAY_LENGTH(instantMessagingKeys_cf), &kCFTypeArrayCallBacks);
        
        
        if(![self recordSetTestMultiValueDictForRecord:record_cf forProperty:@"instantMessaging" withPropertyID:kABPersonInstantMessageProperty withLabelArr:instantMessagingLabelArr_cf withSelectionArr:nameArr_cf withKeys:instantMessagingKeyArr_cf error:error]){
            break;
        }
        
        
        
        
        // -----------------------------------------------
        // Social Profile Properties
        // -----------------------------------------------
        //
        // Note:  When displayed with the Apple Contacts app, it is the Service key that shows up as the label.
        //
        // Note:  For the key kABPersonSocialProfileURLKey we need to have a valid URL value or else memory leaks occur.
        //        In recordSetMultiValueDictionary:forProperty:withPropertyID:withLabelArr:withSelectionArr:withKeys:
        //        we will take the value from withSelectionArr: arg and turn into a URL.
        // 
        CFTypeRef socialProfileKeys_cf[] =  {kABPersonSocialProfileURLKey, kABPersonSocialProfileServiceKey, kABPersonSocialProfileUsernameKey, kABPersonSocialProfileUserIdentifierKey};
        socialProfileKeyArr_cf = CFArrayCreate (kCFAllocatorDefault,socialProfileKeys_cf,ARRAY_LENGTH(socialProfileKeys_cf), &kCFTypeArrayCallBacks);
        
        if(![self recordSetTestMultiValueDictForRecord:record_cf forProperty:@"socialProfile" withPropertyID:kABPersonSocialProfileProperty withLabelArr:socialProfileLabelArr_cf withSelectionArr:nameArr_cf withKeys:socialProfileKeyArr_cf error:error]){
            break;
        }
        
        
        // Success.   
        errorDetected = NO;
        break;
        
        
    } while (1);
    
    
    // Note about CFRelease:
    // By conditionally calling CFRelease such as if(profileImageData_cf), we make sure that profileImageData_cf is not NULL which would
    // cause the call to CFRelease to crash.
    //
    // What this doesn't protect against though is overreleasing.   If we call CFRelease more than once when the retain count was only 1,
    // then we can also crash.
    //
    // For this reason, we do most of the releases here which handles both the success and error cases and ensures we don't overrelease.
    // We act on the value of errorDetected after these releases are done.

    if(profileImageData_cf){
        CFRelease(profileImageData_cf);
    }
    if(nameArr_cf) {
        CFRelease(nameArr_cf);
    }
    if(addressArr_cf) {
        CFRelease(addressArr_cf);
    }
    if(selectionArr_cf){
        CFRelease(selectionArr_cf);
    }
    if(formatOptions_cf){
        CFRelease(formatOptions_cf);
    }
    if(dateLabelArr_cf) {
        CFRelease(dateLabelArr_cf);
    }
    if(dateArr_cf) {
        CFRelease(dateArr_cf);
    }
    if(urlLabelArr_cf){
        CFRelease(urlLabelArr_cf);
    }
    if(urlArr_cf){
        CFRelease(urlArr_cf);
    }
    if(relatedNameLabelArr_cf){
        CFRelease(relatedNameLabelArr_cf);
    }
    if(phoneLabelArr_cf){
        CFRelease(phoneLabelArr_cf);
    }
    if(phoneArr_cf){
        CFRelease(phoneArr_cf);
    }
    if(emailLabelArr_cf){
        CFRelease(emailLabelArr_cf);
    }
    if(emailArr_cf){
        CFRelease(emailArr_cf);
    }
    if(addressKeyArr_cf){
        CFRelease(addressKeyArr_cf);
    }
    if(addressLabelArr_cf){
        CFRelease(addressLabelArr_cf);
    }
    if(instantMessagingKeyArr_cf){
        CFRelease(instantMessagingKeyArr_cf);
    }
    if(instantMessagingLabelArr_cf){
        CFRelease(instantMessagingLabelArr_cf);
    }
    if(socialProfileKeyArr_cf){
        CFRelease(socialProfileKeyArr_cf);
    }
    
    if(socialProfileLabelArr_cf){
        CFRelease(socialProfileLabelArr_cf);
    }

    
    
    if(errorDetected){
        if(record_cf){
            CFRelease(record_cf);
        }
        return NULL;
    }
    else {
        return record_cf;
    }
    
}


// Set a simple value in a record
+ (BOOL)recordSetTestValueForRecord:(ABRecordRef)record_cf
           forProperty:(NSString *)property
          withPropertyID:(ABPropertyID)propertyID
      withSelectionArr:(CFArrayRef)selectionArr_cf
                              error:(NSError **)error
{
    
    CFErrorRef error_cf = NULL;
    
    CFIndex arrCount = CFArrayGetCount(selectionArr_cf);
    
    
    // Choose a random value
    CFIndex randomIndex = random() % arrCount;
    
    
    CFTypeRef value_cf = CFArrayGetValueAtIndex(selectionArr_cf, randomIndex);
    
    
    CFStringRef strValue_cf = NULL;
        
    CFTypeID stringType_cf = CFStringGetTypeID();
    CFTypeID valueType_cf = CFGetTypeID(value_cf);
    
    // Is this a CFString type?  If so, add the propery as suffix
    if(stringType_cf == valueType_cf){

        // Empty dictionary for formatOptions which is currently not implemented in CFStringCreateWithFormatAndArguments
        CFDictionaryRef formatOptions_cf = CFDictionaryCreate (kCFAllocatorDefault,NULL,NULL,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
        
        strValue_cf = CFStringCreateWithFormat(kCFAllocatorDefault,formatOptions_cf,CFSTR("%@_%@"),value_cf,property);
        
        CFRelease(formatOptions_cf);
        
        
        if(!ABRecordSetValue(record_cf, propertyID, strValue_cf, &error_cf)) {
            if(error != NULL){
                NSError *addressBookRecordSetValueError = CFBridgingRelease(error_cf);
                
                NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABRecordSetValue", @""),
                                                  NSUnderlyingErrorKey : addressBookRecordSetValueError};
                *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookRecordSetValueError userInfo:errorDictionary];
                ERROR_LOG("%@",*error)
            }
            CFRelease(strValue_cf);
            return NO;
        }
        
        CFRelease(strValue_cf);
        
    }
    
    else {
        
        if(!ABRecordSetValue(record_cf, propertyID, value_cf, &error_cf)) {
            if(error != NULL){
                NSError *addressBookRecordSetValueError = CFBridgingRelease(error_cf);
                
                NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABRecordSetValue", @""),
                                                  NSUnderlyingErrorKey : addressBookRecordSetValueError};
                *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookRecordSetValueError userInfo:errorDictionary];
                ERROR_LOG("%@",*error)
            }
            return NO;
        }
        
    }
    
    return YES;
}


// Set a multi value in a record for string and datetime property types
+ (BOOL)recordSetTestMultiValueForRecord:(ABRecordRef)record_cf
                forProperty:(NSString *)property
             withPropertyID:(ABPropertyID)propertyID
           withPropertyType:(ABPropertyType)propertyType
               withLabelArr:(CFArrayRef)labelArr_cf
           withSelectionArr:(CFArrayRef)selectionArr_cf
                                   error:(NSError **)error
{
    CFErrorRef error_cf = NULL;
    
    CFIndex labelArrCount = CFArrayGetCount(labelArr_cf);
    CFIndex selectionArrCount = CFArrayGetCount(selectionArr_cf);
    

    ABMutableMultiValueRef multiValue_cf = ABMultiValueCreateMutable(propertyType);

    
    if( (propertyType == kABMultiDateTimePropertyType) || (propertyType == kABMultiStringPropertyType) ) {
        CFStringRef labelBase_cf;
        CFTypeRef value_cf;
        CFDictionaryRef formatOptions_cf = CFDictionaryCreate(kCFAllocatorDefault,NULL,NULL,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
        CFStringRef label_cf;
        
        // Randomize the number of entries
        
        for(int i=0; i < (random() % 5) + 1; i++) {
            
            labelBase_cf = CFArrayGetValueAtIndex(labelArr_cf, random() % labelArrCount);
            value_cf = CFArrayGetValueAtIndex(selectionArr_cf, random() % selectionArrCount);
            
            // Append property to label
            label_cf = CFStringCreateWithFormat(kCFAllocatorDefault,formatOptions_cf,CFSTR("%@_%@"),labelBase_cf,property);
            
            if(!ABMultiValueAddValueAndLabel(multiValue_cf, value_cf, label_cf, NULL)) {
                if(error != NULL){
                    NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABMultiValueAddValueAndLabel", @"")};
                    *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookMultiValueAddValueAndLabelError userInfo:errorDictionary];
                    ERROR_LOG("%@",*error)
                }
                if(label_cf){
                    CFRelease(label_cf);
                }
                if(formatOptions_cf) {
                    CFRelease(formatOptions_cf);
                }
                if(multiValue_cf){
                    CFRelease(multiValue_cf);
                }
                return NO;
            }
            
            CFRelease(label_cf);
        }
        
        if(formatOptions_cf) {
            CFRelease(formatOptions_cf);
        }
    }
        
    else {
        EXCEPTION_LOG("Unsupported property type")
    }
    
    
    
    if(!ABRecordSetValue(record_cf, propertyID, multiValue_cf, &error_cf)) {
        if(error != NULL){
            NSError *addressBookRecordSetValueError = CFBridgingRelease(error_cf);
            
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABRecordSetValue", @""),
                                              NSUnderlyingErrorKey : addressBookRecordSetValueError};
            *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookRecordSetValueError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        if(multiValue_cf){
            CFRelease(multiValue_cf);
        }
        return NO;
    }
    
    
    if(multiValue_cf){
        CFRelease(multiValue_cf);
    }
    
    return YES;
}


// Set a multi value in a record for string and datetime property types
+ (BOOL)recordSetTestMultiValueDictForRecord:(ABRecordRef)record_cf
                forProperty:(NSString *)property
             withPropertyID:(ABPropertyID)propertyID
               withLabelArr:(CFArrayRef)labelArr_cf
           withSelectionArr:(CFArrayRef)selectionArr_cf
                             withKeys:(CFArrayRef)keyArr_cf
                                       error:(NSError **)error
{
    CFErrorRef error_cf = NULL;
    
    CFIndex labelArrCount = CFArrayGetCount(labelArr_cf);
    CFIndex selectionArrCount = CFArrayGetCount(selectionArr_cf);
    CFIndex keyArrCount = CFArrayGetCount(keyArr_cf);
    
    
    ABMutableMultiValueRef multiValue_cf = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    
    
    CFStringRef labelBase_cf;
    CFTypeRef value_cf;
    CFDictionaryRef formatOptions_cf = CFDictionaryCreate(kCFAllocatorDefault,NULL,NULL,0,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
    CFStringRef label_cf;
    
    CFMutableDictionaryRef detailDict_cf;
    
    
    // Randomize the number of entries
    for(int i=0; i < (random() % 5) + 1; i++) {

        labelBase_cf = CFArrayGetValueAtIndex(labelArr_cf, random() % labelArrCount);
        
        detailDict_cf = CFDictionaryCreateMutable(kCFAllocatorDefault,keyArrCount,&kCFTypeDictionaryKeyCallBacks,&kCFTypeDictionaryValueCallBacks);
        
        // Iterate over each key and add values to dictionary
        for (int keyIndex=0; keyIndex < keyArrCount; keyIndex++) {
            value_cf = CFArrayGetValueAtIndex(selectionArr_cf, random() % selectionArrCount);
            
            CFTypeRef key_cf = CFArrayGetValueAtIndex(keyArr_cf,keyIndex);
            
            // Special case where we need to turn our selection value into a URL
            if(key_cf == kABPersonSocialProfileURLKey){
                CFStringRef urlValue_cf = CFStringCreateWithFormat(kCFAllocatorDefault,formatOptions_cf,CFSTR("http://%@.com"),value_cf);
                CFDictionaryAddValue (detailDict_cf, key_cf, urlValue_cf);
                CFRelease(urlValue_cf);
            }
            else {
                CFDictionaryAddValue (detailDict_cf, key_cf, value_cf);
            }
        
        }
    

        // Append property to label
        label_cf = CFStringCreateWithFormat(kCFAllocatorDefault,formatOptions_cf,CFSTR("%@_%@"),labelBase_cf,property);
        
        if(!ABMultiValueAddValueAndLabel(multiValue_cf, detailDict_cf, label_cf, NULL)) {
            if(error != NULL){
                NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABMultiValueAddValueAndLabel", @"")};
                *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookMultiValueAddValueAndLabelError userInfo:errorDictionary];
                ERROR_LOG("%@",*error)
            }
            if(label_cf){
                CFRelease(label_cf);
            }
            if(detailDict_cf){
                CFRelease(detailDict_cf);
            }
            if(formatOptions_cf) {
                CFRelease(formatOptions_cf);
            }
            if(multiValue_cf) {
                CFRelease(multiValue_cf);
            }
            return NO;
        }
    
        if(label_cf){
            CFRelease(label_cf);
        }
        if(detailDict_cf){
            CFRelease(detailDict_cf);
        }
        
    }
    
    if(!ABRecordSetValue(record_cf, propertyID, multiValue_cf, &error_cf)) {
        if(error != NULL){
            NSError *addressBookRecordSetValueError = CFBridgingRelease(error_cf);
            
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Error with ABRecordSetValue", @""),
                                              NSUnderlyingErrorKey : addressBookRecordSetValueError};
            *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookRecordSetValueError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        if(formatOptions_cf) {
            CFRelease(formatOptions_cf);
        }
        if(multiValue_cf) {
            CFRelease(multiValue_cf);
        }
        return NO;
    }
    
    
    if(formatOptions_cf) {
        CFRelease(formatOptions_cf);
    }

    
    // Release objects
    if(multiValue_cf) {
        CFRelease(multiValue_cf);
    }
    
    return YES;
}



// Remove a random entry in Address Book
+ (BOOL)removeRandomRecord:(id)sender
                     error:(NSError **)error
{
    ABAddressBookRef addressBook_cf = ABAddressBookCreateWithOptions(NULL, nil);
    
    CFArrayRef peopleArr_cf = ABAddressBookCopyArrayOfAllPeople(addressBook_cf);
    
    CFIndex peopleArrCount_cf = CFArrayGetCount(peopleArr_cf);
    
    // Get a random index from 0 to peopleArrCount - 1
    CFIndex peopleIndex_cf = random() % peopleArrCount_cf;
    
    
    ABRecordRef record_cf = CFArrayGetValueAtIndex(peopleArr_cf, peopleIndex_cf);
    
    CFErrorRef error_cf = NULL;
    if(!ABAddressBookRemoveRecord (addressBook_cf,record_cf,&error_cf)) {
        if(error != NULL){
            NSError *addressBookRemoveRecordError = CFBridgingRelease(error_cf);
            
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Address Book remove record failed", @""),
                                              NSUnderlyingErrorKey : addressBookRemoveRecordError};
            *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookRemoveRecordError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        if(peopleArr_cf) {
            CFRelease(peopleArr_cf);
        }
        if(addressBook_cf){
            CFRelease(addressBook_cf);
        }
        return NO;
    }
    
    
    if(!ABAddressBookSave(addressBook_cf,&error_cf)) {
        if(error != NULL){
            NSError *addressBookSaveError = CFBridgingRelease(error_cf);
            NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Address Book save failed", @""),
                                              NSUnderlyingErrorKey : addressBookSaveError};
            *error = [[NSError alloc] initWithDomain:AddressBookErrorDomain code:AddressBookSaveError userInfo:errorDictionary];
            ERROR_LOG("%@",*error)
        }
        
        if(peopleArr_cf) {
            CFRelease(peopleArr_cf);
        }
        if(addressBook_cf){
            CFRelease(addressBook_cf);
        }
        return NO;
    }
    

    if(peopleArr_cf) {
        CFRelease(peopleArr_cf);
    }
    
    if(addressBook_cf){
        CFRelease(addressBook_cf);
    }
    
    return YES;
}



// Get an image from text.
// Reference:
// http://stackoverflow.com/questions/2765537/how-do-i-use-the-nsstring-draw-functionality-to-create-a-uiimage-from-text
//
+ (UIImage *)imageFromText:(NSString *)text
                  withSize:(CGSize)contextSize
           withBorderWidth:(CGFloat)borderWidth
              withFontSize:(CGFloat)fontSize
{
    
    UIGraphicsBeginImageContextWithOptions(contextSize,NO,0.0);
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, borderWidth); // line width in points (not pixels)
    
    
    // ============================================
    // Draw our border and background
    // ============================================
    //
    
    // Begin the path
    CGContextBeginPath(context);
    
    // Move around, add lines or arcs to the path
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, contextSize.width, 0);
    CGContextAddLineToPoint(context, contextSize.width, contextSize.height);
    CGContextAddLineToPoint(context, 0, contextSize.height);
    
    
    // Close the path (connects the last point back to the first)
    CGContextClosePath(context);
    
    // Actually the above draws nothing (yet)!
    // You have to set the graphics state and then fill/stroke the above path
    // to see anything.
    
    // Note how the following UIColor object assumes the current context.
    [[UIColor yellowColor] setFill]; // object-oriented convenience method (more in a moment)
    [[UIColor blueColor] setStroke];
    
    // If we intend to use transparency, set this to NO for performance reasons.  Otherwise
    // results are unpredictable.
    // self.opaque = NO;
    
    // Adjust the alpha.
    // self.alpha = 0.1;
    
    CGContextDrawPath(context,kCGPathFillStroke); //kCGPathFillStroke is a constant
    
    
    // ============================================
    // Draw our text
    // ============================================
    //
    
    // set the font type and size
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    //CGSize size  = [text sizeWithFont:font];
    
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
    //
    //    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //    CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
    
    [[UIColor redColor] set];
    
    NSString *textWithLabel = [NSString stringWithFormat:@"Picture: \n%@",text];
    
    // draw in context
    
    // drawAtPoint does not support newline
    //[textWithLabel drawAtPoint:CGPointMake(10.0, 10.0) withFont:font];
    
    CGFloat textOffset = 10.0;
    CGFloat availTextWidth = contextSize.width - (borderWidth * 2) - textOffset;
    CGFloat availTextHeight = contextSize.height - (borderWidth * 2) - textOffset;
    
    
    // Deprecated.
    //[textWithLabel drawInRect:CGRectMake(textOffset, textOffset, availTextWidth, availTextHeight) withFont:font];
    
    [textWithLabel drawInRect:CGRectMake(textOffset, textOffset, availTextWidth, availTextHeight) withAttributes:@{NSFontAttributeName :font}];
    
    // Default font is Helvetica 12-point
    //[textWithLabel drawInRect:CGRectMake(textOffset, textOffset, availTextWidth, availTextHeight) withAttributes:nil];
    
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



// ==========================================================================
// Instance methods
// ==========================================================================
//
#pragma mark -
#pragma mark Instance methods

// None



// ==========================================================================
// C methods
// ==========================================================================
//


#pragma mark -
#pragma mark C methods





@end









