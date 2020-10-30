//
//  SHAHasher.m
//  WordPressKit
//
//  Created by Declan McKenna on 20/10/2020.
//  Copyright © 2020 Automattic Inc. All rights reserved.
//
#import "SHAHasher.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
@implementation SHAHasher

+ (NSString *)combineHashes:(NSArray<NSData *>*) hashArray
{
    NSMutableData *mutableData = [NSMutableData data];
    for (NSData *hash in hashArray) {
        [mutableData appendData:hash];
    }

    unsigned char finalDigest[CC_SHA256_DIGEST_LENGTH];

    CC_SHA256(mutableData.bytes, (CC_LONG)mutableData.length, finalDigest);

    return [self hexStringFromData:[NSData dataWithBytes:finalDigest length:CC_SHA256_DIGEST_LENGTH]];
}

+ (NSData *)hashForStringArray:(NSArray *) array {
    NSString *joinedArrayString = [array componentsJoinedByString:@""];
    return [self hashForString:joinedArrayString];
}

+ (NSData *)hashForString:(NSString *) string {
    if (!string) {
        return [[NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH] copy];
    }

    NSData *encodedBytes = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];

    CC_SHA256(encodedBytes.bytes, (CC_LONG)encodedBytes.length, digest);

    return [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

+ (NSData *)hashForNSInteger:(NSInteger)integer {
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];

    CC_SHA256(&integer, sizeof(integer), digest);

    return [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

+ (NSData *)hashForDouble:(double)dbl {
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];

    CC_SHA256(&dbl, sizeof(dbl), digest);

    return [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

+ (NSData *)hashForBool:(BOOL)boolean {
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];

    CC_SHA256(&boolean, sizeof(boolean), digest);

    return [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}

+ (NSString *)hexStringFromData:(NSData *)data {
    NSMutableString *mutableString = [NSMutableString string];

    const char *hashBytes = [data bytes];

    for (int i = 0; i < data.length; i++) {
        [mutableString appendFormat:@"%02.2hhx", hashBytes[i]];
    }

    return [mutableString copy];
}

@end
