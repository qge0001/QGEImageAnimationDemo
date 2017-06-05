//
//  QGEViewAnimationController.m
//  QGEImageAnimationDemo
//
//  Created by wei1 on 2017/4/20.
//  Copyright © 2017年 qge. All rights reserved.
//

#import "QGEViewAnimationController.h"
#import "Masonry.h"

#define addImageName @"addmedia"
#define panImageWH 80
@interface QGEViewAnimationController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic)CGRect viewFrame;
@property (nonatomic)NSMutableArray<UIImageView *> *images;
@property (nonatomic)NSInteger state;
@property (nonatomic)UIImagePickerController *pC;

@property (nonatomic) CGRect originFrame;
@property(nonatomic) NSMutableArray<NSValue *>* frames;

//@property (nonatomic) NSInteger touchingTag;

@end

@implementation QGEViewAnimationController

-(NSMutableArray *)frames{
    if(_frames == nil){
        _frames = [NSMutableArray array];
    }
    return _frames;
}

-(NSMutableArray<UIImageView *> *)images{
    if(_images == nil){
        _images = [NSMutableArray array];
    }
    return _images;
}



-(void)loadView{
    
    if(CGRectEqualToRect(_viewFrame,CGRectZero)){
        _viewFrame = CGRectMake(0, 0, 300, 300);
    }
    self.view = [[UIView alloc] initWithFrame:_viewFrame];
}

-(instancetype)initWithViewFrame:(CGRect)frame{
    _viewFrame = frame;
    return [self init];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpImage];
    
}

-(void)setUpImage{
    
    for(int i = 0;i<=5;i++){
        UIImageView *imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:addImageName]];
        imageV.userInteractionEnabled = YES;
        imageV.multipleTouchEnabled = NO;
        
        imageV.tag = i;
        
        //添加增加/删除图片手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
        [imageV addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panImage:)];
        
        [imageV addGestureRecognizer:pan];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(panImage:)];
        
        
        
        [imageV addGestureRecognizer:longPress];
        
        [self.images addObject:imageV];
    }
    
    [self.view addSubview:self.images[0]];
    [self.images[0] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view);
        make.height.mas_equalTo(_viewFrame.size.height*2/3);
        make.width.mas_equalTo(_viewFrame.size.width*2/3);
    }];
    
    [self.view addSubview:self.images[1]];
    [self.images[1] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self.view);
        make.left.equalTo(self.images[0].mas_right);
        make.height.mas_equalTo(_viewFrame.size.height/3);
    }];
    
    [self.view addSubview:self.images[2]];
    [self.images[2] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.top.equalTo(self.images[1].mas_bottom);
        make.left.equalTo(self.images[0].mas_right);
        make.height.mas_equalTo(_viewFrame.size.height/3);
    }];
    
    [self.view addSubview:self.images[3]];
    [self.images[3] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.top.equalTo(self.images[2].mas_bottom);
        make.left.equalTo(self.images[0].mas_right);
        make.height.mas_equalTo(_viewFrame.size.height/3);
    }];
    
    [self.view addSubview:self.images[4]];
    [self.images[4] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.images[3].mas_left);
        make.top.equalTo(self.images[0].mas_bottom);
        make.width.mas_equalTo(_viewFrame.size.width/3);
        make.bottom.equalTo(self.view);
    }];
    
    [self.view addSubview:self.images[5]];
    [self.images[5] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.images[4].mas_left);
        make.top.equalTo(self.images[0].mas_bottom);
        make.width.mas_equalTo(_viewFrame.size.width/3);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    _state = -1;
}

-(void)viewDidAppear:(BOOL)animated{
    [self.images enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.frames addObject:[NSValue valueWithCGRect:obj.frame]];
    }];
}

-(void)tapImage:(UITapGestureRecognizer *)sender{
    UIImageView *imageV = sender.view;
    NSInteger imageTag = imageV.tag;
    
    if (imageTag >_state){
        //添加图片
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *addImageAction = [UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
                UIImagePickerController *pC = [[UIImagePickerController alloc]init];
                pC.delegate = self;
                pC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                _pC = pC;
                [self presentViewController:_pC animated:YES completion:nil];
            }else{
                NSLog(@"相册不可访问");
            }
            
            
            
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:addImageAction];
        [self presentViewController:alert animated:true completion:nil];
        
    }else{
        //删除图片
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //此处应有动画
            imageV.hidden = YES;
            [UIView animateWithDuration:0.1 animations:^{
                NSInteger i = _state;
                while(i>imageTag){
                    _images[i].frame = _images[i-1].frame;
                    i--;
                }
            } completion:^(BOOL finished) {
                NSInteger i = imageTag;
                while(i<_state){
                    
                    _images[i].image = _images[i+1].image;
                    _images[i].frame = _images[i+1].frame;
                    i++;
                }
                _images[_state].image = [UIImage imageNamed:addImageName];
                
                _state--;
                
                imageV.hidden = NO;
            }];
            
            
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:deleteAction];
        [self presentViewController:alert animated:true completion:nil];
        
    }
    
}


#pragma mark 平移手势+长按手势
-(void)panImage:(UIGestureRecognizer*)sender{
    UIImageView *imageV = sender.view;
    NSInteger imageTag = imageV.tag;
    if(imageTag>_state){
        return;
    }
   
    CGPoint touchPoint = [sender locationInView:self.view];
    
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            //记录拖动的view的原始frame
            self.originFrame = imageV.frame;
            //scale
            [UIView animateWithDuration:0.1 animations:^{
                imageV.frame = CGRectMake(touchPoint.x-panImageWH/2, touchPoint.y-panImageWH/2, panImageWH, panImageWH);
            }];
            
            for(UIImageView *imageView in _images){
                if(imageView.tag!=imageTag){
                    imageView.userInteractionEnabled = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{
            imageV.frame = CGRectMake(touchPoint.x-panImageWH/2, touchPoint.y-panImageWH/2, panImageWH, panImageWH);
            //找到当前 触摸点的 index
            NSInteger touchPointLocationTag = imageTag;
            for(int i = 0;i<=_state;i++){
                if(i == imageTag){
                    continue;
                }
                if(CGRectContainsPoint(_images[i].frame, touchPoint)){
                    touchPointLocationTag = i;
                    break;
                }
            }
            NSLog(@"原始tag%ld---目的tag%ld",imageTag,touchPointLocationTag);
            
            
            CGRect lastFrame = _images[touchPointLocationTag].frame;
            if(touchPointLocationTag>imageTag){
                [UIView animateWithDuration:0.1 animations:^{
                    for(NSInteger i = touchPointLocationTag;i>imageTag;i--){
                        if(i != imageTag+1){
                            _images[i].frame = _images[i-1].frame;
                        }else{
                            _images[i].frame = _originFrame;
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
                    UIImageView *imageV = _images[i];
                    imageV.tag--;
                    _images[imageV.tag] = imageV;
                }
                _images[touchPointLocationTag] = imageV;
                _originFrame = lastFrame;
                
            }else if(touchPointLocationTag<imageTag){
                [UIView animateWithDuration:0.1 animations:^{
                    for(NSInteger i = touchPointLocationTag;i<imageTag;i++){
                        if(i != imageTag-1){
                            _images[i].frame = _images[i+1].frame;
                        }else{
                            _images[i].frame = _originFrame;
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
                    UIImageView *imageV = _images[i];
                    imageV.tag++;
                    _images[imageV.tag] = imageV;
                }
                _images[touchPointLocationTag] = imageV;
                _originFrame = lastFrame;
            }
            
            
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [UIView animateWithDuration:0.1 animations:^{
                imageV.frame = self.originFrame;
            } completion:^(BOOL finished) {
                for(UIImageView *imageView in _images){
                
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
    for(NSInteger i = 0;i<_images.count;){
        UIImageView *imageV = _images[i];
        NSInteger tag = imageV.tag;
        NSInteger realTag = [self tagForPoint:imageV.center];
        if(tag!=realTag){
            UIImageView *newImageV = _images[realTag];
            _images[realTag] = imageV;
            _images[tag] = newImageV;
            imageV.tag = realTag;
            newImageV.tag = tag;
            
        }else{
            i++;
        }
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


#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    _state++;
    _images[_state].image = image;

    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
