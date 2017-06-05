//
//  AnimationView.m
//  QGEImageAnimationDemo
//
//  Created by wei1 on 2017/6/4.
//  Copyright © 2017年 qge. All rights reserved.
//

#import "AnimationView.h"
#import "Masonry.h"


@interface AnimationView()

@property (nonatomic) UIImage *addImage;

@property (nonatomic)NSMutableArray<UIImage *> *images;

@property (nonatomic)NSInteger panImageWH;

@property (nonatomic)NSMutableArray<UIImageView *> *imageVs;
@property (nonatomic)NSInteger state;


@property (nonatomic) CGRect originFrame;
@property(nonatomic) NSMutableArray<NSValue *>* frames;

@end

@implementation AnimationView

-(NSMutableArray *)frames{
    if(_frames == nil){
        _frames = [NSMutableArray array];
    }
    return _frames;
}

-(NSMutableArray<UIImage *> *)images{
    if(_images == nil){
        _images = [NSMutableArray array];
    }
    return _images;
}

-(NSMutableArray<UIImageView *> *)imageVs{
    if(_imageVs == nil){
        _imageVs = [NSMutableArray array];
    }
    return _imageVs;

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        for(int i = 0;i<=5;i++){
            UIImageView *imageV = [[UIImageView alloc]init];
            imageV.userInteractionEnabled = YES;
            imageV.multipleTouchEnabled = NO;
            
            //添加增加/删除图片手势
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
            [imageV addGestureRecognizer:tap];
            
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panImage:)];
            
            [imageV addGestureRecognizer:pan];
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(panImage:)];
            
            
            
            [imageV addGestureRecognizer:longPress];
            
            [self.imageVs addObject:imageV];
            [self addSubview:imageV];
            
            _state = -1;
        }
    }
    return self;
}
#pragma mark 设置各imageView的frame
-(void)layoutSubviews{
    [super layoutSubviews];
    
    if(_state == -1){
        self.imageVs[0].frame = CGRectMake(0, 0, self.frame.size.width*2/3, self.frame.size.height*2/3);
        self.imageVs[1].frame = CGRectMake(self.frame.size.width*2/3, 0, self.frame.size.height*1/3, self.frame.size.height*1/3);
        self.imageVs[2].frame = CGRectMake(self.frame.size.width*2/3, self.frame.size.height*1/3, self.frame.size.width*1/3, self.frame.size.height*1/3);
        self.imageVs[3].frame = CGRectMake(self.frame.size.width*2/3, self.frame.size.height*2/3, self.frame.size.width*1/3, self.frame.size.height*1/3);
        self.imageVs[4].frame = CGRectMake(self.frame.size.width*1/3, self.frame.size.height*2/3, self.frame.size.width*1/3, self.frame.size.height*1/3);
        self.imageVs[5].frame = CGRectMake(0, self.frame.size.height*2/3, self.frame.size.width*1/3, self.frame.size.height*1/3);
        [self.imageVs enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.frames addObject:[NSValue valueWithCGRect:obj.frame]];
        }];
    }
    
    
    
}

#pragma mark 设置数据源时刷新数据

-(void)setDataSource:(id<AnimationViewDataSource>)dataSource{
    _dataSource = dataSource;
    [self reloadAnimationView];
}

#pragma mark 重新加载image

-(void)reloadAnimationView{
    self.addImage = [self.dataSource setAddImageImageInAnimationView:self];
    NSArray<UIImage *> *images = [self.dataSource loadImagesInAnimationView:self];
    self.images = [images mutableCopy];
    _state = self.images.count - 1;
    for(NSInteger i = 0;i<self.imageVs.count;i++){
        if(i<images.count){
            self.imageVs[i].image = images[i];
        }else{
            self.imageVs[i].image = self.addImage;
        }
        self.imageVs[i].tag = i;
    }
    self.panImageWH = [self.dataSource panImageVWHInAnimationView:self];
}


-(void)tapImage:(UITapGestureRecognizer *)sender{
    if(self.delegate){
        UIImageView *imageV = sender.view;
        NSInteger imageTag = imageV.tag;
        if (imageTag >_state){
            if([self.delegate respondsToSelector:@selector(animationView:didSelectUnExistImage:)]){
                [self.delegate animationView:self didSelectUnExistImage:imageV.image];
            }
        }else{
            if([self.delegate respondsToSelector:@selector(animationView:didSelectExistImage:index:)]){
                [self.delegate animationView:self didSelectExistImage:imageV.image index:imageTag];
            }
        }
    }
}

#pragma mark 平移手势+长按手势
-(void)panImage:(UIGestureRecognizer*)sender{
    UIImageView *imageV = sender.view;
    NSInteger imageTag = imageV.tag;
    if(imageTag>_state){
        return;
    }
    
    CGPoint touchPoint = [sender locationInView:self];
    
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            //记录拖动的view的原始frame
            self.originFrame = imageV.frame;
            //scale
            [UIView animateWithDuration:0.1 animations:^{
                imageV.frame = CGRectMake(touchPoint.x-self.panImageWH/2, touchPoint.y-self.panImageWH/2, self.panImageWH, self.panImageWH);
            }];
            
            for(UIImageView *imageView in _imageVs){
                if(imageView.tag!=imageTag){
                    imageView.userInteractionEnabled = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{
            imageV.frame = CGRectMake(touchPoint.x-self.panImageWH/2, touchPoint.y-self.panImageWH/2, self.panImageWH, self.panImageWH);
            //找到当前 触摸点的 index
            NSInteger touchPointLocationTag = imageTag;
            for(int i = 0;i<=_state;i++){
                if(i == imageTag){
                    continue;
                }
                if(CGRectContainsPoint(self.imageVs[i].frame, touchPoint)){
                    touchPointLocationTag = i;
                    break;
                }
            }
 //           NSLog(@"原始tag%ld---目的tag%ld",imageTag,touchPointLocationTag);
            
            
            CGRect lastFrame = self.imageVs[touchPointLocationTag].frame;
            if(touchPointLocationTag>imageTag){
                [UIView animateWithDuration:0.1 animations:^{
                    for(NSInteger i = touchPointLocationTag;i>imageTag;i--){
                        if(i != imageTag+1){
                            self.imageVs[i].frame = self.imageVs[i-1].frame;
                        }else{
                            self.imageVs[i].frame = _originFrame;
                        }
                    }
                } completion:^(BOOL finished) {
                    if(!finished){
                        NSLog(@"NO");
                    }else{
                        
                    }
                    
                }];
                imageV.tag = touchPointLocationTag;
                for(NSInteger i = imageTag+1;i<=touchPointLocationTag;i++){
                    UIImageView *imageV = self.imageVs[i];
                    imageV.tag--;
                    self.imageVs[imageV.tag] = imageV;
                }
                self.imageVs[touchPointLocationTag] = imageV;
                _originFrame = lastFrame;
                
            }else if(touchPointLocationTag<imageTag){
                [UIView animateWithDuration:0.1 animations:^{
                    for(NSInteger i = touchPointLocationTag;i<imageTag;i++){
                        if(i != imageTag-1){
                            self.imageVs[i].frame = self.imageVs[i+1].frame;
                        }else{
                            self.imageVs[i].frame = _originFrame;
                        }
                    }
                } completion:^(BOOL finished) {
                    if(!finished){
                        NSLog(@"NO");
                    }else{
                        
                    }
                    
                    
                    
                }];
                imageV.tag = touchPointLocationTag;
                for(NSInteger i = imageTag-1;i>=touchPointLocationTag;i--){
                    UIImageView *imageV = self.imageVs[i];
                    imageV.tag++;
                    self.imageVs[imageV.tag] = imageV;
                }
                self.imageVs[touchPointLocationTag] = imageV;
                _originFrame = lastFrame;
            }
            
            
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [UIView animateWithDuration:0.1 animations:^{
                imageV.frame = self.originFrame;
            } completion:^(BOOL finished) {
                for(UIImageView *imageView in self.imageVs){
                    
                    imageView.userInteractionEnabled = YES;
                    
                }
                [self reloadImages];
            }];
            break;
        }
        default:
            break;
    }
}

//防止bug,增强稳定性
-(void)reloadImages{
    for(NSInteger i = 0;i<self.imageVs.count;){
        UIImageView *imageV = self.imageVs[i];
        NSInteger tag = imageV.tag;
        NSInteger realTag = [self tagForPoint:imageV.center];
        if(tag!=realTag){
            UIImageView *newImageV = self.imageVs[realTag];
            self.imageVs[realTag] = imageV;
            self.imageVs[tag] = newImageV;
            imageV.tag = realTag;
            newImageV.tag = tag;
            
        }else{
            i++;
        }
    }
    NSMutableArray<UIImage*> *images = [[NSMutableArray alloc]init];
    for(NSInteger i = 0;i<=_state;i++){
        [images addObject:self.imageVs[i].image];
    }
    self.images = images;
    if(self.delegate&&[self.delegate respondsToSelector:@selector(animationView:didChangeImages:)]){
        [self.delegate animationView:self didChangeImages:[self.images copy]];
    }
}

-(NSInteger)tagForPoint:(CGPoint)point{
    for(int i = 0;i<_frames.count;i++){
        if(CGRectContainsPoint(_frames[i].CGRectValue, point)){
            return i;
        }
    }
    return -1;
}
#pragma mark deleteImageAtIndex
-(void)deleteImageAtIndex:(NSInteger)index{
    if(index <= _state){
        self.imageVs[index].hidden = YES;
        NSInteger imageTag = self.imageVs[index].tag;
        CGRect stateFrame = self.imageVs[_state].frame;
        [UIView animateWithDuration:0.1 animations:^{
            NSInteger i = _state;
            while(i>imageTag){
                self.imageVs[i].frame = self.imageVs[i-1].frame;
                i--;
            }
        } completion:^(BOOL finished) {
            NSInteger i = imageTag;
            while(i<_state){
                
                self.imageVs[i].image = self.imageVs[i+1].image;
                self.imageVs[i].frame = self.imageVs[i+1].frame;
                i++;
            }
            self.imageVs[_state].image = self.addImage;
            self.imageVs[_state].frame = stateFrame;
            _state--;
            
            self.imageVs[index].hidden = NO;
            [self.images removeObjectAtIndex:index];
            if(self.delegate&&[self.delegate respondsToSelector:@selector(animationView:didChangeImages:)]){
                [self.delegate animationView:self didChangeImages:[self.images copy]];
            }
        }];
    }
}

@end
