//
//  DDPhotoBrowserCell.h
//  DDPhotoBrowser
//
//  Created by Alex on 16/8/5.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPhotoBrowserCellID @"DDPhotoBrowserCell"

typedef void(^TapActionBlock)(UITapGestureRecognizer *tapGesture);

static NSString * const kPhotoCellDidZommingNotification = @"kPhotoCellDidZommingNotification";
static NSString * const kPhotoCellDidImageLoadedNotification = @"kPhotoCellDidImageLoadedNotification";

@interface DDPhotoBrowserCell : UICollectionViewCell

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, copy) TapActionBlock tapActionBlock;

- (void)resetZoomingScale;

@end
