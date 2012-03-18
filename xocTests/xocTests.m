//
//  xocTests.m
//  xocTests
//
//  Created by Ilya Alberton on 3/13/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import "xocTests.h"
#import "SqliteConnector.h"

@implementation xocTests

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
    // Point to the bookmark file on the iOS simulator
    NSString* bookmarkLocation = @"/Users/artmobile/Library/Application Support/iPhone Simulator/4.3.2/Library/Safari/Bookmarks.db"; 
    
    
    // Create Sqlite connector to that file
    SqliteConnector *connector = [[SqliteConnector alloc] initWithFilename: bookmarkLocation];
    
    
    /*
    // Extract all bookmarks called walla
    NSMutableArray* array =  [connector getBookmarkAddress:@"walla"];
    
    Bookmark* bookmark = [array objectAtIndex:0];  
    
    
    NSLog(@"Found bookmark called %@", bookmark.title);
     
     [array removeAllObjects];
     [array release];
 
    */
    
    Bookmark* bookmark = [Bookmark alloc];
    
    bookmark.title = @"facebook";
    bookmark.address = @"www.facebook.com";
    
    [connector insertBookmark:bookmark];
    
    
    [bookmark release];
    
    
    // When the connector is released
    [connector release];
}

@end
