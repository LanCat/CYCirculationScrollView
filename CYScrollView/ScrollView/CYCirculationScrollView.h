//
//  CYCirculationScrollView.h
//  CYCirculationScrollView
//
//  Created by yenge on 16/9/14.
//  Copyright © 2016年 yenge. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    CYOffetCenter,
    CYOffetLeft,
    CYOffetRight,
} CYOffetDirection;


@protocol CYCirculationScrollViewDelegate <NSObject>

@optional

- (void)cy_scrollerViewDidClicked:(NSUInteger)index;

- (void)cy_scrollViewDidScroll:(UIScrollView * _Nonnull)scrollView;

- (void)cy_scrollViewDidEndDecelerating:(UIScrollView *_Nonnull)scrollView;

- (void)cy_scrollViewWillBeginDragging:(UIScrollView *_Nonnull)scrollView;

- (void)cy_scrollViewDidEndDragging:(UIScrollView *_Nonnull)scrollView willDecelerate:(BOOL)decelerate;

@end


@interface CYCirculationScrollView : UIView

/**
 *  @author Yenge, 16-09-13 22:09:33
 *
 *  pageControl 当前page
 *
 *  @since <#1.0#>
 */
@property (nonatomic,readonly) NSInteger currentPage;

/**
 *  @author Yenge, 16-09-13 22:09:54
 *
 *  封装了scrollView的delegate方法，提供给需要用到的场景
 *
 *  @since <#1.0#>
 */
@property (nonatomic, weak) id <CYCirculationScrollViewDelegate> scrollDelegate;

@property(nullable, nonatomic,strong) UIColor *pageIndicatorBorderColor;

@property (nonatomic, assign) UIViewContentMode imageContentMode;

@property (nonatomic, assign) BOOL unScrollWhenSinglePage; //单张图片是否滚动。默认不播放
@property (nonatomic, assign) BOOL autoScroll;//是否自动播放
@property (nonatomic, assign) BOOL repeat;//是否循坏播放
/**
 *  通过需要显示的图片就行初始化
 *
 *  @param imageNames 图片地址
 *  @param repeat     是否需要自动轮播
 *  @param autoScroll 自动滚动
 */
- (_Nonnull instancetype)initWithImageNames:( NSArray<NSString *> *_Nonnull)imageNames autoScroll:(BOOL)autoScroll repeat:(BOOL)repeat;

//刷新图片
- (void)reloadImages:(NSArray *_Nonnull)imageNames;

//pagecontrol Y方向上的偏移量 默认为距离底部20像素
- (void)setPageControlOffetY:(CGFloat)y;

//pagecontrol X方向上的偏移量 默认 水平居中
- (void)setPageControlOffetX:(CGFloat)x forDirection:(CYOffetDirection)direction;

- (void)setPageControlPageIndicatorTintColor:( UIColor * _Nonnull )color;

- (void)setPageControlCurrentPageIndicatorTintColor:(UIColor *_Nonnull)color;



@end
