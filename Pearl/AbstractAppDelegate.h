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
//  AbstractAppDelegate.h
//  Pearl
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AbstractAppDelegate : UIResponder <UIApplicationDelegate> {

    UIWindow                                                                *_window;
    UINavigationController                                                  *_navigationController;
}

@property (nonatomic, readwrite, retain) IBOutlet UIWindow                  *window;
@property (nonatomic, readwrite, retain) IBOutlet UINavigationController    *navigationController;

- (void)preSetup;

- (void)didUpdateConfigForKey:(SEL)configKey fromValue:(id)value;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
- (IBAction)restart;
- (void)shutdown:(id)caller;

+ (AbstractAppDelegate *)get;


@end

