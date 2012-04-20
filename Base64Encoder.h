//
//  Base64Encoder.h
//  xoc
//
//  Created by Ilya Alberton on 4/19/12.
//  Copyright 2012 artmobile@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;
@end


