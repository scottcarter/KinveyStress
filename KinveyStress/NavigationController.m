//
//  NavigationController.m
//  KinveyStress
//
//  Created by Scott Carter on 11/26/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

#import "NavigationController.h"

#import "Project.h"

#import "KStressSignInViewController.h"
#import "KStressMainViewController.h"

@interface NavigationController ()

@end

@implementation NavigationController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    [KCSPing pingKinveyWithBlock:^(KCSPingResult *result) {
        if (result.pingWasSuccessful == YES){
            NSLog(@"Kinvey Ping Success with result %@",result);
        } else {
            NSLog(@"Kinvey Ping Failed with result %@",result);
        }
    }];
    
    
    // Determine whether to start with KStressSignInViewController or KStressMainViewController
    
    
    UIStoryboard *storyboard = self.storyboard;
    
    KStressSignInViewController *signInViewController = (KStressSignInViewController *)[storyboard instantiateViewControllerWithIdentifier:@"KStressSignInViewControllerId"];
    
    
    
    KCSUser *user = [KCSUser activeUser];
    
    // User active?
    if(user){
        
        // If we are not using email verification, we can immediately segue
        if(!UseEmailVerification){
            
#if IPHONE_SIMULATOR_DEVELOPMENT
            KStressMainViewController *mainViewController = (KStressMainViewController *)[storyboard instantiateViewControllerWithIdentifier:@"KStressMainViewControllerSimulatorId"];
#else
            KStressMainViewController *mainViewController = (KStressMainViewController *)[storyboard instantiateViewControllerWithIdentifier:@"KStressMainViewControllerDeviceId"];
#endif
            
            [self setViewControllers:@[signInViewController, mainViewController] animated:YES];
            return;
        }
        
        
        // If we are using email verification, see if we have been verified.
        //
        // First we need to get updated information from Kinvey.
        //
        [user refreshFromServer:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            
            KCSUser *user = [KCSUser activeUser];  // Or [objectsOrNil firstObject]
            
            if(!user.emailVerified){
                [self setViewControllers:@[signInViewController] animated:YES];
            }
            else {
                
#if IPHONE_SIMULATOR_DEVELOPMENT
                KStressMainViewController *mainViewController = (KStressMainViewController *)[storyboard instantiateViewControllerWithIdentifier:@"KStressMainViewControllerSimulatorId"];
#else
                KStressMainViewController *mainViewController = (KStressMainViewController *)[storyboard instantiateViewControllerWithIdentifier:@"KStressMainViewControllerDeviceId"];
#endif
                
                [self setViewControllers:@[signInViewController, mainViewController] animated:YES];
            }
           
        }];
        
        
    }
    
    // User not active.
    else {
        [self setViewControllers:@[signInViewController] animated:YES];
    }

    
    
}


@end
