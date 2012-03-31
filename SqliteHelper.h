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
+ (sqlite3*)        openDatabase:   (NSString*) databasePath result: (SQLITE_API int*) result;   
+ (void)            closeDatabase:     (sqlite3*)  database;
+ (sqlite3_stmt*)   prepare_query: (sqlite3*)database query:(NSString*) query result: (SQLITE_API int*) result;
+ (NSString*)       getString: (sqlite3_stmt*) statement index: (int) index;

+ (int)             executeScalarInt:    (sqlite3*) database query:   (NSString*) query result: (SQLITE_API int*) result;
+ (int)             execute:             (sqlite3*) database query:   (NSString*) query result: (SQLITE_API int*) result; 

+ (void)            logError:(int) error_code message: (NSString*) message, ...;
+ (void)            logLastError: (sqlite3*) database message: (NSString*) message, ...;

+ (NSString*)       fromCode: (SQLITE_API int) code;

// return a new autoreleased UUID string
+ (NSString *)generateUuidString;


@end
