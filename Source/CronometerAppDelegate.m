//
//  CronometerAppDelegate.m
//  Cronometer
//
//  Created by Boris Esanu on 08/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "CronometerAppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "UIApplication+NetworkActivity.h"
#import "LoginViewController.h"
#import "WebQuery.h"
#import "HealthKitService.h"

@import HealthKit;

@interface CronometerAppDelegate()

@property (nonatomic) HKHealthStore *healthStore;
		
@end

@implementation CronometerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"didFinishLaunchingWithOptions");
    [Fabric with:@[ CrashlyticsKit]];
    [Crashlytics startWithAPIKey:@"eb259472f985679d5a6a8376d17b49c1ea17ff8f"];
    
    UIColor * greenColor = [UIColor colorWithRed:40/255.0f
                                           green:176/255.0f
                                            blue:102/255.0f
                                           alpha:1];
    
    [[UISegmentedControl appearance] setTintColor:greenColor];
    
    [[UISlider appearance] setTintColor:greenColor];
    /*
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
   [[UIApplication sharedApplication] resetNetworkActivityIndicator];    

   SplashViewController *aViewController = [[SplashViewController alloc] initWithNibName:@"SplashViewController" bundle:[NSBundle mainBundle]];
   [self setSplashView:aViewController];
   
   UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: aViewController];
   navController.delegate = self;    
   [navController setToolbarHidden: YES];
   [navController setNavigationBarHidden: YES];

    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:248/255.0f
                                                                  green:81/255.0f
                                                                   blue:30/255.0f
                                                                  alpha:1]];
    if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    }
    UIColor * greenColor = [UIColor colorWithRed:40/255.0f
                                           green:176/255.0f
                                            blue:102/255.0f
                                           alpha:1];
		
    [[UISegmentedControl appearance] setTintColor:greenColor];
    
    [[UISlider appearance] setTintColor:greenColor];
    
   self.window.rootViewController = navController;*/
    
   //[self.window makeKeyAndVisible];
    
    
//    [HealthKitService sharedInstance];
   
   return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
   /*
    Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    */
   NSLog(@"GOT HERE applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
   /*
    Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    */
   NSLog(@"GOT HERE applicationWillEnterForeground");
    
    if ([[HealthKitService sharedInstance] isServiceAccessible]){
        [[HealthKitService sharedInstance] refreshData];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   /*
    Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    */
   
   NSLog(@"GOT HERE applicationDidBecomeActive");
   
   // We need to properly handle activation of the application with regards to Facebook Login
   // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
   [FBSession.activeSession handleDidBecomeActive];
   
   
   // Set to TODAY if it's been a while
   DiaryViewController *diary = [DiaryViewController singleton];
   if (diary != nil && [[WebQuery singleton] isLoggedIn]) {      
      if ([diary isKindOfClass:[DiaryViewController class]]) {             
         NSLog(@"Refreshing Diary Data");
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[WebQuery singleton] relogin];
            dispatch_async(dispatch_get_main_queue(), ^{
               [diary refreshData];
            });
         });
      }
   }
   
}

- (void)applicationWillTerminate:(UIApplication *)application {   
   NSLog(@"GOT HERE applicationWillTerminate");
   /*
    Called when the application is about to terminate.
    Save data if appropriate.
    See also applicationDidEnterBackground:.
    */
   [FBSession.activeSession close];
}


/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error {
   
   NSLog(@"GOT HERE FB sessionStateChanged");
   
   switch (state) {
      case FBSessionStateOpen:
         if (!error) {
            // We have a valid session
            NSLog(@"User session found");
            [[LoginViewController singleton] doFacebookLogin: self];
         }
         break;
      case FBSessionStateClosed:
      case FBSessionStateClosedLoginFailed:
         [FBSession.activeSession closeAndClearTokenInformation];
         break;
      default:
         break;
   }
      
   if (error) {
      UIAlertView *alertView = [[UIAlertView alloc]
                                initWithTitle:@"Error"
                                message:error.localizedDescription
                                delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
      [alertView show];
   }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
   return [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"email"]
                                             allowLoginUI:allowLoginUI
                                        completionHandler:^(FBSession *session,
                                                            FBSessionState state,
                                                            NSError *error) {
                                           [self sessionStateChanged:session
                                                               state:state
                                                               error:error];
                                        }];
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
   // attempt to extract a token from the url
   return [FBSession.activeSession handleOpenURL:url];
}

# pragma mark - HealthKit

- (void)setupHealthStoreIfPossible
{
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        self.healthStore = [[HKHealthStore alloc] init];
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                
                return;
            }
            
            NSLog(@"Success got HealthKit permissions!");
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the user interface based on the current user's health information.
//                [self updateUsersAgeLabel];
//                [self updateUsersHeightLabel];
//                [self updateUsersWeightLabel];
            });
        }];
    }
}

#pragma mark - HealthKit Permissions

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, birthdayType, biologicalSexType, nil];
}



@end
