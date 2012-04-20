

#import <Foundation/Foundation.h>

@interface SecureJsonChannel : NSObject
+ (NSString*) negotiateKey:(NSString*) server;
+ (NSDictionary*) get:(NSString*)url andPassword:(NSString*) password;
@end
