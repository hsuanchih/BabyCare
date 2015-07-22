//
//  UIViewController+Containment.h
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/14/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Containment)

- (void) displayViewController:(UIViewController*)viewcontroller inView:(UIView*)view withFrame:(CGRect)frame;
- (void) hideViewController:(UIViewController*)viewcontroller;

@end
