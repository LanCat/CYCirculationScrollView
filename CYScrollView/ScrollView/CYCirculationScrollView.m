//
//  CYCirculationScrollView.m
//  CYCirculationScrollView
//
//  Created by yenge on 16/9/14.
//  Copyright © 2016年 yenge. All rights reserved.
//

#import "CYCirculationScrollView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface CYCirculationScrollView ()<UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) BOOL didAddImages;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *imageNames;
@end

@implementation CYCirculationScrollView
- (void) dealloc {
    [_timer invalidate];
}

#pragma public methods
- (instancetype)initWithImageNames:(NSArray<NSString *> *)imageNames isRepeatPlay:(BOOL)repeat {
    if (self = [super init]) {
        if (imageNames.count > 0) {
            _imageNames = [NSMutableArray arrayWithArray:imageNames];
            NSString *tempImageName = [imageNames firstObject];
            [_imageNames addObject:tempImageName];
            tempImageName = [imageNames lastObject];
            [_imageNames insertObject:tempImageName atIndex:0];
        }
        _repeat = repeat;
        _currentPage = 1;
    }
    return self;
}

- (void)reloadImages:(NSArray *)imageNames {
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (imageNames.count > 0) {
        _imageNames = [NSMutableArray arrayWithArray:imageNames];
        NSString *tempImageName = [imageNames firstObject];
        [_imageNames addObject:tempImageName];
        tempImageName = [imageNames lastObject];
        [_imageNames insertObject:tempImageName atIndex:0];
    }
    _currentPage = 1;
    _didAddImages = NO;
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //判断是否已经有frame，有了才进行布局
    if (self.frame.size.width > 0 && !self.didAddImages) {
        [self layoutImages];
        [self layouPageControl];
        self.didAddImages = YES;
        if (_repeat) {
            [self start];
        }
    }
}

- (void)layouPageControl {
    _pageControl = [[UIPageControl alloc]init];
    _pageControl.numberOfPages = _imageNames.count - 2;
    _pageControl.currentPage = 0;
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:_pageControl];
    CGFloat bottom = self.bounds.size.height * 0.2;
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-bottom));
        make.centerX.equalTo(self.mas_centerX);
    }];
}

#pragma mark - layoutSubviews
- (void)layoutImages {
    _scrollView = [UIScrollView new];
    [self addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    for (NSInteger i = 0; i < [_imageNames count]; i ++) {
        
        NSString *imageName = [_imageNames objectAtIndex:i];
        UIImageView *imageView;
        
        if ([imageName hasPrefix:@"http://"] || [imageName hasPrefix:@"https://"]) {
            imageView = [[UIImageView alloc]init];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageName]];
        }else {
            imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        }
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        [_scrollView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(i * self.bounds.size.width));
            make.top.equalTo(@0);
            make.width.equalTo(self.mas_width);
            make.height.equalTo(self.mas_height);
        }];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollerViewDidClicked:)];
        [imageView addGestureRecognizer:tapGesture];
    }
    
    [_scrollView setContentSize:CGSizeMake(_imageNames.count * self.bounds.size.width, self.frame.size.height)
     ];
    [_scrollView setContentOffset:CGPointMake(self.frame.size.width, self.frame.size.height)];
}

#pragma mark- auto scroll
- (void)start {
    _timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(startScroll) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stop {
    [_timer invalidate];
    _timer = nil;
}

- (void)startScroll {
    _currentPage ++;
    if (_currentPage == [_imageNames count] - 1) {
        _currentPage = 1;
        [_scrollView scrollRectToVisible:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) animated:NO];
    }else {
        [_scrollView scrollRectToVisible:CGRectMake(self.frame.size.width * _currentPage, 0, self.frame.size.width, self.frame.size.height) animated:YES];
    }
}

#pragma mark- UIScrollViewDelegate
- (void)scrollerViewDidClicked:(UITapGestureRecognizer *)tapGesture{
    UIImageView *imageView = (UIImageView *)tapGesture.view;
    if ([self.scrollDelegate respondsToSelector:@selector(cy_scrollerViewDidClicked:)]) {
        NSLog(@"images did clicked at index: %zd",imageView.tag);
        [self.scrollDelegate cy_scrollerViewDidClicked:imageView.tag];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.currentPage = floor(scrollView.contentOffset.x /self.frame.size.width);
    self.pageControl.currentPage = floor(self.currentPage-1);
    
    if ([self.scrollDelegate respondsToSelector:@selector(cy_scrollViewDidScroll:)]) {
        [self.scrollDelegate cy_scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_currentPage == 0) {
        [scrollView setContentOffset:CGPointMake((_imageNames.count - 2) * self.frame.size.width, 0)];
    }
    if(_currentPage == [_imageNames count] - 1){
        [scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
    }
    if ([self.scrollDelegate respondsToSelector:@selector(cy_scrollViewDidEndDecelerating:)]) {
        [self.scrollDelegate cy_scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stop];
    if ([self.scrollDelegate respondsToSelector:@selector(cy_scrollViewWillBeginDragging:)]) {
        [self.scrollDelegate cy_scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self start];
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewDidEndDragging: willDecelerate:)]) {
        [self.scrollDelegate cy_scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}
@end
