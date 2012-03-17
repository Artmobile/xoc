//
//  SqliteConnector.h
//  xoc
//
//  Created by Ilya Alberton on 3/16/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqliteConnector : NSObject
- (void) insertBookmark: (NSString*) title url:(NSString*) url;
- (NSMutableArray*) getBookmarkAddress: (NSString*) title;
@end
