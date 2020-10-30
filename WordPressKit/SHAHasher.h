//
//  SHAHasher.h
//  WordPressKit
//
//  Created by Declan McKenna on 20/10/2020.
//  Copyright © 2020 Automattic Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface SHAHasher : NSObject
+ (NSString *)combineHashes:(NSArray<NSData *>*) hashArray;
+ (NSData *)hashForStringArray:(NSArray *) array;
+ (NSData *)hashForString:(NSString *) string;
+ (NSData *)hashForNSInteger:(NSInteger)integer;
+ (NSData *)hashForDouble:(double)dbl;
+ (NSData *)hashForBool:(BOOL)boolean;
+ (NSString *)hexStringFromData:(NSData *)data;
@end
