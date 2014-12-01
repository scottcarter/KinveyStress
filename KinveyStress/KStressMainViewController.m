//
//  KStressMainViewController.m
//  KinveyStress
//
//  Created by Scott Carter on 11/25/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

#import "KStressMainViewController.h"

#import "Project.h"

#import "AddressBook.h"
#import "Contact.h"

#import "SVProgressHUD.h"

#import "NSDictionary+MD5.h"
#import "NSData+Base64.h"


#pragma mark -


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Private Interface
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
@interface KStressMainViewController ()

// ==========================================================================
// Properties
// ==========================================================================
//
#pragma mark -
#pragma mark Properties

@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;


@property (weak, nonatomic) IBOutlet UIButton *saveToKinveyButton;
@property (weak, nonatomic) IBOutlet UIButton *emptyAddressBookButton;
@property (weak, nonatomic) IBOutlet UIButton *populateAddressBookButton;

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) KCSLinkedAppdataStore* updateStore;  // Objects at Kinvey

@end



// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                    Implementation
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
#pragma mark -
@implementation KStressMainViewController

// ==========================================================================
// Constants and Defines
// ==========================================================================
//
#pragma mark -
#pragma mark Constants and Defines

// None


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


- (IBAction)logoutAction:(UIButton *)sender {
   
    
    [[KCSUser activeUser] logout];
    [self.navigationController popViewControllerAnimated:YES];
}


// Remove all Address Book records
- (IBAction)emptyAddressBookAction {
    
    [self disableControls];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Not handling errors (other than the logging that happens) if called from debug button
        NSError *error;
        [AddressBook emptyAddressBook:self error:&error];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self enableControls];
        });
    });
    
    
}


// Populate Address Book with random data
- (IBAction)populateAddressBookAction {
    
    [self disableControls];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Not handling errors (other than the logging that happens) if called from debug button
        NSError *error;
        [AddressBook emptyAddressBook:self error:&error];
        
        
        BOOL result = [AddressBook populateAddressBookWithSeed:AddressBookRandomSeedForPopulate allowSparseFields:YES allowRandomDuplicates:NO allowImages:YES numLoopsForPopulate:AddressBookNumLoopsForPopulate numEntriesToPopulateBeforeSave:AddressBookNumEntriesToPopulateBeforeSave fixingProperty:@"" withPropertyID:0 withValue:NULL error:&error];
        if(!result){
            NSLog(@"populateAddressBook failed with error = %@",error);
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self enableControls];
        });
        
    });
    
    
    
}


// Save Address Book records to Kinvey
- (IBAction)saveToKinveyAction {
    
    [self saveToKinvey];
}



// ==========================================================================
// Initializations
// ==========================================================================
//
#pragma mark -
#pragma mark Initializations

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // We need to determine if we have Address Book access before showing
    // one of the following views.
    self.buttonContainerView.hidden = YES;
    self.alertView.hidden = YES;
    
    
    [self.progressView setProgress:0.0];
    
    [self enableControls];
    
    
    // Clear out the cache on launch.
    [KCSFileStore clearCachedFiles];
    
    KCSCollection* collection = [KCSCollection collectionFromString:@"Contact" ofClass:[Contact class]];
    
    [KCSCachedStore setDefaultCachePolicy:KCSCachePolicyNone];
    
    self.updateStore = [KCSLinkedAppdataStore storeWithCollection:collection options:nil];
    

    
    
    // Start out by checking if we have access to the Address Book
    [self checkAddressBookAccessGranted];
    
    
}



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

// None


// ==========================================================================
// Instance methods
// ==========================================================================
//
#pragma mark -
#pragma mark Instance methods

// Are we granted access to user's Address Book?
//
- (void)checkAddressBookAccessGranted
{
    
    // What is the authorization status?
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    
    NSString *alertText = @"You must grant access to your\nAddress Book for this app to function.\n\nPlease update your preferences in:\nSettings->Privacy->Contacts";
    
    if(authStatus == kABAuthorizationStatusAuthorized){
        self.buttonContainerView.hidden = NO;
        return;
    }
    
    else if(authStatus == kABAuthorizationStatusRestricted){
        self.mainLabel.text = alertText;
        self.alertView.hidden = NO;
        return;
    }
    else if(authStatus == kABAuthorizationStatusDenied){
        self.mainLabel.text = alertText;
        self.alertView.hidden = NO;
        return;
    }
    
    
    if(authStatus != kABAuthorizationStatusNotDetermined){
        EXCEPTION_LOG("Illegal authStatus = %ld",authStatus)
        return;
    }
    
    
    
    // User has not been prompted for permission
    // authStatus = kABAuthorizationStatusNotDetermined
    
    ABAddressBookRef addressBook_cf = ABAddressBookCreateWithOptions(NULL, nil);
    
    
    // Puts up a modal dialog
    // Per the docs:
    // "The completion handler is called on an arbitrary queue."
    // So we can't update the UI directly from the completion block.
    //
    ABAddressBookRequestAccessWithCompletion(addressBook_cf, ^(bool granted, CFErrorRef error) {
        
        // Make sure we execute our code on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            if(addressBook_cf){
                CFRelease(addressBook_cf);
            }
            
            if(granted){
                self.buttonContainerView.hidden = NO;
            }
            else {
                self.mainLabel.text = alertText;
                self.alertView.hidden = NO;
            }
            
        });
        
    });
    
    
    
}


- (void)disableControls
{
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    
    self.saveToKinveyButton.enabled = NO;
    self.emptyAddressBookButton.enabled = NO;
    self.populateAddressBookButton.enabled = NO;
    self.logoutButton.enabled = NO;
}


- (void)enableControls
{
    [self.spinner stopAnimating];
    
    self.saveToKinveyButton.enabled = YES;
    self.emptyAddressBookButton.enabled = YES;
    self.populateAddressBookButton.enabled = YES;
    self.logoutButton.enabled = YES;
}


// Save Address Book records to Kinvey
- (void)saveToKinvey
{
    
    // Reset our progress indicator
    [self.progressView setProgress:0.0];
    
    // Disable controls
    [self disableControls];
    
    // Dispatch to global queue to allow our UI to update
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *contactRecordsArr = [self contactRecords];
        
        NSUInteger count = [contactRecordsArr count];
        
        // Execute Kinvey save on main thread.
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            KCSMetadata* metadata = [[KCSMetadata alloc] init]; // By default only user has access
            [metadata setGloballyReadable:YES];
            
            
            
            
            [self.updateStore saveObject:contactRecordsArr withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                
                // Completion block is called on main thread.
                
                
                // Enable controls
                [self enableControls];
                
                if (errorOrNil != nil) {
                    
                    //save failed, show an error alert
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Save failed", @"Save Failed")
                                                                        message:[errorOrNil localizedFailureReason] //not actually localized
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                              otherButtonTitles:nil];
                    [alertView show];
                    
                } else {
                    //save was successful
                    NSLog(@"Successfully saved %lu records to Kinvey!", (unsigned long)count);
                    
                    // https://github.com/TransitApp/SVProgressHUD
                    [SVProgressHUD showSuccessWithStatus:@"Saved to Kinvey!"];
                    
                }
            } withProgressBlock:^(NSArray *objects, double percentComplete) {
                
                [self.progressView setProgress:percentComplete];
            }];
            
        });
        
    });
    
}


// Fetch records from Address Book and convert to an array of Contact objects.
- (NSArray *)contactRecords
{
    // Get the array of Person records from Address Book, including all fields.
    ABAddressBookRef addressBook_cf = ABAddressBookCreateWithOptions(NULL, nil);

    NSArray *addressBookPersonRecordArr = [AddressBook getPersonRecordArrayWithFields:RecordFieldsAll withAddressBook:addressBook_cf];
    PLOG_TOP("Done with [AddressBook getPersonRecordArray] got %lu records",(unsigned long)[addressBookPersonRecordArr count])
    
    CFRelease(addressBook_cf);
    
    NSMutableArray *contactMutableArr = [[NSMutableArray alloc] init];
    
    for(NSDictionary *addressBookPersonRecordDict in addressBookPersonRecordArr) {
        Contact* contact = [[Contact alloc] init];
        
        contact.address = addressBookPersonRecordDict[@"address"];
        contact.birthday = addressBookPersonRecordDict[@"birthday"];
        contact.creationDate = addressBookPersonRecordDict[@"creationDate"];
        contact.date = addressBookPersonRecordDict[@"date"];
        contact.department = addressBookPersonRecordDict[@"department"];
        contact.email = addressBookPersonRecordDict[@"email"];
        contact.firstName = addressBookPersonRecordDict[@"firstName"];
        contact.firstNamePhonetic = addressBookPersonRecordDict[@"firstNamePhonetic"];
        
        // We encode our image as base64.  Alternatively we could have converted NSData to UIImage and mapped
        // to File collection with kinveyPropertyToCollectionMapping in Contact.m
        contact.imageThumbnail = [(NSData *)addressBookPersonRecordDict[@"imageThumbnail"] base64EncodedString];
        
        contact.instantMessaging = addressBookPersonRecordDict[@"instantMessaging"];
        contact.jobTitle = addressBookPersonRecordDict[@"jobTitle"];
        contact.lastName = addressBookPersonRecordDict[@"lastName"];
        contact.lastNamePhonetic = addressBookPersonRecordDict[@"lastNamePhonetic"];
        contact.middleName = addressBookPersonRecordDict[@"middleName"];
        contact.middleNamePhonetic= addressBookPersonRecordDict[@"middleNamePhonetic"];
        contact.modificationDate = addressBookPersonRecordDict[@"modificationDate"];
        
        contact.modifiedPrimaryRecordId = @"";
        
        contact.nickname = addressBookPersonRecordDict[@"nickname"];
        contact.note = addressBookPersonRecordDict[@"note"];
        contact.organization = addressBookPersonRecordDict[@"organization"];
        contact.personKind = addressBookPersonRecordDict[@"personKind"];
        contact.phone = addressBookPersonRecordDict[@"phone"];
        contact.prefix = addressBookPersonRecordDict[@"prefix"];
        
        
        // Calculate primaryRecordId as hash on our records, excluding some fields.
        // Fields to exclude from our hash.
        //
        // I exclude imageOriginal since this field is not sent to Kinvey.  imageThumbnail is included though.
        NSSet *exclusionSet = [NSSet setWithObjects:@"addressBookRecordId",@"creationDate",@"modificationDate", @"imageOriginal", nil];
        
        NSString *primaryRecordId = [addressBookPersonRecordDict MD5ExcludingKeysFromSet:exclusionSet];
        
        contact.primaryRecordId = primaryRecordId;
        
        
        contact.recordState = @0;
        
        contact.related = addressBookPersonRecordDict[@"related"];
        contact.socialProfile = addressBookPersonRecordDict[@"socialProfile"];
        contact.suffix = addressBookPersonRecordDict[@"suffix"];
        
        NSUInteger timeSince1970 = (NSUInteger)[[NSDate date] timeIntervalSince1970];
        contact.timeoutDate = [NSNumber numberWithUnsignedInteger:timeSince1970]; // Today's date
        
        contact.url = addressBookPersonRecordDict[@"url"];
        
        contact.userIdentifier = [KCSUser activeUser].username;
        
        
        // Add contact to array
        [contactMutableArr addObject:contact];
        
    }
    
    
    NSArray *contactArr = [NSArray arrayWithArray:contactMutableArr];
    
    return contactArr;

}



// ==========================================================================
// C methods
// ==========================================================================
//


#pragma mark -
#pragma mark C methods





@end









