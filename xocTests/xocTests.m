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
    SqliteConnector *connector = [[SqliteConnector alloc] init: @"/Users/artmobile/Library/Application Support/iPhone Simulator/4.3.2/Library/Safari/Bookmarks.db"];
    
    [connector getBookmarkAddress:@"walla"];
    
    // When the connector is released
    [connector release];
}

@end
