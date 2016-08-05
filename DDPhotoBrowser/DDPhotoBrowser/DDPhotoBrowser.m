//
//  DDPhotoBrowser.m
//  DDPhotoBrowser
//
//  Created by Alex on 16/8/5.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import "DDPhotoBrowser.h"
#import "DDPhotoBrowserCell.h"
#import "DDImageCache.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kScreenRect [UIScreen mainScreen].bounds
#define kScreenRatio kScreenWidth / kScreenHeight
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface DDPhotoBrowser ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
/**
 *  CollectionView
 */
@property (nonatomic, strong) UICollectionView *collectionView;
/**
 *  当前显示ImageView
 */
@property (nonatomic, strong) UIImageView *currentShowImageView;
/**
 *  零时显示当前图片（动画结束后移除）
 */
@property (nonatomic, strong) UIImageView *tmpImageView;
/**
 *  图片链接数组
 */
@property (nonatomic, strong) NSArray *imageUrlArray;
/**
 *  图片总数
 */
@property (nonatomic, assign) NSInteger imagesCount;
/**
 *  当前page
 */
@property (nonatomic, assign) NSInteger currentPage;
/**
 *  显示当前page和总page
 */
@property (nonatomic, strong) UILabel *countLab;
/**
 *  当前index
 */
@property (nonatomic, assign) NSInteger currentIndex;
/**
 *  endTempFrame
 */
@property (nonatomic, assign) CGRect endTempFrame;
/**
 *  图片是否下载完成
 */
@property (nonatomic, assign) BOOL imageDidLoaded;
/**
 *  动画是否完成
 */
@property (nonatomic, assign) BOOL animationCompleted;
/**
 *  加载图片
 */
@property (nonatomic, strong) UIImage *placeholderImage;
/**
 *  booBar View
 */
@property (nonatomic, strong) UIView *toolBar;
/**
 *  记录缩放indexPath
 */
@property (nonatomic, strong) NSIndexPath *zoomingIndexPath;
/**
 *  Block
 */
@property (nonatomic, copy) DismissBlock dismissDlock;

@end

@implementation DDPhotoBrowser

#pragma mark -
#pragma mark - 懒加载CollectionView
- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        // 水平滚动
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.hidden = YES;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

#pragma mark -
#pragma mark - 初始化
- (void)configureBrowser {
    
    self.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self addSubview:self.collectionView];
    
    [self setupToolBar];
    [self registerNotification];
    
    [self.collectionView registerClass:[DDPhotoBrowserCell class] forCellWithReuseIdentifier:kPhotoBrowserCellID];
}

#pragma mark -
#pragma mark - 注册通知
- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadForScreenRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureBrowser];
    }
    return self;
}

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
+ (instancetype)showFromImageView:(UIImageView *)imageView withURLStrings:(NSArray *)URLStrings placeholderImage:(UIImage *)placeholderImage atIndex:(NSInteger)index dismiss:(DismissBlock)block {
   
    DDPhotoBrowser *browser = [[DDPhotoBrowser alloc] initWithFrame:kScreenRect];
    browser.currentShowImageView = imageView;
    browser.imageUrlArray = URLStrings;
    browser.imagesCount = URLStrings.count;
    browser.placeholderImage = placeholderImage;
    browser.dismissDlock = block;
    
    [browser resetCountLabWithIndex:index+1];
    [browser animateImageViewAtIndex:index];
    
    return browser;
}

#pragma mark -
#pragma mark - 设置当前Page和总Page
- (void)resetCountLabWithIndex:(NSInteger)index {
    
    NSString *text = [NSString stringWithFormat:@"%zd%zd",_imagesCount,_imagesCount];
    CGFloat width = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}].width+8;
    _countLab.frame = CGRectMake(8, 1, MAX(50, width), 28);
    _countLab.text = [NSString stringWithFormat:@"%zd/%zd",index,_imagesCount];
}

#pragma mark -
#pragma mark - 动画显示和移除
- (void)animateImageViewAtIndex:(NSInteger)index {
    _currentIndex = index;
    
    // 获取当前点击图片的frame
    CGRect startFrame = [self.currentShowImageView.superview convertRect:self.currentShowImageView.frame toView:[UIApplication sharedApplication].keyWindow];
    CGRect endFrame = kScreenRect;
    
    if (self.currentShowImageView.image) {
        UIImage *image = self.currentShowImageView.image;
        // 获取图片比例
        CGFloat ratio = image.size.width / image.size.height;
        // 如果图片比例大于当前屏幕的比例
        if (ratio > kScreenRatio) {
            
            endFrame.size.width = kScreenWidth;
            endFrame.size.height = kScreenWidth / ratio;
            
        }
        else {
            endFrame.size.height = kScreenHeight;
            endFrame.size.width = kScreenHeight * ratio;
            
        }
        endFrame.origin.x = (kScreenWidth - endFrame.size.width) / 2;
        endFrame.origin.y = (kScreenHeight - endFrame.size.height) / 2;
        
    }
    
    _endTempFrame = endFrame;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:startFrame];
    tempImageView.image = self.currentShowImageView.image;
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    [[UIApplication sharedApplication].keyWindow addSubview:tempImageView];
    _tmpImageView = tempImageView;
    
    if (self.imageUrlArray) {
        
        NSString *urlKey = self.imageUrlArray[_currentIndex];
        UIImage *image = nil;
        // 有缓存取缓存图片
        if ([DDImageCache isImageCache:urlKey]) {
            image = [DDImageCache getCacheImage:urlKey];
        }
        else
        {
            // 没完成下载图片
            image = [DDImageCache downLoadImage:urlKey complete:^{
                _imageDidLoaded = YES;
            }];
        }
    
    }
    [self.collectionView setContentOffset:CGPointMake(kScreenWidth * index,0) animated:NO];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        tempImageView.frame = endFrame;
        
    } completion:^(BOOL finished) {
        _currentPage = index;
        _animationCompleted = YES;
        if (_imageDidLoaded) {
            self.collectionView.hidden = NO;
            [tempImageView removeFromSuperview];
            _animationCompleted = NO;
        }
        
    }];
    
}

#pragma mark - 
#pragma mark - 安装 ToolBar
- (void)setupToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-38, self.frame.size.width, 30)];
    _toolBar.backgroundColor = [UIColor clearColor];
    [self addSubview:_toolBar];
    
    UILabel *countLab = [[UILabel alloc] init];
    countLab.textColor = [UIColor whiteColor];
    countLab.layer.cornerRadius = 2;
    countLab.layer.masksToBounds = YES;
    countLab.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];
    countLab.font = [UIFont systemFontOfSize:13];
    countLab.textAlignment = NSTextAlignmentCenter;
    [_toolBar addSubview:countLab];
    _countLab = countLab;
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(_toolBar.frame.size.width-58, 1, 50, 28);
    saveBtn.layer.cornerRadius = 2;
    [saveBtn setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.4]];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    //[saveBtn addTarget:self action:@selector(saveImae) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:saveBtn];
    
}

#pragma mark -
#pragma mark - dismiss
- (void)dismiss {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    if (self.dismissDlock) {
        DDPhotoBrowserCell *cell = (DDPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage inSection:0]];
        self.dismissDlock(cell.imageView.image, _currentPage);
    }
    
    if (_currentPage != _currentIndex) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
        }];
        return;
    }
    
    CGRect endFrame = [self.currentShowImageView.superview convertRect:self.currentShowImageView.frame toView:[UIApplication sharedApplication].keyWindow];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:_endTempFrame];
    tempImageView.image = self.currentShowImageView.image;
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.collectionView.hidden = YES;
    
    [[UIApplication sharedApplication].keyWindow addSubview:tempImageView];
    
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        tempImageView.frame = endFrame;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        [tempImageView removeFromSuperview];
        
    }];
    
}

#pragma mark -
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _imageUrlArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoBrowserCellID forIndexPath:indexPath];
    cell.indexPath = indexPath;
    [cell resetZoomingScale];
    __weak __typeof(self) wself = self;
    cell.tapActionBlock = ^(UITapGestureRecognizer *sender) {
        [wself dismiss];
    };
    if (self.imageUrlArray) {
        NSURL *url = [NSURL URLWithString:self.imageUrlArray[indexPath.row]];
        if (indexPath.row != _currentIndex) {
            [cell.imageView sd_setImageWithURL:url placeholderImage:_placeholderImage];
        }
        else {
            
            UIImage *placeHolder = _tmpImageView.image;
            [cell.imageView sd_setImageWithURL:url placeholderImage:placeHolder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!_imageDidLoaded) {
                    _imageDidLoaded = YES;
                    if (_animationCompleted) {
                        self.collectionView.hidden = NO;
                        [_tmpImageView removeFromSuperview];
                        _animationCompleted = NO;
                    }
                    
                }
            }];
        }
    }
   
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return kScreenRect.size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _currentPage = scrollView.contentOffset.x/kScreenWidth + 0.5;
    _countLab.text = [NSString stringWithFormat:@"%zd/%zd",_currentPage+1,_imagesCount];
    
    if (_zoomingIndexPath) {
        [self.collectionView reloadItemsAtIndexPaths:@[_zoomingIndexPath]];
        _zoomingIndexPath = nil;
    }
    
}

#pragma mark - 
#pragma mark - 屏幕变化通知
- (void)reloadForScreenRotate {
    _collectionView.frame = kScreenRect;
    
    [self.collectionView reloadData];
    self.collectionView.contentOffset = CGPointMake(kScreenWidth * _currentPage,0);
}

#pragma mark -
#pragma mark - cell 缩放通知
- (void)photoCellDidZooming:(NSNotification *)nofit {
    NSIndexPath *indexPath = nofit.object;
    _zoomingIndexPath = indexPath;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
