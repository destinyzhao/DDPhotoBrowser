//
//  DDPhotoBrowser.h
//  DDPhotoBrowser
//
//  Created by Alex on 16/8/5.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DismissBlock)(UIImage*image, NSInteger index);

@interface DDPhotoBrowser : UIView

/**
 *  显示PhotoBrowser
 *
 *  @param imageView        当前点击ImageView
 *  @param URLStrings       图片链接数组
 *  @param placeholderImage 加载中的图片
 *  @param index            当前图片在图片链接数组的Index
 *  @param block            回调
 *
 *  @return
 */
+ (instancetype)showFromImageView:(UIImageView *)imageView withURLStrings:(NSArray *)URLStrings placeholderImage:(UIImage *)placeholderImage atIndex:(NSInteger)index dismiss:(DismissBlock)block;

@end
