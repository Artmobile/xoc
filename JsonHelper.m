//
//  JsonHelper.m
//  xoc
//
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//


#import "JsonHelper.h"
#import "JSONKit.h"

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

@end
