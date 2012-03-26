//
//  xocTests.m
//  xocTests
//
//  Created by Ilya Alberton on 3/13/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import "xocTests.h"
#import "SqliteConnector.h"
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
    [self testGetBookmarkAddress];
}

- (void)testSqlHelper{
    NSMutableArray* bookmarks = [[NSMutableArray alloc] init];
    
    sqlite3* database = [SqliteHelper openDatabase: bookmarkLocation];
    
    sqlite3_stmt* stmt = [SqliteHelper prepare_query: database query:@"SELECT title, url FROM bookmarks"];
    
    
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
        Bookmark* bm = (Bookmark*)current;
        NSLog(@"%@", bm.title);
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(database); 
}

- (void) testInsertBookmarkInsert {
    // Create Sqlite connector to that file
    SqliteConnector *connector = [[SqliteConnector alloc] initWithFilename: bookmarkLocation];
    
    Bookmark* bookmark = [Bookmark alloc];
    
    bookmark.title = @"facebook";
    bookmark.address = @"www.facebook.com";
    
    [connector insertBookmark:bookmark];
    
    
    [bookmark release];
    
    
    // When the connector is released
    [connector release];
}

- (void) testGetBookmarkAddress {
    // Create Sqlite connector to that file
    SqliteConnector *connector = [[SqliteConnector alloc] initWithFilename: bookmarkLocation];

    
    // Extract all bookmarks called walla
    NSMutableArray* array =  [connector getBookmarkAddress:@"facebook"];
    
    Bookmark* bookmark = [array objectAtIndex:0];  
    
    NSLog(@"Found bookmark called %@", bookmark.address);
    
    [array release];
}
@end
