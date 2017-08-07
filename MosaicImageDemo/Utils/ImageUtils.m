//
//  ImageUtils.m
//  OpenCV_imageGray
//
//  Created by chenlishuang on 17/7/25.
//  Copyright © 2017年 chenlishuang. All rights reserved.
//

#import "ImageUtils.h"

@implementation ImageUtils
+ (UIImage *)imageProcess:(UIImage *)image{
    //第一步:确定图片的宽高
    //有两种方案
    //第一种:image.size.width
    //第二种:CGImageGetWidth(image.CGImage)
    CGImageRef imageRef = image.CGImage;
    NSInteger width = CGImageGetWidth(imageRef);
    NSInteger height = CGImageGetHeight(imageRef);
    //第二步:创建颜色空间(分为两种: 灰色颜色空间/彩色颜色空间)
    //彩色颜色空间:CGColorSpaceCreateDeviceRGB
    //灰色颜色空间:CGColorSpaceCreateDeviceGray
    //也可以动态获取颜色空间
    //动态获取:CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(image.CGImage);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    //第三部:创建图片上下文(解析图片信息,绘制图片)
    //开辟一块内存空间,这块空间用于处理马赛克图片
    //参数一:数据源
    //参数二:图片宽
    //参数三:图片高
    //参数四:表示每一个像素点,每一个分量的大小(在图像学中,像素点:ARGB组成,每一个表示一个分量,例如A,R,G,B,每一个分量的大小是8位 = 1字节)
    //参数五:每一行大小(其实图片:像素数组)
    //如何计算每一行的大小,所占用的内存
    //首先计算一个像素点的大小 (最大值) = ARGB = 4个分量 = 每一个分量8位 * 4 = 4字节
    //所以每一行的大小 = width *4
    //参数六:颜色空间
    //参数七:位图信息(是否需要透明度)(深入学习:了解底层字节序)
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, width * 4, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    
    //第四步:根据图片上下文,绘制对应颜色空间的图片
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    //第五步:重点,获取图片的像素数组
    //为什么是unsigned
    //unsigned:表示无符号
    //signed:表示有符号
    //在图像学中,ARGB取值范围:0~255(没有正负号)->通用
    //例如:
    //采用unsigned:像素点取值范围(0~255)
    //采用signed:像素点取值范围(-128~127)
    //我们通常情况下都是取值0~255,所以通用unsigned
    unsigned char* bitmapDataSrc = CGBitmapContextGetData(contextRef);
    
    //第六步:最核心功能(加入马赛克)
    //核心原理,算法
    //马赛克:讲图片模糊(马赛克的算法可逆,也可以不可逆,取决于打码的算法问题)
    //对图片进行采样
    //处理原理
    //让一个像素点替换为一个和他相同的颜色的矩形区域(正方形,圆形等等...)
    //矩形区域:包含了N个像素点
    //可以选择马赛克区域
    //矩形区域:认为马赛克级别(通俗的讲就是马赛克点的大小)(失真强度,1就是矩形区域(1*1),强度10就是(10*10))
    NSUInteger currentIndex,preCurrentIndex,level = 10;
    //像素点 4个通道,默认值为0-->4个字节
    unsigned char* pixels[4] = {0};
    for (NSUInteger i = 0; i<height-1; i++) {
        for (NSUInteger j = 0; j<width-1; j++) {
            //循环遍历每一个像素点,然后筛选,打码
            //获取当前像素点坐标->指针位移方式处理像素点->修改
            currentIndex = (i*width)+j;
            //计算矩形区域 (筛选马赛克的区域)
            //分析下面筛选算法(组成马赛克点,矩形算法)
            //假设level = 3 (3*3矩形)
            //宽的规律
            //第一次运行循环:(第一行,第一列)
            //       i=0,j=0,level=3  i%level=0 %3 = 0
            //       j % 3 = 0 % 3 = 0
            //       memcpy(pixels, bitmapDataSrc + 4 * currentIndex, 4);
            // 给像素点赋值(在这里以字节为单位获取,一个像素 = 4个字节)
            //第一次循环结果:获取第一个像素点的值
            //第二次运行循环:(第一行第二列)
            //     i = 0  j = 1 level = 3
            //     i % level = 0 % 3 = 0
            //     j % level = 1 % 3 = 1
            //第二次循环的结果:第一行第二个像素点值 = 第一个像素点值 (保证一致)
            //第三次运行循环:(第一行第三列)
            //     i = 0  j = 2 level = 3
            //     i % level = 0
            //     j % level = 2 % 3 = 2
            //第三次循环结果:第一行第三个像素点值 = 第一个像素点值
            //第四次运行循环:(第一行第四列)
            //     i = 0  j = 3 level = 3
            //     i % level = 0
            //     j % level = 3 % 3 = 0
            //行:开始循环
            //计算高的规律
            //第一次运行循环:(第二行第一列)
            //     i = 1  j = 3 level = 3
            //     i % level = 0
            //     j % level = 3 % 3 = 0
            //第一次循环结果:第二行第一个像素点 = 第一行第一个像素点值
            //第二次运行循环:(第二行第二列)
            //     i = 1  j = 1 level = 3
            //     i % level = 1
            //     j % level = 1 % 3 = 1
            //第二次循环结果:第二行第二个像素点 = 第一行第一个像素点值
            //第三次运行循环:(第二行第一列)
            //     i = 1  j = 2 level = 3
            //     i % level = 1
            //     j % level = 2 % 3 = 2
            //第三次循环结果:第二行第三个像素点 = 第一行第一个像素点值
            //总结如下:通过该算法,动态截取到了一个矩形(3*3)
            if (i%level==0) {
                if (j%level==0) {
                    //参数一:拷贝的目标(像素点)
                    //参数二:源文件
                    //参数三:截取的长度(按字节计算)
                    //一个像素点,一个像素点读取,每次读取4个字节
                    //C语言拷贝数据函数
                    memcpy(pixels, bitmapDataSrc + 4 * currentIndex, 4);
                }else{
                    //将上一个像素点的值,拷贝复制替换给第二个像素点(指针位移方式计算)
                    memcpy(bitmapDataSrc + 4 * currentIndex, pixels, 4);
                }
            }else{
                //例如: i = 1
                //currentIndex = (i*width)+j = (1*width)+j;
                //preCurrentIndex = (1 - 1) * width + j = 0;
                preCurrentIndex = (i - 1) * width + j;
                memcpy(bitmapDataSrc + 4 * currentIndex, bitmapDataSrc + 4 * preCurrentIndex, 4);
            }
        }
    }
    //第七步:获取图片数据集合->用于创建马赛克图片
    NSUInteger size = width * height * 4;
    CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, bitmapDataSrc, size, NULL);
    //第八步:创建马赛克图片(内存操作)
    //参数一:数据源
    //参数二:图片宽
    //参数三:图片高
    //参数四:表示每一个像素点,每一个分量的大小(在图像学中,像素点:ARGB组成,每一个表示一个分量,例如A,R,G,B,每一个分量的大小是8位 = 1字节)
    //参数五:每一行内存大小
    //参数六:颜色空间
    //参数七:位图信息(是否需要透明度)(深入学习:了解底层字节序)
    //参数八:数据源(数据集合)
    //参数九:数据解码器
    //参数十:是否抗锯齿
    //参数十一:渲染器
    CGImageRef mosaicImageRef = CGImageCreate(width, height, 8, 4*8, width *4, colorSpaceRef, kCGImageAlphaPremultipliedLast, providerRef, NULL, NO, kCGRenderingIntentDefault);
    
    //第九步:创建输出马赛克图片(显示UI图片)->填充颜色
    CGContextRef outputContextRef = CGBitmapContextCreate(nil, width, height, 8, width * 4, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    //绘制图片
    CGContextDrawImage(outputContextRef, CGRectMake(0, 0, width, height), mosaicImageRef);
    //创建图片
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContextRef);
    UIImage *resultImage = [UIImage imageWithCGImage:resultImageRef];
    //第十步:释放内存
    CGImageRelease(resultImageRef);
    CGImageRelease(mosaicImageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(providerRef);
    CGContextRelease(contextRef);
    CGContextRelease(outputContextRef);
    
    
    return resultImage;
}







@end
