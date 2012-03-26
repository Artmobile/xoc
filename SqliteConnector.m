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
    
    if(sqlite3_open([_databasePath UTF8String], &_database) != SQLITE_OK) {
        return Nil;
    }
    
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    [_databasePath retain]; // Make sure that the database path is retained
    
    return self;
}

- (void)dealloc {
    [_databasePath release];
    
    sqlite3_close(_database);    
    
    free(_database); // Free the database object since it's a C and not Objective C object
    
    [super dealloc];
}

- (int)executeScalarInt: (NSString*) query{
    const char *querychar = [query UTF8String]; 
    
    sqlite3_stmt *statement;
    
    
    int result;
    
    if(sqlite3_prepare_v2(_database, querychar, -1, &statement, NULL) == SQLITE_OK){
        sqlite3_step(statement);
        result = sqlite3_column_int(statement, 0);
    }
    
    
    // Release the compiled statement from memory
    sqlite3_finalize(statement);   
    
    return result;
    
}

- (int) execute: (NSString*) query{
    const char *querychar = [query UTF8String]; 
    
    sqlite3_stmt *statement;
    
    
    int result;
    
    int sql_result = sqlite3_prepare_v2(_database, querychar, -1, &statement, NULL);
    
    if( sql_result == SQLITE_OK){
        sqlite3_step(statement);
        result = sqlite3_changes(_database);
    }
    
    
    // Release the compiled statement from memory
    sqlite3_finalize(statement);   
    
    return result;
}

// Will add a new bookmark
// Thanks to the stack overflow:
// http://stackoverflow.com/questions/5847514/nsimage-to-blob-and-blob-to-nsimage-sqlite-nsdata

- (void) insertBookmark: (Bookmark*) bookmark{
    
    int bookmarks_bar_id = [self getBookmarksBarId];

    
    // Create a new Bookmark.
     
    NSString *query = [NSString stringWithFormat: @"INSERT INTO bookmarks (special_id, parent, type, title, url, num_children, editable, deletable, hidden, hidden_ancestor_count, order_index, external_uuid, sync_key, extra_attributes) VALUES (0,%d,0, '%@', '%@', 0, 1,1,0,0,5, '00000000-0000-0000-0000-000000000001', NULL, NULL)",bookmarks_bar_id,bookmark.title, bookmark.address ];        
    
    
    int rows_affected = 0;
    
    rows_affected = [self execute: query];

    
    // Now that a new bookmark has been created, increment bookmarks num_of children
    NSString* update = [NSString stringWithFormat:@"UPDATE bookmarks SET num_children = num_children+1 WHERE id=%d", bookmarks_bar_id];
    
    rows_affected = [self execute: update];
}


- (int) getBookmarksBarChildren {

    return [self executeScalarInt:@"SELECT num_children FROM bookmarks WHERE title='BookmarksBar''"];
}

- (int) getBookmarksBarId {
    return [self executeScalarInt:@"SELECT id FROM bookmarks WHERE title='BookmarksBar'"];
}



// Will extract a bookmark using a title
- (NSMutableArray*) getBookmarkAddress: (NSString*) title{
    
    NSMutableArray* bookmarks = [[NSMutableArray alloc] init];

    
    // Setup the SQL Statement and compile it for faster access
    //const char *sqlStatement = "SELECT title, url FROM Bookmarks ORDER BY title ASC";
    
    char sqlStatement[512];
    memset(sqlStatement, sizeof(sqlStatement),'\0');
    
    sprintf(sqlStatement, "SELECT title, url FROM Bookmarks WHERE title=\'%s\' ORDER BY title ASC", [title UTF8String]);
    
    NSString* query = [NSString stringWithUTF8String:sqlStatement];
    
    sqlite3_stmt *compiledStatement;
    
    if(sqlite3_prepare_v2(_database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        
        // Loop through the results and add them to the feeds array
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            
            // Read the data from the result row
            NSString *aTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            
            NSString *aUrl = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
            
            Bookmark* bookmark = [Bookmark alloc];
            
            bookmark.title = aTitle;
            bookmark.address = aUrl;
            
            [bookmarks addObject:bookmark];
        }
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(compiledStatement);    
    
    return bookmarks; 
}


@end
