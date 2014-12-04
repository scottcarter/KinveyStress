
## About


This project is a start of some stress tests to the Kinvey backend.

It currently makes use of the iPhone Address Book and provides the following functions via buttons:

- Empty Address Book
- Populate Address Book
- Save to Kinvey

By default 500 records (see Settings section below) are populated to the Address Book on a Populate button activation.   All records in the Address Book are uploaded to Kinvey on the Save button activation.   The app currently empties the Address Book automatically before a Populate.

Populated records use pseudo-random data, repeatable between launches of the app.  To view this consistently in the Kinvey web console, you will wish to sort on the primaryRecordId field.


## Restrictions

**This project is only intended for the Xcode simulator** as testing is destructive to the Address Book contents.

KinveyStress does make use of the macro IPHONE_SIMULATOR_DEVELOPMENT (defined in Global.h) to guard against accidental runs on a device.


## Settings

I've borrowed the class AddressBook.m from my Contacts2Web app to provide the set of methods needed to manipulate the Address Book.  

**Number of records**

You can control how many records are populated to your Address Book in the simulator by setting the contant AddressBookNumEntriesToPopulateBeforeSave in AddressBook.m

**Record characteristics**

You can control how records are populated in the method populateAddressBookAction in KStressMainViewController.m. 

There are arguments for:

- allowSparseFields (whether select fields are allowed to be randomly empty)
- allowRandomDuplicates (whether fields can be randomly duplicated)
- allowImages (whether thumbnail images are generated)


Notes:
- Only a few fields respond to the setting for allowSparseFields.  Search for this argument in AddressBook.m.
- If random duplicates are allowed, they are created 5% of the time.  This can be changed in AddressBook.m.  Search for "NSUInteger percentage = 5"
- Thumbnails are created as text inside a JPEG image.


## Results

It is not the intention of this project to report here on any particular metrics.

Some items I will be looking at include:

- Memory utilization of the Kinvey SDK.
- Bandwidth - how long it takes to upload a certain amount of data.



## Installation

### Pods

Navigate to the folder where you downloaded the project (Ex: KinveyStress-master) and execute

**pod install**

Assumes that CocoaPods is installed on your system.


### Workspace based

When opening the project, be sure to select **KinveyStress.xcworkspace**.


### Kinvey setup

Create a new Kinvey App to accompany this project.  Within the app, navigate to the Dashboard and note the App ID and App Secret. 

Edit AppDelegate.m.  Within application:didFinishLaunchingWithOptions: look for initializeKinveyServiceForAppKey:withAppSecret:usingOptions: and insert your own App Key (App ID) and App Secret.



