//
//  PlistHandler.h
//  xoc
//
//  Created by Ilya Alberton on 3/13/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistHandler : NSObject
- inject:(NSString*)fileLocation;
- (void) readDatabase;
@end
