//
//  ZYImageCache.m
//  ZYAdLaunch
//
//  Created by zhaoyang on 2016/11/23.
//  Copyright © 2016年 zhaoyang. All rights reserved.
//

#import "ZYImageCache.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ZYImageCache

+ (UIImage *)zy_getCacheImageWithUrl:(NSURL *)url
{
    if (url == nil) return nil;
    
    NSString *path = [NSString stringWithFormat:@"%@%@",[self zy_cacheImagePath],[self zy_md5String:url.absoluteString]];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    return nil;
}


/**
 缓存图片

 @param data imageDta
 @param url 图片Url
 */
+ (void)zy_saveImageData:(NSData *)data imageUrl:(NSURL *)url
{
    //absoluteString完整的url字符串
    NSString *path = [NSString stringWithFormat:@"%@%@",[self zy_cacheImagePath],[self zy_md5String:url.absoluteString]];
    if (data) {
        BOOL isOk = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        if (!isOk) NSLog(@"cache file error for URL: %@", url);
    }
}

/**
 获取缓存路径

 @return 缓存路径
 */
+ (NSString *)zy_cacheImagePath
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/ZYLaunchAdCache"];
    [self zy_checkDirectory:path];
    return path;
}


/**
 检查目录

 @param path 需要被检查的路径
 */
+ (void)zy_checkDirectory:(NSString *)path
{
    // 创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    // 判断路径下面是否为文件夹
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        //如果不是文件夹
        [self zy_createBaseDirectoryAtPath:path];
    }else{
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self zy_createBaseDirectoryAtPath:path];
        }
    }
}

/**
 创建目录

 @param path 路径
 */
+ (void)zy_createBaseDirectoryAtPath:(NSString *)path
{
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager]createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"create cache directory failed, error = %@", error);
    }else{
        NSLog(@"ZYLaunchAdCachePath:%@",path);
        [self zy_addDoNotBackupAttribute:path];
    }
}


/**
 防止备份到iCloud和iTunes

 @param path 路径
 */
+ (void)zy_addDoNotBackupAttribute:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    //通过对设备上的文件设置该NSURLIsExcludedFromBackupKey属性，禁用该文件被iCloud备份
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        NSLog(@"error to set do not backup attribute, error = %@", error);
    }
}


/**
 对传入的String进行MD5

 @param string 原String
 @return MD5以后的String
 */
+ (NSString *)zy_md5String:(NSString *)string
{
    if (string == nil || [string length] == 0) return nil;
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}
























@end
