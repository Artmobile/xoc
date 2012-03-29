//
//  xocTests.m
//  xocTests
//
//  Created by Ilya Alberton on 3/13/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import "xocTests.h"
#import "BookmarkManager.h"
#import "SqliteHelper.h"


@implementation xocTests

// Point to the bookmark file on the iOS simulator
NSString* bookmarkLocation = @"/Users/artmobile/Library/Application Support/iPhone Simulator/4.3.2/Library/Safari/Bookmarks.db"; 


- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testExample
{
    /*
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES) lastObject];
    bookmarkLocation = [libraryPath stringByAppendingPathComponent:@"Safary/Bookmarks.db"];
    */
}


- (void)testSqlHelper{
    NSMutableArray* bookmarks = [[NSMutableArray alloc] init];
    SQLITE_API int result;
    sqlite3* database = [SqliteHelper openDatabase: bookmarkLocation result:&result];
    if(result != SQLITE_OK)
    {
        [SqliteHelper logError: result message:@"Could not open database %@", bookmarkLocation];
        return;
    }
    
    NSString* query = @"SELECT title, url FROM bookmarks";
    
    sqlite3_stmt* stmt = [SqliteHelper prepare_query: database query:query result:&result];
    if(result != SQLITE_OK)
    {
        [SqliteHelper logError: result message:@"Could not prepare a statement for %@", query];
        return;
    }

    
    while(sqlite3_step(stmt) == SQLITE_ROW) {
        
        NSString *aUrl = [SqliteHelper getString:stmt index:1];
        
        
        // Read the data from the result row
        NSString *aTitle = [SqliteHelper getString:stmt index:0];
        
        
        Bookmark* bookmark = [Bookmark alloc];
        
        bookmark.title = aTitle;
        bookmark.address = aUrl;
        
        
        [bookmark retain];   
        
        [bookmarks addObject:bookmark];
    }
    
    
    for (id current in bookmarks) {
        NSLog(@"%@", ((Bookmark*)current).title);
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(database); 
}

- (void) testInsertBookmarkInsert {
    // Create Sqlite connector to that file
    SQLITE_API int result;
    BookmarkManager *connector = [[BookmarkManager alloc] initWithFilename: bookmarkLocation result: &result];
    
    if(result != SQLITE_OK)
    {
        [SqliteHelper logError: result message:@"Could not initialize the bookmark manager. Requested database file was %@", bookmarkLocation];
        return;
    }
    
    Bookmark* bookmark = [Bookmark alloc];
    
    bookmark.title = @"facebook";
    bookmark.address = @"www.facebook.com";
    
    [connector insertBookmark:bookmark result:&result];
    if(result != SQLITE_OK)
        [SqliteHelper logError: result message:@"Could not insert bookmark. Bookmark taitle was %@ and address was %@", bookmark.title, bookmark.address];
    


    
    [bookmark release];
    
    
    // When the connector is released
    [connector release];
}

- (void) testGetBookmarkAddress {
    // Create Sqlite connector to that file
    SQLITE_API int result;
    BookmarkManager *connector = [[BookmarkManager alloc] initWithFilename: bookmarkLocation result: &result];
    if(result != SQLITE_OK)
    {
        [SqliteHelper logError: result message:@"Could not initialize the bookmark manager. Requested database file was %@", bookmarkLocation];
        return;
    }

    
    // Extract some bookmarks
    NSMutableArray* array =  [connector getBookmarkAddress:@"facebook" result: &result];
    if(result != SQLITE_OK)
    {
        [SqliteHelper logError: result message:@"Could find a bookmarks address for the title %@", @"facebook"];
        return;
    }
    
    Bookmark* bookmark = [array objectAtIndex:0];  
    
    NSLog(@"Found bookmark called %@", bookmark.address);
    
    [array release];
}
@end
