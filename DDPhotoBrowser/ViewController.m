//
//  ViewController.m
//  DDPhotoBrowser
//
//  Created by Alex on 16/8/5.
//  Copyright © 2016年 Alex. All rights reserved.
//

#import "ViewController.h"
#import "PhotoCollectionCell.h"
#import "DDPhotoBrowser.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *imageUrlArray;

@end

@implementation ViewController

- (NSMutableArray *)imageUrlArray
{
    if (!_imageUrlArray) {
        _imageUrlArray = [NSMutableArray array];
    }
    return _imageUrlArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupCollectionView];
    [self getWebImages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 初始化CollectionView
- (void)setupCollectionView
{
    CGFloat collectionViewWidth = [[UIScreen mainScreen] bounds].size.width;
    // 间距
    CGFloat spacing = 5;
    // 列数
    CGFloat column = 2;
    // 单元格宽度
    CGFloat cellWidth = (collectionViewWidth - (column+1)*spacing)/column;
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    self.collectionView.collectionViewLayout = layout;
    // 垂直滚动
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    // 水平间隔
    layout.minimumLineSpacing = spacing;
    // 垂直间距
    layout.minimumInteritemSpacing = spacing;
    // 设置单元格Size
    layout.itemSize = CGSizeMake(cellWidth, cellWidth);
    // 设置单元格EdgeInsets
    layout.sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
}

#pragma mark - 
#pragma mark - CollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageUrlArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PhotoCollectionCell";
    PhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_imageUrlArray[indexPath.row]]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionCell *cell = (PhotoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
     [DDPhotoBrowser showFromImageView:cell.imageView withURLStrings:_imageUrlArray placeholderImage:[UIImage imageNamed:@"placeholder"] atIndex:indexPath.row dismiss:nil];
}

#pragma mark -
#pragma mark - 获取数据
- (void)getWebImages {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:@"http://api.tietuku.cn/v2/api/getrandrec?key=bJiYx5aWk5vInZRjl2nHxmiZx5VnlpZkapRuY5RnaGyZmsqcw5NmlsObmGiXYpU="];
    
    NSURLRequest *repuest = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:repuest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSMutableArray *urlS = [NSMutableArray array];
        for (NSDictionary *dict in result) {
            NSString *linkurl = dict[@"linkurl"];
            
            [urlS addObject:linkurl];
        }
        self.imageUrlArray = urlS;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.collectionView reloadData];
        });
        
    }];
    [task resume];
}


@end
