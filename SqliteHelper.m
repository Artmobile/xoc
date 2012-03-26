//
//  SqliteHelper.m
//  xoc
//
//  Created by Ilya Alberton on 3/23/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import "SqliteHelper.h"

@implementation SqliteHelper

// return a new autoreleased UUID string
+ (NSString *)generateUuidString
{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // transfer ownership of the string
    // to the autorelease pool
    [uuidString autorelease];
    
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}

// Open the sqlite database from the connection string 
+ (sqlite3*)openDatabase: (NSString*) databasePath {
    sqlite3* database;
    
    if(sqlite3_open([databasePath UTF8String], &database) != SQLITE_OK) {
        return Nil;
    }
    
    return database;
}

+ (void) closeDatabase: (sqlite3*) database {
    
    free(database);
}

+ (int)executeScalarInt:    (sqlite3*) database query:   (NSString*) query{
    const char *querychar = [query UTF8String]; 
    
    sqlite3_stmt *statement;
    
    
    int result;
    
    if(sqlite3_prepare_v2(database, querychar, -1, &statement, NULL) == SQLITE_OK){
        sqlite3_step(statement);
        result = sqlite3_column_int(statement, 0);
    }
    
    
    // Release the compiled statement from memory
    sqlite3_finalize(statement);   
    
    return result;
}

+ (int)execute:             (sqlite3*) database query:   (NSString*) query{
    const char *querychar = [query UTF8String]; 
    
    sqlite3_stmt *statement;
    
    
    int result;
    
    int sql_result = sqlite3_prepare_v2(database, querychar, -1, &statement, NULL);
    
    if( sql_result == SQLITE_OK){
        sqlite3_step(statement);
        result = sqlite3_changes(database);
    }
    
    
    // Release the compiled statement from memory
    sqlite3_finalize(statement);   
    
    return result;
}


+ (sqlite3_stmt*)   prepare_query: (sqlite3*)database query:(NSString*) query{
    char sqlStatement[512];
    memset(sqlStatement, sizeof(sqlStatement),'\0');
    
    sprintf(sqlStatement, "%s", [query UTF8String]);
    
    sqlite3_stmt *compiledStatement;
    
    sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL);

    return compiledStatement;    
}

+ (NSString*)getString:(sqlite3_stmt*) statement index: (int) index {
    char* result = (char*)sqlite3_column_text(statement, index);
    
    if(result == NULL)
        return nil;
    
    return [NSString stringWithUTF8String:result];
}

@end
