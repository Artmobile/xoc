//
//  JsonHelper.h
//  xoc
//
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonCryptor.h>

@interface JsonHelper : NSObject

+ (id)dataWithBase64EncodedString:(NSString *)string;
+ (NSDictionary*)       get: (NSString*) url timeoutInterval:(NSTimeInterval) timeoutInterval;
+ (NSString*) doCipher:(NSString*) key plainText:(NSString*)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt;
@end
