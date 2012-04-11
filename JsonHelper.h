//
//  JsonHelper.h
//  xoc
//
//  Created by Ilya Alberton on 4/11/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonHelper : NSObject

+ (NSDictionary*)       get: (NSString*) url timeoutInterval:(NSTimeInterval) timeoutInterval;

@end
