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

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSArray *originImages;

@property (assign) CGFloat pageControlOffsetCenterY;
@property (assign) CGFloat pageControlOffsetCenterX;
@property (assign) CYOffetDirection offectDirection;

@end

@implementation CYCirculationScrollView
- (void) dealloc {
    [_timer invalidate];
}

#pragma public methods
- (instancetype)initWithImageNames:(NSArray<NSString *> *)imageNames autoScroll:(BOOL)autoScroll repeat:(BOOL)repeat{
    if (self = [super init]) {
        _originImages = imageNames;
        _autoScroll = autoScroll;
        if (self.unScrollWhenSinglePage && imageNames.count == 1) {
            _autoScroll = NO;
        }
        _repeat = repeat;
        _currentPage = 1;
        self.pageControlOffsetCenterY = 0;
        self.pageControlOffsetCenterX = 0;
        [self createPageView:imageNames];
    }
    return self;
}

- (void)createPageView:(NSArray *)imageNames {
    
    if (imageNames.count == 0) {
        return;
    }
    if (!_scrollview) {
        self.scrollview = [UIScrollView new];
        [self addSubview:_scrollview];
        self.scrollview.showsHorizontalScrollIndicator = NO;
        self.scrollview.showsVerticalScrollIndicator = NO;
        self.scrollview.pagingEnabled = YES;
        self.scrollview.delegate = self;
    }
    
    
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = [UIColor clearColor];
        [_scrollview addSubview:_contentView];
    }
    
    NSMutableArray *imagesURLs = [imageNames mutableCopy];
    if (self.unScrollWhenSinglePage && imageNames.count == 1) {
        _autoScroll = NO;
    }
    if (imageNames.count == 1) {
        _repeat = NO;
    }
    if (_repeat && imageNames.count >= 1) {
        NSString *tempImageName = [imageNames firstObject];
        [imagesURLs addObject:tempImageName];
        tempImageName = [imageNames lastObject];
        [imagesURLs insertObject:tempImageName atIndex:0];
    }
    
    if (!_images) {
        _images = [NSMutableArray arrayWithCapacity:imagesURLs.count];
    }
    [_images removeAllObjects];
    for (NSInteger i = 0; i < [imagesURLs count]; i ++) {
        
        NSString *imageName = [imagesURLs objectAtIndex:i];
        UIImageView *imageView = [UIImageView new];
        
        if ([imageName hasPrefix:@"http://"] || [imageName hasPrefix:@"https://"]) {
            imageView = [[UIImageView alloc]init];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageName]];
        }else {
            imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        }
        [imageView setContentMode:self.imageContentMode];
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollerViewDidClicked:)];
        [imageView addGestureRecognizer:tapGesture];
        [_contentView addSubview:imageView];
        [_images addObject:imageView];
    }
    
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]init];
        [self addSubview:_pageControl];
    }
    _pageControl.numberOfPages = imageNames.count;
    _pageControl.currentPage = 1;
    _pageControl.hidesForSinglePage = YES;
    if (_autoScroll) {
        [self start];
    }else {
        [self stop];
    }
}

- (void)drawRect:(CGRect)rect {
    [self.pageControl.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.pageIndicatorBorderColor) {
            obj.layer.masksToBounds = YES;
            [obj.layer setBorderColor:self.pageIndicatorBorderColor.CGColor];
            [obj.layer setBorderWidth:1];
        }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_images.count) {
        return;
    }
    UIImageView *lastImageView = nil;
    for (UIImageView *imageView in _images) {
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (!lastImageView) {
                make.left.mas_equalTo(0);
            }else {
                make.left.mas_equalTo(lastImageView.mas_right);
            }
            make.top.equalTo(@0);
            make.width.equalTo(self.mas_width);
            make.height.equalTo(self.mas_height);
        }];
        lastImageView = imageView;
    }
    
    [_scrollview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
        make.right.equalTo(_contentView.mas_right);
        make.bottom.mas_equalTo(_contentView.mas_bottom);
    }];
    
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(self.pageControlOffsetCenterY - 20);
        switch (_offectDirection) {
            case CYOffetLeft:
                make.centerX.equalTo(self.mas_left).offset(self.pageControlOffsetCenterX).priorityHigh();
                break;
            case CYOffetRight:
                make.centerX.equalTo(self.mas_right).offset(self.pageControlOffsetCenterX).priorityHigh();
                break;
            case CYOffetCenter:
                make.centerX.equalTo(self.mas_centerX).offset(self.pageControlOffsetCenterX).priorityHigh();
                break;
            default:
                make.centerX.equalTo(self.mas_centerX);

                break;
        }
    }];
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_scrollview);
        make.right.mas_equalTo(lastImageView.mas_right);
        make.height.mas_equalTo(self.mas_height);
    }];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_scrollview.mas_bottom);
    }];
}

- (void)reloadImages:(NSArray *)imageNames {
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
    [_contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (imageNames.count > 0) {
        _originImages = imageNames;
        [self createPageView:imageNames];
        _currentPage = 1;
        [self setNeedsLayout];
        [self layoutIfNeeded];
        [self setNeedsDisplay];
    }
    
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
    if (_currentPage == [_images count] - 1) {
        _currentPage = 1;
        [self.scrollview scrollRectToVisible:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) animated:NO];
    }else {
        [self.scrollview scrollRectToVisible:CGRectMake(self.frame.size.width * _currentPage, 0, self.frame.size.width, self.frame.size.height) animated:YES];
    }
}

#pragma mark- UIScrollViewDelegate
- (void)scrollerViewDidClicked:(UITapGestureRecognizer *)tapGesture{
    UIImageView *imageView = (UIImageView *)tapGesture.view;
    if ([self.scrollDelegate respondsToSelector:@selector(cy_scrollerViewDidClicked:)]) {
        NSLog(@"images did clicked at index: %zd",imageView.tag);
        NSInteger index = 0;
        if (imageView.tag == 0) {
            index = _images.count - 1;
        }else if (imageView.tag == _images.count - 1) {
            index = 0;
        }else {
            index = imageView.tag -1;
        }
        [self.scrollDelegate cy_scrollerViewDidClicked:index];
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.currentPage = floor(scrollView.contentOffset.x /self.frame.size.width);
    self.pageControl.currentPage = _repeat ?floor(self.currentPage-1):self.currentPage;
    
    if ([self.scrollDelegate respondsToSelector:@selector(cy_scrollViewDidScroll:)]) {
        [self.scrollDelegate cy_scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_repeat) {
        if (_currentPage == 0) {
            [scrollView setContentOffset:CGPointMake((_images.count - 2) * self.frame.size.width, 0)];
        }
        if(_currentPage == [_images count] - 1){
            [scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
        }
    }
    if ([self.scrollDelegate respondsToSelector:@selector(cy_scrollViewDidEndDecelerating:)]) {
        [self.scrollDelegate cy_scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_autoScroll) {
        [self stop];
    }
    if ([self.scrollDelegate respondsToSelector:@selector(cy_scrollViewWillBeginDragging:)]) {
        [self.scrollDelegate cy_scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_autoScroll) {
        [self start];
    }
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewDidEndDragging: willDecelerate:)]) {
        [self.scrollDelegate cy_scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

#pragma mark- setter

- (void)setPageControlOffetX:(CGFloat)x forDirection:(CYOffetDirection)direction {
    self.pageControlOffsetCenterX = x;
    _offectDirection = direction;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setPageControlOffetY:(CGFloat)y {
    self.pageControlOffsetCenterY = y;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setPageControlPageIndicatorTintColor:(UIColor *)color {
    self.pageControl.pageIndicatorTintColor = color;
}

- (void)setPageControlCurrentPageIndicatorTintColor:(UIColor *)color {
    self.pageControl.currentPageIndicatorTintColor = color;
}

- (void)setUnScrollWhenSinglePage:(BOOL)unScrollWhenSinglePage {
    _unScrollWhenSinglePage = unScrollWhenSinglePage;
    [self reloadImages:_originImages];
}

- (void)setRepeat:(BOOL)repeat {
    _repeat = repeat;
    [self reloadImages:_originImages];
}

- (void)setImageContentMode:(UIViewContentMode)imageContentMode {
    _imageContentMode = imageContentMode;
    if (_images.count > 0) {
        [_images enumerateObjectsUsingBlock:^(UIImageView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.contentMode = imageContentMode;
        }];
    }
}
@end
