//
//  SqliteHelper.h
//  xoc
//
//  Created by Ilya Alberton on 3/23/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h> // Import the sqlite3 database framework

@interface SqliteHelper : NSObject
+ (sqlite3*)        openDatabase:   (NSString*) databasePath;   
+ (void)            closeDatabase:     (sqlite3*)  database;
+ (sqlite3_stmt*)   prepare_query: (sqlite3*)database query:(NSString*) query;
+ (NSString*)       getString: (sqlite3_stmt*) statement index: (int) index;

+ (int)             executeScalarInt:    (sqlite3*) database query:   (NSString*) query;
+ (int)             execute:             (sqlite3*) database query:   (NSString*) query; 

@end
