//
//  JsonHelper.m
//  xoc
//
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//


#import "JsonHelper.h"
#import "JSONKit.h"

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@implementation JsonHelper
 
/*! 
 @method get:
 @abstract Retrieves JSON from provided URL.
 @discussion This function will return a Dictionary populated from JSON response.
 @param URL to fetch  JSON from and the timeInterval to wait for response.
 @result A newly-created and autoreleased NSURLRequest instance.
 */ 
+ (NSDictionary*) get: (NSString*) url timeoutInterval:(NSTimeInterval) timeoutInterval {
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:timeoutInterval];  
    NSHTTPURLResponse* response; 
    NSError* err;
    
    NSData* jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];   
    
    if([response statusCode] == 200){
        
        JSONDecoder* decoder = [[JSONDecoder alloc] init];    
        NSDictionary *dict = [decoder objectWithData:jsonData];
        return dict;
    }
    else
        return [NSDictionary alloc];
}


+ (id)dataWithBase64EncodedString:(NSString *)string;
{
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:nil];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

/*!
 // Java example
 public static byte[] encryptTripleDES(String message) throws Exception {
    final MessageDigest md = MessageDigest.getInstance("md5");
    final byte[] digestOfPassword = md.digest("--KEY--".getBytes("utf-8"));
    final SecretKey key = new SecretKeySpec(digestOfPassword, "DESede");
    final IvParameterSpec iv = new IvParameterSpec(new byte[8]);
    final Cipher cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
    cipher.init(Cipher.ENCRYPT_MODE, key, iv);
    return cipher.doFinal(message.getBytes("utf-8"));
 } 
*/ 
+ (NSString*) doCipher:(NSString*) key plainText:(NSString*)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt {
    
    const void *vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        NSData *EncryptData = [JsonHelper dataWithBase64EncodedString:plainText];
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
    }
    else
    {
        NSData *tempData = [plainText dataUsingEncoding:NSASCIIStringEncoding];
        plainTextBufferSize = [tempData length];
        vplainText =  [tempData bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    //  uint8_t ivkCCBlockSize3DES;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    //NSString *key = [NSString MD5:@"HSDNIFFU"];
    
    NSData *_keyData = [key dataUsingEncoding:NSASCIIStringEncoding];
    
    NSLog(@"key byte is %s", [_keyData bytes]);
    
    // Initialization vector; dummy in this case 0's.
    uint8_t iv[kCCBlockSize3DES];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       (const void *)[_keyData bytes], //"123456789012345678901234", //key
                       kCCKeySize3DES,
                       iv,  //iv,
                       vplainText,  //plainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    //if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
    /*else*/ if (ccStatus == kCCParamError) return @"PARAM ERROR";
    else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
    else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
    else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
    else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
    else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED";
    
    NSString *result;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        
        //  result = [[NSString alloc] initWithData: [NSData dataWithBytes:(const void *)bufferPtr length:[(NSUInteger)movedBytes] encoding:NSASCIIStringEncoding]];
        result = [[[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSASCIIStringEncoding] autorelease];
    }
    else
    {
        NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        NSLog(@"data is: %@", myData);
        result = [myData base64Encoding];
    }
    return result;
}
@end
