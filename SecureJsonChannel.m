
#import "JSONKit.h"
#import "SecureJsonChannel.h"
#import "JsonHelper.h"
#import "Cipher.h"

@implementation SecureJsonChannel

+ (NSString*) permanent {
    return @"A34vB1007688";
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSDictionary*) get:(NSString*) url andPassword:(NSString*) password {
    NSDictionary* result = [JsonHelper get:url timeoutInterval:60.0];
    
    // Get a string from JSON. The string must be Base64 encoded by sender
    NSString* str = [result objectForKey:@"data"];
    
    // Convert string into NSData
    NSData* dat= [NSData dataWithBase64EncodedString:str];
    
    // Execute Cipher
    Cipher* cipher = [[Cipher alloc] initWithKey:password];
    NSData* decrypted = [cipher decrypt:dat];
    
    JSONDecoder* decoder = [[JSONDecoder alloc] init];    
    NSDictionary *dict = [decoder objectWithData:decrypted];

    return dict;
}

+ (NSString*) negotiateKey:(NSString*) server{
    NSString* url = [NSString stringWithFormat: @"%@/SecureSocialAjax/negotiate?password=%@", server, [self permanent]];    
    
    // Convert string into NSData
    NSDictionary* result = [JsonHelper get:url timeoutInterval:60.0];

    // Get a string from JSON. The string must be Base64 encoded by sender
    NSString* str = [result objectForKey:@"data"];
    
    // Convert string into NSData
    NSData* dat= [NSData dataWithBase64EncodedString:str];
    
    // Execute Cipher
    Cipher* cipher = [[Cipher alloc] initWithKey:[self permanent]];
    NSData* decrypted = [cipher decrypt:dat];
    
    JSONDecoder* decoder = [[JSONDecoder alloc] init];    
    NSDictionary *dict = [decoder objectWithData:decrypted];
    
    return [dict objectForKey:@"key"];
}

@end
