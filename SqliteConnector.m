//
//  SqliteConnector.m
//  xoc
//
//  Created by Ilya Alberton on 3/16/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import "SqliteConnector.h"




@implementation SqliteConnector


// This is a constructor
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithFilename: (NSString*) fileName
{
    // Save the file name
    _databasePath = fileName;
    
    _database = [SqliteHelper openDatabase:fileName];
    
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    [_databasePath retain]; // Make sure that the database path is retained
    
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

- (void) insertBookmark: (Bookmark*) bookmark{
    
    int bookmarks_bar_id = [self getBookmarksBarId];

    
    // Create a new Bookmark.
     
    NSString *query = [NSString stringWithFormat: @"INSERT INTO bookmarks (special_id, parent, type, title, url, num_children, editable, deletable, hidden, hidden_ancestor_count, order_index, external_uuid, sync_key, extra_attributes) VALUES (0,%d,0, '%@', '%@', 0, 1,1,0,0,5, %@, NULL, NULL)",bookmarks_bar_id,bookmark.title, bookmark.address, [SqliteHelper generateUuidString] ];        
    
    
    int rows_affected = 0;
    
    rows_affected = [SqliteHelper execute:_database query:query];

    
    // Now that a new bookmark has been created, increment bookmarks num_of children
    NSString* update = [NSString stringWithFormat:@"UPDATE bookmarks SET num_children = num_children+1 WHERE id=%d", bookmarks_bar_id];
    
    rows_affected = [SqliteHelper execute: _database query: update];
}


- (int) getBookmarksBarChildren {

    return [SqliteHelper executeScalarInt:_database query:@"SELECT num_children FROM bookmarks WHERE title='BookmarksBar''"];
}

- (int) getBookmarksBarId {
    return [SqliteHelper executeScalarInt:_database query:@"SELECT id FROM bookmarks WHERE title='BookmarksBar'"];
}



// Will extract a bookmark using a title
- (NSMutableArray*) getBookmarkAddress: (NSString*) title{
    NSString* query = [NSString stringWithFormat:@"SELECT title, url FROM Bookmarks WHERE title=\'%@\' ORDER BY title ASC", title];
    sqlite3_stmt* stmt = [SqliteHelper prepare_query: _database query: query];
    
    NSMutableArray* bookmarks = [[NSMutableArray alloc] init];
    
    while(sqlite3_step(stmt) == SQLITE_ROW) {
        
        NSString *aUrl = [SqliteHelper getString:stmt index:1];
        
        
        // Read the data from the result row
        NSString *aTitle = [SqliteHelper getString:stmt index:0];
        
        Bookmark* bookmark = [Bookmark alloc];
        
        bookmark.title = aTitle;
        bookmark.address = aUrl;
        
        [bookmarks addObject:bookmark];
    }
    
    sqlite3_finalize(stmt);

    return bookmarks; 
}


@end
