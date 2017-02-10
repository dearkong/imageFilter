//
//  ViewController.m
//  imageFilter
//
//  Created by cheyipai.com on 16/12/14.
//  Copyright © 2016年 kong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    UIImagePickerController *imagePicker;
    UIImageView *imageView;
    CIImage *beginImage;
    UIImage *resultImage;
    CIFilter *filter1;
    CIFilter *filter2;
    CIFilter *filter3;
    CIFilter *filter4;
    CIContext *ctx;


}
@property (nonatomic,strong)UISlider *slider1;
@property (nonatomic,strong)UISlider *slider2;
@property (nonatomic,strong)UISlider *slider3;
@property (nonatomic,strong)UISlider *slider4;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imageView];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 200, 50, 40)];
    label1.text = @"模糊";
    [self.view addSubview:label1];
    
    _slider1 = [[UISlider alloc] initWithFrame:CGRectMake(label1.frame.size.width + label1.frame.origin.x, label1.frame.origin.y, self.view.frame.size.width - 70, label1.frame.size.height)];
    [_slider1 addTarget:self action:@selector(slider1:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider1];
    
    
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(label1.frame.origin.x, label1.frame.origin.y+ label1.frame.size.height, label1.frame.size.width, label1.frame.size.height)];
    label2.text = @"鱼眼";
    [self.view addSubview:label2];
    
    _slider2 = [[UISlider alloc] initWithFrame:CGRectMake(label2.frame.size.width + label2.frame.origin.x, label2.frame.origin.y, self.view.frame.size.width - 70, label2.frame.size.height)];
    [_slider2 addTarget:self action:@selector(slider2:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider2];
    
    
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(label2.frame.origin.x, label2.frame.origin.y+ label2.frame.size.height, label2.frame.size.width, label2.frame.size.height)];
    label3.text = @"色彩";
    [self.view addSubview:label3];
    
    _slider3 = [[UISlider alloc] initWithFrame:CGRectMake(label3.frame.size.width + label3.frame.origin.x, label3.frame.origin.y, self.view.frame.size.width - 70, label3.frame.size.height)];
    [_slider3 addTarget:self action:@selector(slider3:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider3];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(label3.frame.origin.x, label3.frame.origin.y+ label3.frame.size.height, label3.frame.size.width, label3.frame.size.height)];
    label4.text = @"像素";
    [self.view addSubview:label4];
    
    _slider4 = [[UISlider alloc] initWithFrame:CGRectMake(label4.frame.size.width + label4.frame.origin.x, label4.frame.origin.y, self.view.frame.size.width - 70, label4.frame.size.height)];
    [_slider4 addTarget:self action:@selector(slider4:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider4];
    
    
    
    
    
    _slider1.minimumValue = 0;
    _slider1.maximumValue = 10;
    _slider2.minimumValue = -4;
    _slider2.maximumValue = 4;
    _slider3.minimumValue = -2;
    _slider3.maximumValue = 2;
    _slider4.minimumValue = 0;
    _slider4.maximumValue = 30;
    
   
    NSArray *nameArr = @[@"重置",@"照片",@"保存"];
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20 +(self.view.frame.size.width - 250)/2.0*i + 70* i , self.view.frame.size.height - 50, 70, 50) ;
        [btn setTitle:nameArr[i] forState:UIControlStateNormal];
        btn.tag = 100 + i;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        
    }
    
    imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    
    
    //调用reset方法来初始化程序界面
    [self reset:nil];
    [self logAllFilters];
    
    
    
    //创建基于CPU的CIContext
    ctx = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kCIContextUseSoftwareRenderer]];
//    //创建基于GPU的CIContext
    ctx = [CIContext contextWithOptions:nil];
    EAGLContext *eaglctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    ctx = [CIContext contextWithEAGLContext:eaglctx];
//    //

    
    filter1 = [CIFilter filterWithName:@"CIGaussianBlur"];
    
    filter2 = [CIFilter filterWithName:@"CIBumpDistortion"];
    
    filter3 = [CIFilter filterWithName:@"CIHueAdjust"];
    
    filter4 = [CIFilter filterWithName:@"CIPixellate"];
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}
//定义一个工具方法，对程序本身没有任何作用，仅仅用于查看系统内建的所有过滤器
- (void)logAllFilters {

    NSArray *properties = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    NSLog(@"所有内建过滤器：\n%@",properties);
    for (NSString *filterName in properties) {
        CIFilter *filter = [CIFilter filterWithName:filterName];
        //打印所有过滤器的默认属性
        NSLog(@"=====%@=====\n%@",filterName,[filter attributes]);
    }


}
- (void)btn:(UIButton *)btn {
    switch (btn.tag) {
        case 100:
            //重置
            [self reset:nil];
            break;
        case 101:
            //照片
            [self presentViewController:imagePicker animated:YES completion:nil];
            break;
        case 102:
            //保存
            UIImageWriteToSavedPhotosAlbum(resultImage, nil, nil, nil);
            break;
            
        default:
            break;
    }

}
- (void)slider1:(UISlider *)sl {

    //模糊
    //重新设置界面上其他UISlider的初始值
    _slider2.value = 0;
    _slider3.value = 0;
    _slider4.value = 0;
   
    float slideValue = self.slider1.value;
    //设置该过滤器处理的原始图片
    [filter1 setValue:beginImage forKey:@"inputImage"];
    //为过滤器设置参数
    [filter1 setValue:[NSNumber numberWithFloat:slideValue] forKey:@"inputRadius"];
    //得到过滤器设置后的图片
    CIImage *outImage = [filter1 outputImage];
//    NSLog(@"[outImage extent]:%@",NSStringFromCGRect([outImage extent]));
//    CGImageRef tem = [ctx createCGImage:outImage fromRect:CGRectMake(0, 0, 1080, 1920)];
    CGImageRef tem = [ctx createCGImage:outImage fromRect:[outImage extent]];

    resultImage = [UIImage imageWithCGImage:tem];
    CGImageRelease(tem);
    [imageView setImage:resultImage];

}
- (void)slider2:(UISlider *)sl {
    
    //鱼眼
    
    
    //重新设置界面上其他UISlider的初始值
    _slider1.value = 0;
    _slider3.value = 0;
    _slider4.value = 0;
    
    float slideValue = self.slider2.value;
    //设置该过滤器处理的原始图片
    [filter2 setValue:beginImage forKey:@"inputImage"];
    
    [filter2 setValue:[CIVector vectorWithX:150 Y:240] forKey:@"inputCenter"];

    [filter2 setValue:[NSNumber numberWithFloat:150] forKey:@"inputRadius"];

    [filter2 setValue:[NSNumber numberWithFloat:slideValue] forKey:@"inputScale"];
    CIImage *outImage = [filter2 outputImage];
    //    NSLog(@"[outImage extent]:%@",NSStringFromCGRect([outImage extent]));
    //    CGImageRef tem = [ctx createCGImage:outImage fromRect:CGRectMake(0, 0, 1080, 1920)];
    CGImageRef tem = [ctx createCGImage:outImage fromRect:[outImage extent]];
    
    resultImage = [UIImage imageWithCGImage:tem];
    CGImageRelease(tem);
    [imageView setImage:resultImage];
    


    
}
- (void)slider3:(UISlider *)sl {

    //色彩
    
    //重新设置界面上其他UISlider的初始值
    _slider1.value = 0;
    _slider2.value = 0;
    _slider4.value = 0;
    
    float slideValue = self.slider3.value;
    //设置该过滤器处理的原始图片
    [filter3 setValue:beginImage forKey:@"inputImage"];
   
    
    [filter3 setValue:[NSNumber numberWithFloat:slideValue] forKey:@"inputAngle"];
    CIImage *outImage = [filter3 outputImage];
    //    NSLog(@"[outImage extent]:%@",NSStringFromCGRect([outImage extent]));
    //    CGImageRef tem = [ctx createCGImage:outImage fromRect:CGRectMake(0, 0, 1080, 1920)];
    CGImageRef tem = [ctx createCGImage:outImage fromRect:[outImage extent]];
    
    resultImage = [UIImage imageWithCGImage:tem];
    CGImageRelease(tem);
    [imageView setImage:resultImage];
    

    
}
- (void)slider4:(UISlider *)sl {
    
    //像素
    
    //重新设置界面上其他UISlider的初始值
    _slider1.value = 0;
    _slider3.value = 0;
    _slider2.value = 0;
    
    float slideValue = self.slider4.value;
    //设置该过滤器处理的原始图片
    [filter4 setValue:beginImage forKey:@"inputImage"];
    
    [filter4 setValue:[CIVector vectorWithX:150 Y:240] forKey:@"inputCenter"];
    
    
    [filter4 setValue:[NSNumber numberWithFloat:slideValue] forKey:@"inputScale"];
    CIImage *outImage = [filter4 outputImage];
    //    NSLog(@"[outImage extent]:%@",NSStringFromCGRect([outImage extent]));
    //    CGImageRef tem = [ctx createCGImage:outImage fromRect:CGRectMake(0, 0, 1080, 1920)];
    CGImageRef tem = [ctx createCGImage:outImage fromRect:[outImage extent]];
    
    resultImage = [UIImage imageWithCGImage:tem];
    CGImageRelease(tem);
    [imageView setImage:resultImage];
    

}

- (void)reset:(id)sender {
    //重设界面上UISlider的初始值ha
    self.slider1.value = 0;
    self.slider2.value = 0;
    self.slider3.value = 0;
    self.slider4.value = 0;
    //得到原始的图片路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"hahaha" ofType:@"jpg"];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    imageView.image = [UIImage imageWithContentsOfFile:filePath];
    //使用图片URL创建CIImage
    beginImage = [CIImage imageWithContentsOfURL:fileUrl];
    


}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    beginImage = [CIImage imageWithCGImage:selectedImage.CGImage];
    [imageView setImage:selectedImage];



}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
