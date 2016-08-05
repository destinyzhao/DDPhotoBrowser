//
//  DDImageCache.h
//  DDPhotoBrowser
//
//  Created by Alex on 16/8/5.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^DownLoadCompleteBlock)(void);

@interface DDImageCache : NSObject

@property (copy, nonatomic) DownLoadCompleteBlock downLoadCompleteBlock;

/**
 *  判断是否有缓存
 *
 *  @param imgUrl 图片URL地址
 *
 *  @return YES OR NO
 */
+ (BOOL )isImageCache:(NSString *)imgUrl;

/**
 *  获取缓存图片
 *
 *  @param imageUrl 图片URL地址
 *
 *  @return 缓存图片
 */
+ (UIImage *)getCacheImage:(NSString *)imageUrl;

/**
 *  下载图片
 *
 *  @param imageUrl 图片URL地址
 *
 *  @return 图片
 */
+ (UIImage *)downLoadImage:(NSString *)imageUrl complete:(DownLoadCompleteBlock)complete;


@end
