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
// Note that their is a difference of 978,307,200 seconds between the Epoch and Jan 1, 2001 (the other possible
// iOS reference date which we don't currently use).
//
// Why -1?
//
// It is a decent starting date for picking a birthday with the ROR date picker that we use.
//
// It is easy to spot when browsing the db.
//
// It is not midnight, which is important to be able to allow us to distinguish it from dates
// returned by date picker.   It is not noon, which allows us to distinguish it from dates
// returned from the Address Book.
//
// We also want to avoid picking a date that is too old, since with the wrong version
// of Ruby we run into a date parsing bug.  See:
// https://bugs.ruby-lang.org/issues/8580
//
//
NSTimeInterval const NullDateSeconds = -1;



// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Error domains for our custom NSError objects
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//


NSString *const AddressBookErrorDomain = @"scarter.Contacts2Web.addressBookErrorDomain";





