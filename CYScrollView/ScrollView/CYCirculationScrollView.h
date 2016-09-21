//
//  CYCirculationScrollView.h
//  CYCirculationScrollView
//
//  Created by yenge on 16/9/14.
//  Copyright © 2016年 yenge. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CYCirculationScrollViewDelegate <NSObject>

@optional

- (void)cy_scrollerViewDidClicked:(NSUInteger)index;

- (void)cy_scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)cy_scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)cy_scrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)cy_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

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
@property (nonatomic, weak) id<CYCirculationScrollViewDelegate> scrollDelegate;

/**
 *  通过需要显示的图片就行初始化
 *
 *  @param imageNames
 *  @param repeat     是否需要自动轮播
 *
 *  @return
 */
- (instancetype)initWithImageNames:(NSArray<NSString *> *)imageNames isRepeatPlay:(BOOL)repeat;
@end
