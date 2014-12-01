//
//  Contact.m
//  KinveyStress
//
//  Created by Scott Carter on 11/28/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

#import "Contact.h"

@implementation Contact


- (NSDictionary *)hostToKinveyPropertyMapping
{
    return @{
             @"entityId" : KCSEntityKeyId, //the required _id field
             
             @"address" : @"address",
             @"birthday" : @"birthday",
             @"creationDate" : @"creationDate",
             @"date" : @"date",
             @"department" : @"department",
             @"email" : @"email",
             @"firstName" : @"firstName",
             @"firstNamePhonetic" : @"firstNamePhonetic",
             @"imageThumbnail" : @"imageThumbnail",
             @"instantMessaging" : @"instantMessaging",
             @"jobTitle" : @"jobTitle",
             @"lastName" : @"lastName",
             @"lastNamePhonetic" : @"lastNamePhonetic",
             @"middleName" : @"middleName",
             @"middleNamePhonetic" : @"middleNamePhonetic",
             @"modificationDate" : @"modificationDate",
             @"modifiedPrimaryRecordId" : @"modifiedPrimaryRecordId",
             @"nickname" : @"nickname",
             @"note" : @"note",
             @"organization" : @"organization",
             @"personKind" : @"personKind",
             @"phone" : @"phone",
             @"prefix" : @"prefix",
             @"primaryRecordId" : @"primaryRecordId",
             @"recordState" : @"recordState",
             @"related" : @"related",
             @"socialProfile" : @"socialProfile",
             @"suffix" : @"suffix",
             @"timeoutDate" : @"timeoutDate",
             @"url" : @"url",
             @"userIdentifier" : @"userIdentifier",
             
             @"metadata" : KCSEntityKeyMetadata //optional _metadata field
             };
}

// No mapping required to another collection
//+ (NSDictionary *)kinveyPropertyToCollectionMapping
//{
//    return @{@"<uimage_fieldname>": KCSFileStoreCollectionName};
//}




@end
