//
//  ViewController.m
//  QGEImageAnimationDemo
//
//  Created by wei1 on 2017/4/20.
//  Copyright © 2017年 qge. All rights reserved.
//

#import "ViewController.h"
#import "QGEViewAnimationController.h"
#import "AnimationView.h"
#define ViewWH 400
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define addImageName @"addmedia"
@interface ViewController ()<AnimationViewDelegate,AnimationViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic) AnimationView *animationView;
@property (nonatomic) NSMutableArray<UIImage*> *images;
@property (nonatomic)UIImagePickerController *pC;
@end

@implementation ViewController

-(NSMutableArray<UIImage *> *)images{
    if(_images == nil){
        _images = [NSMutableArray array];
    }
    return _images;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AnimationView *animationView = [[AnimationView alloc]initWithFrame:CGRectMake(30, 0, ViewWH, ViewWH)];
    [self.view addSubview:animationView];
    animationView.delegate = self;
    animationView.dataSource = self;
    self.animationView = animationView;
//    self.animationView = animationView;
}

-(NSArray<UIImage *> *)loadImagesInAnimationView:(AnimationView *)animationView{
    return [self.images copy];
}

-(UIImage *)setAddImageImageInAnimationView:(AnimationView *)animationView{
    return [UIImage imageNamed:addImageName];
}

-(NSInteger)panImageVWHInAnimationView:(AnimationView *)animationView{
    return 40;
}

-(void)animationView:(AnimationView *)animationView didChangeImages:(NSArray<UIImage *> *)images{
    self.images = [images mutableCopy];;
}

-(void)animationView:(AnimationView *)animationView didSelectUnExistImage:(UIImage *)image{
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
}

#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self.images addObject:image];
    [self.animationView reloadAnimationView];    
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)animationView:(AnimationView *)animationView didSelectExistImage:(UIImage *)image index:(NSInteger)index{
    //删除图片
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.animationView deleteImageAtIndex:index];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:true completion:nil];
}

@end
