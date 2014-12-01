//
//  Types.h
//  KinveyStress
//
//  Created by Scott Carter on 11/28/14.
//  Copyright (c) 2013 Scott Carter. All rights reserved.
//

#ifndef KinveyStress_Types_h
#define KinveyStress_Types_h


// +++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Error codes for our custom NSError objects
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
// Error domains in Project.h


// AddressBookErrorDomain
//
enum {
    AddressBookSaveError,
    AddressBookRemoveRecordError,
    AddressBookAddRecordError,
    AddressBookSetImageError,
    AddressBookRecordSetValueError,
    AddressBookMultiValueAddValueAndLabelError,
};
typedef NSInteger AddressBookError;





#endif
