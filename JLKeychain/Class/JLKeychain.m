//
//  JLKeychain.m
//  JLKeychain
//
//  Created by Aimy on 14/11/4.
//  Copyright (c) 2014年 Aimy. All rights reserved.
//

#import "JLKeychain.h"

#import "KeychainItemWrapper.h"

#define KEYCHAIN_IDENTITY @"KEYCHAIN_IDENTITY"

#define KEYCHAIN_GROUP @""

#define KEYCHAIN_DICT_ENCODE_KEY_VALUE @"KEYCHAIN_DICT_ENCODE_KEY_VALUE"

@interface JLKeychain ()

@property (nonatomic, strong) KeychainItemWrapper *otsItem;

@property (nonatomic, strong) NSArray *commonClasses;

@end

@implementation JLKeychain

+ (JLKeychain *)sharedInstance
{
    static dispatch_once_t once;
    static JLKeychain * singleton;
    dispatch_once(&once, ^{
        singleton = [[JLKeychain alloc] init];
    });
    
    return singleton;
}

- (id)init
{
    if (self = [super init]) {
        self.commonClasses = @[[NSNumber class],
                               [NSString class],
                               [NSMutableString class],
                               [NSData class],
                               [NSMutableData class],
                               [NSDate class],
                               [NSValue class]];
        
        [self setup];
    }
    return self;
}

- (void)setup
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_IDENTITY accessGroup:nil];
    self.otsItem = wrapper;
}

+ (void)setKeychainValue:(id<NSCopying, NSObject>)value forType:(NSString *)type
{
    JLKeychain *keychain = [JLKeychain sharedInstance];
    
    __block BOOL find = NO;
    [keychain.commonClasses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Class class = obj;
        if ([value isKindOfClass:class]) {
            find = YES;
            *stop = YES;
        }
        
    }];
    
    if (!find && value) {
        NSLog(@"error set keychain type [%@], value [%@]",type ,value);
        return ;
    }
    
    if (!type || !keychain.otsItem) {
        return ;
    }
    
    id data = [keychain.otsItem objectForKey:(__bridge id)kSecValueData];
    NSMutableDictionary *dict = nil;
    if (data && [data isKindOfClass:[NSMutableData class]]) {
        dict = [keychain decodeDictWithData:data];
    }
    
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    
    dict[type] = value;
    data = [keychain encodeDict:dict];
    
    if (data && [data isKindOfClass:[NSMutableData class]]) {
        [keychain.otsItem setObject:KEYCHAIN_IDENTITY forKey:(__bridge id)(kSecAttrAccount)];
        [keychain.otsItem setObject:data forKey:(__bridge id)kSecValueData];
    }
}

+ (id)getKeychainValueForType:(NSString *)type
{
    JLKeychain *keychain = [JLKeychain sharedInstance];
    if (!type || !keychain.otsItem) {
        return nil;
    }
    
    id data = [keychain.otsItem objectForKey:(__bridge id)kSecValueData];
    NSMutableDictionary *dict = nil;
    if (data && [data isKindOfClass:[NSMutableData class]]) {
        dict = [keychain decodeDictWithData:data];
    }
    
    return dict[type];
}

+ (void)reset
{
    JLKeychain *keychain = [JLKeychain sharedInstance];
    if (!keychain.otsItem) {
        return ;
    }
    
    id data = [keychain encodeDict:[NSMutableDictionary dictionary]];
    
    if (data && [data isKindOfClass:[NSMutableData class]]) {
        [keychain.otsItem setObject:KEYCHAIN_IDENTITY forKey:(__bridge id)(kSecAttrAccount)];
        [keychain.otsItem setObject:data forKey:(__bridge id)kSecValueData];
    }
}

- (NSMutableData *)encodeDict:(NSMutableDictionary *)dict
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dict forKey:KEYCHAIN_DICT_ENCODE_KEY_VALUE];
    [archiver finishEncoding];
    return data;
}

- (NSMutableDictionary *)decodeDictWithData:(NSMutableData *)data
{
    NSMutableDictionary *dict = nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    if ([unarchiver containsValueForKey:KEYCHAIN_DICT_ENCODE_KEY_VALUE]) {
        @try {
            dict = [unarchiver decodeObjectForKey:KEYCHAIN_DICT_ENCODE_KEY_VALUE];
        }
        @catch (NSException *exception) {
            NSLog(@"keychain decode error, maybe contain some object didn`t in this project, so reset");
            [JLKeychain reset];
        }
    }
    [unarchiver finishDecoding];
    
    return dict;
}

@end
