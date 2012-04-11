//
//  PlistHandler.h
//  xoc
//
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistHandler : NSObject
- inject:(NSString*)fileLocation;
- (void) readDatabase;
@end
