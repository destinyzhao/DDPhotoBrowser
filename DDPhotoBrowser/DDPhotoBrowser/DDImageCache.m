//
//  DDImageCache.m
//  DDPhotoBrowser
//
//  Created by Alex on 16/8/5.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import "DDImageCache.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>

@implementation DDImageCache

/**
 *  判断是否有缓存
 *
 *  @param imgUrl 图片URL地址
 *
 *  @return YES OR NO
 */
+ (BOOL)isImageCache:(NSString *)imgUrl
{
    SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
    
    // 判断默认图片是否有缓存图片
    if (![imageManager cachedImageExistsForURL:[NSURL URLWithString:imgUrl]])
    {
        return NO;
    }
    
    return YES;
}

/**
 *  获取缓存图片
 *
 *  @param imageUrl 图片URL地址
 *
 *  @return 缓存图片
 */
+ (UIImage *)getCacheImage:(NSString *)imageUrl
{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    return [imageCache imageFromDiskCacheForKey:imageUrl];
}

/**
 *  下载图片
 *
 *  @param imageUrl 图片URL地址
 *
 *  @return 图片
 */
+ (UIImage *)downLoadImage:(NSString *)imageUrl complete:(DownLoadCompleteBlock)complete
{

    DDImageCache *cache = [DDImageCache new];
    cache.downLoadCompleteBlock = complete;
    SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
    __block UIImage *dlownLoadImage = nil;
    // 没有缓存下载
    [imageManager downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        // 下载进度
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            dlownLoadImage = image;
        }
        
    }];
    
    return dlownLoadImage;
}


@end
