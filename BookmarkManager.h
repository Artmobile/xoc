//
//  SqliteConnector.h
//  xoc
//
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h> // Import the sqlite3 database framework
#import "SqliteHelper.h"

#import "Bookmark.h"

@interface BookmarkManager : NSObject{

    NSString* _databasePath;
    sqlite3* _database;
}

- (id)init;
- (id)initWithResult: (SQLITE_API int*) result;
- (id)initWithFilename:                 (NSString*) fileName result: (SQLITE_API int*) result;

- (int) getBookmarksBarChildren: (SQLITE_API int*) result;
- (int) getBookmarksBarId: (SQLITE_API int*) result ;
- (BOOL) insertBookmark:                (Bookmark*) bookmark result: (SQLITE_API int*) result;
- (NSMutableArray*) getBookmarkAddress: (NSString*) title result: (SQLITE_API int*) result;
@end
