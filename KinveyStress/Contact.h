//
//  Contact.h
//  KinveyStress
//
//  Created by Scott Carter on 11/28/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>

@interface Contact : NSObject <KCSPersistable>

@property (nonatomic, copy) NSString* entityId; //Kinvey entity _id

@property (nonatomic, copy) NSArray *address;
@property (nonatomic, copy) NSNumber *birthday;
@property (nonatomic, copy) NSNumber *creationDate;
@property (nonatomic, copy) NSArray *date;
@property (nonatomic, copy) NSString *department;
@property (nonatomic, copy) NSArray *email;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *firstNamePhonetic;
@property (nonatomic, copy) NSString *imageThumbnail; // Base 64 encoded
@property (nonatomic, copy) NSArray *instantMessaging;
@property (nonatomic, copy) NSString *jobTitle;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *lastNamePhonetic;
@property (nonatomic, copy) NSString *middleName;
@property (nonatomic, copy) NSString *middleNamePhonetic;
@property (nonatomic, copy) NSNumber *modificationDate;
@property (nonatomic, copy) NSString *modifiedPrimaryRecordId;
@property (nonatomic, copy) NSString *nickname; 
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *organization;
@property (nonatomic, copy) NSNumber *personKind;
@property (nonatomic, copy) NSArray *phone;
@property (nonatomic, copy) NSString *prefix;
@property (nonatomic, copy) NSString *primaryRecordId;
@property (nonatomic, copy) NSNumber *recordState;
@property (nonatomic, copy) NSArray *related;
@property (nonatomic, copy) NSArray *socialProfile;
@property (nonatomic, copy) NSString *suffix;
@property (nonatomic, copy) NSNumber *timeoutDate;
@property (nonatomic, copy) NSArray *url;
@property (nonatomic, copy) NSString *userIdentifier;

@property (nonatomic, retain) KCSMetadata* metadata; //Kinvey metadata, optional

@end





