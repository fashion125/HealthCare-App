//
//  Toolbox.m
//  Cronometer
//
//  Created by Boris Esanu on 21/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "Toolbox.h"

#import <CommonCrypto/CommonDigest.h>

@implementation Toolbox

+ (NSString *) urlEncode: (NSString *)str {
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)str,  NULL,  (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    return  encodedString;
}



+ (NSData *)sha256:(NSData *)data {
   unsigned char hash[CC_SHA256_DIGEST_LENGTH];
   if ( CC_SHA256([data bytes], (CC_LONG)[data length], hash) ) {
      return [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];        
   }
   return nil;
}


static char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";  
  
+(NSString *)encode:(NSData *)plainText {  
   unsigned long encodedLength = (((([plainText length] % 3) + [plainText length]) / 3) * 4) + 1;
   unsigned char *outputBuffer = malloc(encodedLength);  
   unsigned char *inputBuffer = (unsigned char *)[plainText bytes];  
   
   NSInteger i;  
   NSInteger j = 0;  
   unsigned long remain;
   
   for(i = 0; i < [plainText length]; i += 3) {  
      remain = [plainText length] - i;  
      
      outputBuffer[j++] = alphabet[(inputBuffer[i] & 0xFC) >> 2];  
      outputBuffer[j++] = alphabet[((inputBuffer[i] & 0x03) << 4) |   
                                   ((remain > 1) ? ((inputBuffer[i + 1] & 0xF0) >> 4): 0)];  
      
      if(remain > 1)  
         outputBuffer[j++] = alphabet[((inputBuffer[i + 1] & 0x0F) << 2)  
                                      | ((remain > 2) ? ((inputBuffer[i + 2] & 0xC0) >> 6) : 0)];  
      else   
         outputBuffer[j++] = '=';  
      
      if(remain > 2)  
         outputBuffer[j++] = alphabet[inputBuffer[i + 2] & 0x3F];  
      else  
         outputBuffer[j++] = '=';              
   }  
   
   outputBuffer[j] = 0;  

   NSString *result = [NSString stringWithUTF8String: (const char *)outputBuffer];  
   free(outputBuffer);  
   
   return result;  
}

+ (void) showMessage: (NSString *)msg  withTitle: (NSString *) title {
   dispatch_async(dispatch_get_main_queue(), ^{
      UIAlertView* dialog = [[UIAlertView alloc] init];
      [dialog setDelegate:self];
      [dialog setTitle: title];
      [dialog setMessage: msg]; 
      [dialog addButtonWithTitle:@"OK"];
      [dialog show];
   });
}

+ (void) showMessage: (NSString *)msg {
   [Toolbox showMessage:msg withTitle:@"Message"];
}


+ (void) moveView: (UIView*) view up: (int) delta {
   const float movementDuration = 0.3f;    
   [UIView beginAnimations: @"anim" context: nil];
   [UIView setAnimationBeginsFromCurrentState: YES];
   [UIView setAnimationDuration: movementDuration];
   view.frame = CGRectOffset(view.frame, 0, delta);
   [UIView commitAnimations];
}

+ (NSString *) capString:(NSString *)str maxLen:(int)maxLen {
   if ([str length] > maxLen) {
      str = [NSString stringWithFormat: @"%@...", [str substringToIndex: (maxLen-3)]];
   }
   return str;
}



+ (UIColor *) darker: (UIColor *) col by: (double) val {   
   CGColorRef color = col.CGColor; 
   unsigned long numComponents = CGColorGetNumberOfComponents(color);
   if (numComponents == 4)  {
      const CGFloat *components = CGColorGetComponents(color);
      CGFloat red = components[0];
      CGFloat green = components[1];
      CGFloat blue = components[2]; 
      CGFloat alpha = components[3];
      return [UIColor colorWithRed: (red*val) green:(green*val) blue:(blue*val) alpha:(alpha*val)];
   }
   return col;
}

@end
