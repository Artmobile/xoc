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

+ (NSString*)       fromCode: (SQLITE_API int) code {
    switch(code)
    {
        case SQLITE_OK:             return @"OK";
        case SQLITE_ERROR:          return @"SQL error or missing database";
        case SQLITE_INTERNAL:       return @"nternal logic error in SQLite";
        case SQLITE_PERM:           return @"Access permission denied";
        case SQLITE_ABORT:          return @"Callback routine requested an abort";
        case SQLITE_BUSY:           return @"The database file is locked";
        case SQLITE_LOCKED:         return @"A table in the database is locked";
        case SQLITE_NOMEM:          return @"A malloc() failed";
        case SQLITE_READONLY:       return @"Attempt to write a readonly database";
        case SQLITE_INTERRUPT:      return @"Operation terminated by sqlite3_interrupt()";
        case SQLITE_IOERR:          return @"Some kind of disk I/O error occurred";
        case SQLITE_CORRUPT:        return @"The database disk image is malformed";
        case SQLITE_NOTFOUND:       return @"NOT USED. Table or record not found";
        case SQLITE_FULL:           return @"Insertion failed because database is full";
        case SQLITE_CANTOPEN:       return @"Unable to open the database file";
        case SQLITE_PROTOCOL:       return @"Database lock protocol error";
        case SQLITE_EMPTY:          return @"Database is empty";
        case SQLITE_SCHEMA:         return @"The database schema changed";
        case SQLITE_TOOBIG:         return @"String or BLOB exceeds size limit";
        case SQLITE_CONSTRAINT:     return @"Abort due to constraint violation";
        case SQLITE_MISMATCH:       return @"Data type mismatch";
        case SQLITE_MISUSE:         return @"Library used incorrectly";
        case SQLITE_NOLFS:          return @"Uses OS features not supported on host";
        case SQLITE_AUTH:           return @"Authorization denied";
        case SQLITE_FORMAT:         return @"Auxiliary database format error";
        case SQLITE_RANGE:          return @"2nd parameter to sqlite3_bind out of range";
        case SQLITE_NOTADB:         return @"File opened that is not a database file";
        case SQLITE_ROW:            return @"sqlite3_step() has another row ready";
        case SQLITE_DONE:           return @"sqlite3_step() has finished executing";
        default: return @"Unknown code";    
    }
}

+ (void) logError:(int) error_code message: (NSString*) message, ...{
    va_list args;
    va_start(args, message);
    NSLog(@"\nError (%d) occurred. [%@]",error_code,  [SqliteHelper fromCode:error_code]); 
    NSLogv(message, args);
    va_end(args);
}

// Open the sqlite database from the connection string 
+ (sqlite3*)openDatabase: (NSString*) databasePath result:(SQLITE_API int*) result {
    sqlite3* database;
    
    *result = sqlite3_open([databasePath UTF8String], &database);
    
    if(*result != SQLITE_OK) {
        return NULL;
    }
    
    return database;
}

+ (void) closeDatabase: (sqlite3*) database {
    
    free(database);
}

+ (int)executeScalarInt:    (sqlite3*) database query:   (NSString*) query result: (SQLITE_API int*) result{
    const char *querychar = [query UTF8String]; 
    
    sqlite3_stmt *statement;
    
    *result =sqlite3_prepare_v2(database, querychar, -1, &statement, NULL);
    
    int return_value;
    
    if(*result == SQLITE_OK){
        sqlite3_step(statement);
        return_value = sqlite3_column_int(statement, 0);
    }
    
    
    // Release the compiled statement from memory
    sqlite3_finalize(statement);   
    
    return return_value;
}

// Returns rows affected
+ (int)execute:             (sqlite3*) database query:   (NSString*) query result: (SQLITE_API int*) result{
    const char *querychar = [query UTF8String]; 
    
    sqlite3_stmt *statement;
    
    *result = sqlite3_prepare_v2(database, querychar, -1, &statement, NULL);
    int rows_affected = 0;
    if( *result == SQLITE_OK){
        sqlite3_step(statement);
        rows_affected = sqlite3_changes(database);
    }
    
    
    // Release the compiled statement from memory
    sqlite3_finalize(statement);   
    
    return rows_affected;
}


+ (sqlite3_stmt*)   prepare_query: (sqlite3*)database query:(NSString*) query result:(SQLITE_API int*) result{
    if(database == NULL)
        return NULL;
    
    char sqlStatement[512];
    memset(sqlStatement, sizeof(sqlStatement),'\0');
    
    sprintf(sqlStatement, "%s", [query UTF8String]);
    
    sqlite3_stmt *compiledStatement;
    
    *result =  sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL);
    if(*result != SQLITE_OK)
        return NULL;

    return compiledStatement;    
}

+ (NSString*)getString:(sqlite3_stmt*) statement index: (int) index {
    char* result = (char*)sqlite3_column_text(statement, index);
    
    if(result == NULL)
        return nil;
    
    return [NSString stringWithUTF8String:result];
}

@end
