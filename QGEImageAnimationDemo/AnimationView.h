//
//  AnimationView.h
//  QGEImageAnimationDemo
//
//  Created by wei1 on 2017/6/4.
//  Copyright © 2017年 qge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AnimationView;


@protocol AnimationViewDataSource <NSObject>
//设置加载的图片
-(NSArray<UIImage *> *)loadImagesInAnimationView:(AnimationView *)animationView;
//置位图片
-(UIImage *)setAddImageImageInAnimationView:(AnimationView *)animationView;
//设置拖动图片的大小
-(NSInteger)panImageVWHInAnimationView:(AnimationView *)animationView;

@end

@protocol AnimationViewDelegate<NSObject>
@optional
-(void)animationView:(AnimationView *)animationView didSelectExistImage:(UIImage *)image index:(NSInteger)index;

-(void)animationView:(AnimationView *)animationView didSelectUnExistImage:(UIImage *)image;

-(void)animationView:(AnimationView *)animationView didChangeImages:(NSArray<UIImage *> *)image;

@end

@interface AnimationView : UIView

@property(weak,nonatomic) id<AnimationViewDataSource> dataSource;

@property(weak,nonatomic) id<AnimationViewDelegate> delegate;
//重新加载数据
-(void)reloadAnimationView;
//删除图片
-(void)deleteImageAtIndex:(NSInteger)index;

@end



