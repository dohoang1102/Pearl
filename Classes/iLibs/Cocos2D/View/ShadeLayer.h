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
//  ShadeLayer.h
//  iLibs
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "FancyLayer.h"


@interface ShadeLayer : FancyLayer {

    BOOL                                                     _pushed;
    BOOL                                                     _fadeNextEntry;
    MenuItem                                                 *_backButton, *_nextButton;
    Menu                                                     *_backMenu, *_nextMenu;
    NSInvocation                                             *_backInvocation, *_nextInvocation;

    CocosNode                                                *_background;
    CGPoint                                                  _backgroundOffset;
}

@property (readwrite, retain) MenuItem                              *backButton;
@property (readwrite, retain) MenuItem                              *nextButton;
@property (readwrite) BOOL                                          fadeNextEntry;
@property (readwrite, retain) CocosNode                             *background;
@property (readwrite, assign) CGPoint                               backgroundOffset;

- (void)setBackButtonTarget:(id)target selector:(SEL)selector;
- (void)setNextButtonTarget:(id)target selector:(SEL)selector;
- (void)dismissAsPush:(BOOL)isPushed;
- (void)back;

- (void)ready;
- (void)gone;

@end