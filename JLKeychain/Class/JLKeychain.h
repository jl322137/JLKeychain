//
//  JLKeychain.h
//  JLKeychain
//
//  Created by Aimy on 14/11/4.
//  Copyright (c) 2014年 Aimy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLKeychain : NSObject

/**
 *  best for these default objects,NSNumber,NSString,NSData,NSDate...,don`t set inherit Class
 *
 *  @param value
 *  @param type
 */
+ (void)setKeychainValue:(id<NSCopying, NSObject>)value forType:(NSString *)type;
/**
 *  get data from keychain with type
 *
 *  @param type NSString
 *
 *  @return value
 */
+ (id)getKeychainValueForType:(NSString *)type;
/**
 *  reset keychain data
 */
+ (void)reset;

@end
