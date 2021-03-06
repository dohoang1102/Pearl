//
//  BoxView.h
//  Pearl
//
//  Created by Maarten Billemont on 04/10/10.
//  Copyright 2010 lhunath (Maarten Billemont). All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * A box layer is a plain layer that renders a bounding box.
 */
@interface BoxLayer : CCNode {

    ccColor4B                           _color;
}

@property (nonatomic, assign) ccColor4B color;

+ (id)boxed:(CCNode *)node;
+ (id)boxed:(CCNode *)node color:(ccColor4B)color;
+ (BoxLayer *)boxWithSize:(CGSize)aFrame color:(ccColor4B)aColor;

- (id)initWithSize:(CGSize)aFrame color:(ccColor4B)aColor;

@end
