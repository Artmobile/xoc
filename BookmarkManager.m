//
//  SqliteConnector.m
//  xoc
//
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import "BookmarkManager.h"

@implementation BookmarkManager

- (id)init
{
    self = [super init];
    if (self) {
        // Initialize here
    }
    
    return self;
}

// This is a constructor
- (id)initWithResult: (SQLITE_API int*) result
{
    self = [super init];
    if (self) {
        
#if TARGET_IPHONE_SIMULATOR
        NSString* version = [[UIDevice currentDevice] systemVersion];
        _databasePath=[NSString stringWithFormat: @"/Users/%@/Library/Application Support/iPhone Simulator/%@/Library/Safari/Bookmarks.db", NSUserName(),version];
#else
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES) lastObject];
        _databasePath  = [libraryPath stringByAppendingPathComponent:@"Safari/Bookmarks.db"];
#endif
    }
    
    // Check if we arunning in the similator
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath: _databasePath];
    
    if(!exists)
        return NULL;

    // Now that everything is fine, open
    _database = [SqliteHelper openDatabase:_databasePath result: result];

    
    return self;
}

- (id)initWithFilename: (NSString*) fileName result: (SQLITE_API int*) result
{
    self = [super init];
    if (self) {
        // Initialization code here.
        // Save the file name
        _databasePath = fileName;
        
        _database = [SqliteHelper openDatabase:fileName result: result];
        
        
        if(_database == NULL)
            return NULL;
    }
    
    [_databasePath retain]; // Make sure that the database path is retained

    *result = SQLITE_OK;
    
    return self;
}

- (void)dealloc {
    [_databasePath release];

    [SqliteHelper closeDatabase:_database];
    
    [super dealloc];
}



// Will add a new bookmark
// Thanks to the stack overflow:
// http://stackoverflow.com/questions/5847514/nsimage-to-blob-and-blob-to-nsimage-sqlite-nsdata

- (BOOL) insertBookmark: (Bookmark*) bookmark result: (SQLITE_API int*) result{
    
    int bookmarks_bar_id = [self getBookmarksBarId:result];
    if(SQLITE_OK != *result){
        [SqliteHelper logLastError: _database message: @"Failed to insert bookmark. Failed to retrieve bookmark id"];
        return FALSE;
    }

    // TODO first check if such a bookmark already exists
    NSMutableArray* addresses = [self getBookmarkAddress:bookmark.title result:result];
    if([addresses count] > 0)
        return FALSE;
    
    // Create a new Bookmark.
    NSString *query = [NSString stringWithFormat: @"INSERT INTO bookmarks (special_id, parent, type, title, url, num_children, editable, deletable, hidden, hidden_ancestor_count, order_index, external_uuid, sync_key, extra_attributes) VALUES (0,%d,0, '%@', '%@', 0, 1,1,0,0,5, '%@', NULL, NULL)",bookmarks_bar_id,bookmark.title, bookmark.address, [SqliteHelper generateUuidString] ];        
    
    int rows_affected = 0;
    
    rows_affected = [SqliteHelper execute:_database query:query result:result];
    if(SQLITE_OK != *result){
        [SqliteHelper logLastError: _database  message: @"Failed to insert bookmark. Could not prepare a statement for %@", query];
        return FALSE;
    }
    
    // Now that a new bookmark has been created, increment bookmarks num_of children
    NSString* update = [NSString stringWithFormat: @"UPDATE bookmarks SET num_children = num_children+1 WHERE id=%d", bookmarks_bar_id];
    
    rows_affected = [SqliteHelper execute: _database query: update result:result];
    
    return TRUE;
}


- (int) getBookmarksBarChildren: (SQLITE_API int*) result {
    NSString *query = @"SELECT num_children FROM bookmarks WHERE title='BookmarksBar'";
    
    int children = [SqliteHelper executeScalarInt:_database query:query result:result];
    if(SQLITE_OK != *result)
    {
        [SqliteHelper logLastError: _database message: @"Could not retrieve bookmark childrent number. Could not prepare a statement for %@", query];    
        return -1;
    }
    
    return children;
}

- (int) getBookmarksBarId: (SQLITE_API int*) result {
    NSString* query = @"SELECT id FROM bookmarks WHERE title='BookmarksBar'";
    int children =  [SqliteHelper executeScalarInt:_database query:query result:result];

    if(SQLITE_OK != *result)
    {
        [SqliteHelper logLastError:_database message: @"Could not retrieve bookmarks bar id. Could not prepare a statement for %@", query];    
        return -1;
    }

    return children;
}



// Will extract a bookmark using a title
- (NSMutableArray*) getBookmarkAddress: (NSString*) title result: (SQLITE_API int*) result{
    NSString* query = [NSString stringWithFormat:@"SELECT title, url FROM Bookmarks WHERE title=\'%@\' ORDER BY title ASC", title];
    
    
    sqlite3_stmt* stmt = [SqliteHelper prepare_query: _database query: query result: result];

    NSMutableArray* bookmarks = [[NSMutableArray alloc] init];
    
    if(*result != SQLITE_OK){
        if(SQLITE_OK != result)
        {
            [SqliteHelper logLastError: _database message: @"Failed to get the bookmark address. Could not prepare a statement for %@", query];    
            return 0;
        }

        return bookmarks; // Return an empty array
    }    
    
    while((*result = sqlite3_step(stmt)) == SQLITE_ROW) {
        
        NSString *aUrl = [SqliteHelper getString:stmt index:1];
        
        
        // Read the data from the result row
        NSString *aTitle = [SqliteHelper getString:stmt index:0];
        
        Bookmark* bookmark = [Bookmark alloc];
        
        bookmark.title = aTitle;
        bookmark.address = aUrl;
        
        [bookmarks addObject:bookmark];
    }
    
    *result = sqlite3_finalize(stmt);

    return bookmarks; 
}


@end
