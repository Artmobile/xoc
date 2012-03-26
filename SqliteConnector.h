//
//  SqliteConnector.h
//  xoc
//
//  Created by Ilya Alberton on 3/16/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h> // Import the sqlite3 database framework
#import "SqliteHelper.h"

#import "Bookmark.h"

@interface SqliteConnector : NSObject{

    NSString* _databasePath;
    sqlite3* _database;
}

- (id)init;
- (id)initWithFilename:                 (NSString*) fileName;

- (int) getBookmarksBarChildren;
- (int) getBookmarksBarId;
- (void) insertBookmark:                (Bookmark*) bookmark;
- (NSMutableArray*) getBookmarkAddress: (NSString*) title;
@end
