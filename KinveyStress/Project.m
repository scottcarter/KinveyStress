//
//  Project.m
//  KinveyStress
//
//  Created by Scott Carter on 11/28/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

#import "Project.h"


// Define some constants that were declared in Project.h


// ++++++++++++++++++++++++++++++++++
// General project constants
// ++++++++++++++++++++++++++++++++++
//

BOOL const UseEmailVerification = NO;


// Our representation of a null date is created with dateWithTimeIntervalSince1970 (date
// referenced to January 1, 1970  GMT)
//
// We use a null date of 1 sec before midnight on Dec. 31, 1969 = -1
//
NSTimeInterval const NullDateSeconds = -1;



// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Error domains for our custom NSError objects
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//


NSString *const AddressBookErrorDomain = @"scarter.KinveyStress.addressBookErrorDomain";





