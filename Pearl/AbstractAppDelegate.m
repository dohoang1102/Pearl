/*
 *   Copyright 2009, Maarten Billemont
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

//
//  AbstractAppDelegate.m
//  Pearl
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import "AbstractAppDelegate.h"
#import "Logger.h"
#import "Config.h"
#ifdef PEARL_MEDIA
#import "AudioController.h"
#endif
#import "Resettable.h"
#ifdef PEARL_UIKIT
#import "AlertViewController.h"
#import "RootViewController.h"
#endif
#import "CodeUtils.h"


@implementation AbstractAppDelegate
@synthesize window = _window, navigationController = _navigationController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Log application details.
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [info objectForKey:@"CFBundleName"];
    NSString *displayName = [info objectForKey:@"CFBundleDisplayName"];
    NSString *build = [Config get].build;
    NSString *version = [Config get].version;
    NSString *copyright = [Config get].copyright;
    
    if (!name)
        name = displayName;
    if (displayName && ![displayName isEqualToString:name])
        name = [NSString stringWithFormat:@"%@ (%@)", displayName, name];
    if (!version)
        version = build;
    if (build && ![build isEqualToString:version])
        version = [NSString stringWithFormat:@"%@ (%@)", version, build];
    
    inf(@"%@ v%@", name, version);
    if (copyright)
        inf(@"%@", copyright);
    inf(@"===================================");
    
#ifdef PEARL_WITH_APNS
    if ([[Config get].supportedNotifications unsignedIntegerValue])
        [application registerForRemoteNotificationTypes:[[Config get].supportedNotifications unsignedIntegerValue]];
#endif
    
    // Start the background music.
    [self preSetup];
    
    return NO;
}


- (void)preSetup {
    
#ifdef PEARL_MEDIA
    if ([[Config get].currentTrack isEqualToString:@"sequential"]) {
        // Restart sequentially from the start.
        [Config get].playingTrack = nil;
        [[AudioController get] playTrack:@"sequential"];
    } else
        [[AudioController get] playTrack:[Config get].currentTrack];
#endif
    
    if (!self.window) {
        self.window = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
#ifdef PEARL_UIKIT
        self.window.rootViewController = [[RootViewController new] autorelease];
#endif
    }
    if (!self.navigationController && [self.window.rootViewController isKindOfClass:[UINavigationController class]])
        self.navigationController = (UINavigationController *) self.window.rootViewController;
}

- (void)didUpdateConfigForKey:(SEL)configKey fromValue:(id)value {
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
}

- (void)restart {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
#ifdef PEARL_UIKIT
    [[AlertViewController activeAlerts] makeObjectsPerformSelector:@selector(dismissAlert)];
#endif
}

- (void)shutdown:(id)caller {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Will be deprecated at some point, please replace with application:openURL:sourceApplication:annotation:" userInfo:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
#ifdef PEARL_MEDIA
    [[AudioController get] playTrack:nil];
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [Config get].firstRun = [NSNumber numberWithBool:NO];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
    
}

- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration {
    
}

- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
    
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
    
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame {
    
}

#ifdef PEARL_WITH_APNS
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [Config get].deviceToken = deviceToken;
    [Config get].notificationsSupported = YES;
    [Config get].notificationsChecked = YES;
    
    dbg(@"APN Device Token Hex: %@", [deviceToken encodeHex]);
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [Config get].notificationsSupported = NO;
    [Config get].notificationsChecked = YES;
    
    wrn(@"Couldn't register with the APNs: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}
#endif

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0) {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0) {
    
}

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
    
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application {
    
}

- (void)dealloc {
    
    self.window = nil;
    
    [super dealloc];
}

+(AbstractAppDelegate *) get {
    
    id delegate = [UIApplication sharedApplication].delegate;
    if ([delegate isKindOfClass:[AbstractAppDelegate class]])
        return (AbstractAppDelegate *) delegate;
    
    return nil;
}


@end
