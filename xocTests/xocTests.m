//
//  xocTests.m
//  xocTests
//
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import "xocTests.h"
#import "BookmarkManager.h"
#import "SqliteHelper.h"
#import <UIKit/UIKit.h>
#import "JsonHelper.h"
#import "Cipher.h"
#import "Base64Encoder.h"
#import "SecureJsonChannel.h"


@implementation xocTests

// Point to the bookmark file on the iOS simulator
NSString* bookmarkLocation = @"";


- (void)setUp
{
    [super setUp];
    
#if TARGET_IPHONE_SIMULATOR
    NSString* version = [[UIDevice currentDevice] systemVersion];
    bookmarkLocation =[NSString stringWithFormat: @"/Users/%@/Library/Application Support/iPhone Simulator/%@/Library/Safari/Bookmarks.db", NSUserName(),version];
#else
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES) lastObject];
    NSString* location  = [libraryPath stringByAppendingPathComponent:@"Safary/Bookmarks.db"];
    
    bookmarkLocation = location;
#endif
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testCipherChannel{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSString* key = [SecureJsonChannel negotiateKey:@"http://localhost:9001"];
    
    NSString* message = @"One%20way";
    
    NSDictionary* result = [SecureJsonChannel get:
                            [NSString stringWithFormat: @"http://localhost:9001/securesocialajax/testNested?message=%@", message] 
                            andPassword:key];
    
    NSLog(@"%@", [result objectForKey:@"content"]);
    
    [pool drain];
}

- (void)testCipher{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSDictionary* result = [JsonHelper get:@"http://localhost:9001/securesocialajax/test?message=One%20way&password=ticktick" timeoutInterval:60.0];
    
    // Get a string from JSON. The string must be Base64 encoded by sender
    NSString* str = [result objectForKey:@"data"];
    
    // Convert string into NSData
    NSData* dat= [NSData dataWithBase64EncodedString:str];
    
    // Execute Cipher
    Cipher* cipher = [[Cipher alloc] initWithKey:@"ticktick"];
    NSData* decrypted = [cipher decrypt:dat];
    
    // Convert the decrypted result into text
    NSString* plainText = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    
    // Print it
    NSLog(@"%@",plainText);
    
    [pool drain];
}

- (void)testSqlHelper{
    NSMutableArray* bookmarks = [[NSMutableArray alloc] init];
    SQLITE_API int result;
    sqlite3* database = [SqliteHelper openDatabase: bookmarkLocation result:&result];
    if(result != SQLITE_OK)
    {
        // NOTE that we cannot use logLastError since the database is not open yet
        [SqliteHelper logError: result message:@"Could not open database %@", bookmarkLocation];
        return;
    }
    
    NSString* query = @"SELECT title, url FROM bookmarks1";
    
    sqlite3_stmt* stmt = [SqliteHelper prepare_query: database query:query result:&result];
    if(result != SQLITE_OK)
    {
        [SqliteHelper logLastError: database message:@"Could not prepare a statement for %@", query];
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
    BookmarkManager *connector = [[BookmarkManager alloc] initWithResult: &result];
    
    if(result != SQLITE_OK)
    {
        [SqliteHelper logError: result message:@"Could not initialize the bookmark manager. Requested database file was %@", bookmarkLocation];
        return;
    }
    
    Bookmark* bookmark = [Bookmark alloc];
    
    bookmark.title = @"IBM";
    bookmark.address = @"www.ibm.com";
    
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
    BookmarkManager *connector = [[BookmarkManager alloc] initWithResult: &result];
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
