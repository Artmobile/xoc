//
//  xocAppDelegate.h
//  xoc
//
//  Created by Ilya Alberton on 3/13/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class xocViewController;

@interface xocAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet xocViewController *viewController;

@end
