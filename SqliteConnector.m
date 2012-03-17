//
//  SqliteConnector.m
//  xoc
//
//  Created by Ilya Alberton on 3/16/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import "SqliteConnector.h"
#import <sqlite3.h> // Import the sqlite3 database framework



@implementation SqliteConnector


NSString* databasePath;
sqlite3 *database;


// This is a constructor
- (id)init: (NSString*) fileName
{
    // Save the file name
    databasePath = fileName;
    
    if(sqlite3_open([databasePath UTF8String], &database) != SQLITE_OK) {
        return Nil;
    }
    
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    [databasePath retain]; // Make sure that the database path is retained
    
    return self;
}


- (void)dealloc {
    [databasePath release];
    
    sqlite3_close(database);    
    
    free(database); // Free the database object since it's a C and not Objective C object
    
    [super dealloc];
}

// Will add a new bookmark
- (void) insertBookmark: (NSString*) title url:(NSString*) url{
    NSLog(@"Bookmark was inserted successfully");
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
    
    if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        
        // Loop through the results and add them to the feeds array
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            
            // Read the data from the result row
            NSString *aTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            
            NSString *aUrl = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
        }
    }
    
    // Release the compiled statement from memory
    sqlite3_finalize(compiledStatement);    
    
    return bookmarks; 
}


@end
