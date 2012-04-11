//
//  PlistHandler.m
//  xoc
//
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import "PlistHandler.h"
#import <sqlite3.h> // Import the sqlite3 database framework

@implementation PlistHandler

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }

    return self;
}


// Thanks to the stack overflow:
// http://stackoverflow.com/questions/5847514/nsimage-to-blob-and-blob-to-nsimage-sqlite-nsdata

- inject:(NSString*)fileLocation  {
    NSString* errorDesc = @"No error";
    NSPropertyListFormat format;
    
    NSString* buddy_command = @"/usr/libexec/PlistBuddy ~/Library/Safari/Bookmarks.plist -x -c print"; 
    
    NSString* plistPath = @"/Users/artmobile/Library/Application Support/iPhone Simulator/4.3.2/Library/Safari/Bookmarks.db";
        
    // Check if the file exists
    BOOL bFileExists =  [[NSFileManager defaultManager] fileExistsAtPath:plistPath];
    
    
    // A proper way of accessing Library directory
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    
    
    //[self readDatabase];
    [self insertBookmark];
    
    
    return [NSString stringWithFormat: @"%@ - was parsed", fileLocation];
}


-(void)insertBookmark//:(NSString *)title url:(NSString *)url data:(NSData *)data
{
    NSString *title = @"google";
    NSString *url = @"www.google.com";
    
    sqlite3 *database;

    NSString* databasePath = @"/Users/artmobile/Library/Application Support/iPhone Simulator/4.3.2/Library/Safari/Bookmarks.db";
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
//        NSString *query = [NSString stringWithFormat:@"INSERT INTO bookmarks (title, url) VALUES ('%@', '%@')",title, url];
        NSString *query = @"INSERT INTO bookmarks (special_id, parent, type, title, url, num_children, editable, deletable, hidden, hidden_ancestor_count, order_index, external_uuid, sync_key, extra_attributes) VALUES (0,0,0, 'walla', 'www.walla.com', 0, 1,1,0,0,5, '00000000-0000-0000-0000-000000000001', NULL, NULL)";        
        
        //NSString *query = @"INSERT INTO route (name) VALUES ('kvishshesh')";
        
        const char *querychar = [query UTF8String]; 
        
        sqlite3_stmt *statement; 
        
        
        if (sqlite3_prepare_v2(database, querychar, -1, &statement, NULL) == SQLITE_OK)
        {
            
            int row =  3;
            
            //sqlite3_bind_blob(statement, row, [imagedata bytes], [imagedata length], NULL);
            
            sqlite3_step(statement);
            
            sqlite3_finalize(statement);
            
        }
        else
        {
            NSLog(@"Error"); 
        }
        
        [databasePath retain]; 
    }
    sqlite3_close(database);
}


-(void) readDatabase {
    // Setup the database object
    sqlite3 *database;
    
    NSMutableArray* bookmarks = [[NSMutableArray alloc] init];
    
    NSString* databasePath = @"/Users/artmobile/Library/Application Support/iPhone Simulator/4.3.2/Library/Safari/Bookmarks.db";
    
    // Open the database from the users filessytem
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        // Setup the SQL Statement and compile it for faster access
        const char *sqlStatement = "SELECT title, url FROM Bookmarks ORDER BY title ASC";
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
        sqlite3_close(database); 
        
        [databasePath retain]; 
    }
}

@end
