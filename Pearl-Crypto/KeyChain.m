//
//  CryptUtils.m
//  Pearl
//
//  Created by Maarten Billemont on 05/11/09.
//  Copyright 2009, lhunath (Maarten Billemont). All rights reserved.
//
//  See http://www.cocoadev.com/index.pl?BaseSixtyFour

#import <CommonCrypto/CommonHMAC.h>

#import "KeyChain.h"
#import "CryptUtils.h"
#import "Logger.h"


@implementation NSString (KeyChain)

- (NSData *)signWithAssymetricKeyChainKeyFromTag:(NSString *)tag {
    
    return [[self dataUsingEncoding:NSUTF8StringEncoding] signWithAssymetricKeyChainKeyFromTag:tag];
}

- (NSData *)signWithAssymetricKeyChainKeyFromTag:(NSString *)tag usePadding:(SecPadding)padding {
    
    return [[self dataUsingEncoding:NSUTF8StringEncoding] signWithAssymetricKeyChainKeyFromTag:tag usePadding:padding];
}

@end

@implementation NSData (KeyChain)

- (NSData *)signWithAssymetricKeyChainKeyFromTag:(NSString *)tag {
    
    switch ([self length]) {
        case 16:
            return [self signWithAssymetricKeyChainKeyFromTag:tag usePadding:kSecPaddingPKCS1MD5];
        case 20:
            return [self signWithAssymetricKeyChainKeyFromTag:tag usePadding:kSecPaddingPKCS1SHA1];
        default:
            return [self signWithAssymetricKeyChainKeyFromTag:tag usePadding:kSecPaddingPKCS1];
    }
}

- (NSData *)signWithAssymetricKeyChainKeyFromTag:(NSString *)tag usePadding:(SecPadding)padding {
    
    NSDictionary *queryAttr     = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (id)kSecClassKey,                (id)kSecClass,
                                   [[NSString stringWithFormat:@"%@-priv", tag] dataUsingEncoding:NSUTF8StringEncoding],
                                   (id)kSecAttrApplicationTag,
                                   (id)kSecAttrKeyTypeRSA,          (id)kSecAttrKeyType,
                                   (id)kCFBooleanTrue,              (id)kSecReturnRef,
                                   nil];
    
    SecKeyRef privateKey = nil;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)queryAttr, (CFTypeRef *) &privateKey);
    if (status != errSecSuccess || privateKey == nil) {
        err(@"Problem during key lookup; status == %d.", status);
        return nil;
    }
    
    
    // Malloc a buffer to hold signature.
    size_t signedHashBytesSize  = SecKeyGetBlockSize(privateKey);
    uint8_t *signedHashBytes    = calloc( signedHashBytesSize, sizeof(uint8_t) );
    
    // Sign the SHA1 hash.
    status = SecKeyRawSign(privateKey, padding,
                           self.bytes, self.length,
                           signedHashBytes, &signedHashBytesSize);
    CFRelease(privateKey);
    if (status != errSecSuccess) {
        err(@"Problem during data signing; status == %d.", status);
        return nil;
    }
    
    // Build up signed SHA1 blob.
    NSData *signedData = [NSData dataWithBytes:signedHashBytes length:signedHashBytesSize];
    if (signedHashBytes)
        free(signedHashBytes);
    
    return signedData;
}

@end

@implementation KeyChain

+ (OSStatus)addOrUpdateItemForQuery:(NSDictionary *)query withAttributes:(NSDictionary *)attributes {
    
    OSStatus resultCode;
    if (SecItemCopyMatching((CFDictionaryRef)query, NULL) == noErr)
        resultCode = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)attributes);
    
    else {
        NSMutableDictionary *newItem = [[query mutableCopy] autorelease];
        [newItem addEntriesFromDictionary:attributes];
        
        resultCode = SecItemAdd((CFDictionaryRef)newItem, NULL);
    }
    
    if (resultCode != noErr)
        err(@"While adding or updating keychain item: %@ with attributes: %@, error occured: %d", query, attributes, resultCode);
    return resultCode;
}

+ (OSStatus)findItemForQuery:(NSDictionary *)query into:(id*)result {
    
    return SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)result);
}

+ (NSDictionary *)createQueryForClass:(CFTypeRef)kSecClassValue
                           attributes:(NSDictionary *)kSecAttrDictionary
                              matches:(NSDictionary *)kSecMatchDictionary {
    
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObject:kSecClassValue forKey:kSecClass];
    [query addEntriesFromDictionary:kSecAttrDictionary];
    [query addEntriesFromDictionary:kSecMatchDictionary];
    
    return query;
}

+ (id)runQuery:(NSDictionary *)query returnType:(CFTypeRef)kSecReturn {
    
    NSMutableDictionary *dataQuery = [query mutableCopy];
    [dataQuery setObject:[NSNumber numberWithBool:YES] forKey:kSecReturn];
    
    id result = nil;
    OSStatus resultCode;
    if ((resultCode = [self findItemForQuery:dataQuery into:&result]) != noErr)
        err(@"While querying keychain for: %@, error occured: %d", dataQuery, resultCode);
    
    return result;
}

+ (id)itemForQuery:(NSDictionary *)query {
    
    return [self runQuery:query returnType:kSecReturnRef];
}

+ (NSData *)persistentItemForQuery:(NSDictionary *)query {
    
    return (NSData *)[self runQuery:query returnType:kSecReturnPersistentRef];
}

+ (NSDictionary *)attributesOfItemForQuery:(NSDictionary *)query {
    
    return (NSDictionary *)[self runQuery:query returnType:kSecReturnAttributes];
}

+ (NSData *)dataOfItemForQuery:(NSDictionary *)query {
    
    return (NSData *)[self runQuery:query returnType:kSecReturnData];
}

+ (BOOL)generateKeyPairWithTag:(NSString *)tag {
    
    NSDictionary *privKeyAttr   = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [[NSString stringWithFormat:@"%@-priv",  tag] dataUsingEncoding:NSUTF8StringEncoding],
                                   (id)kSecAttrApplicationTag,
                                   nil];
    NSDictionary *pubKeyAttr    = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [[NSString stringWithFormat:@"%@-pub",   tag] dataUsingEncoding:NSUTF8StringEncoding],
                                   (id)kSecAttrApplicationTag,
                                   nil];
    NSDictionary *keyPairAttr   = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (id)kSecAttrKeyTypeRSA,          (id)kSecAttrKeyType,
                                   [NSNumber numberWithInt:1024],   (id)kSecAttrKeySizeInBits,
                                   (id)kCFBooleanTrue,              (id)kSecAttrIsPermanent,
                                   privKeyAttr,                     (id)kSecPrivateKeyAttrs,
                                   pubKeyAttr,                      (id)kSecPublicKeyAttrs,
                                   nil];
    
    OSStatus status = SecKeyGeneratePair((CFDictionaryRef)keyPairAttr, nil, nil);
    if (status != errSecSuccess) {
        err(@"Problem during key generation; status == %d.", status);
        return NO;
    }
    
    return YES;
}

+ (NSData *)publicKeyWithTag:(NSString *)tag {
    
    NSData *publicKeyData = nil;
    NSDictionary *queryAttr     = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (id)kSecClassKey,                (id)kSecClass,
                                   [[NSString stringWithFormat:@"%@-pub",  tag] dataUsingEncoding:NSUTF8StringEncoding],
                                   (id)kSecAttrApplicationTag,
                                   (id)kSecAttrKeyTypeRSA,          (id)kSecAttrKeyType,
                                   (id)kCFBooleanTrue,              (id)kSecReturnData,
                                   nil];
    
    // Get the key bits.
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)queryAttr, (CFTypeRef *)&publicKeyData);
    if (status != errSecSuccess) {
        err(@"Problem during public key export; status == %d.", status);
        return nil;
    }
    
    [publicKeyData autorelease];
    return [CryptUtils derEncodeRSAKey:publicKeyData];
}

@end
