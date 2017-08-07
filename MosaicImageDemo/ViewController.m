//
//  ViewController.m
//  MosaicImageDemo
//
//  Created by chenlishuang on 2017/8/7.
//  Copyright © 2017年 chenlishuang. All rights reserved.
//

#import "ViewController.h"
#import "ImageUtils.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)normalAction:(id)sender {
    self.imageView.image = [UIImage imageNamed:@"111.jpg"];
    
}
- (IBAction)mosaicAction:(id)sender {
    self.imageView.image = [ImageUtils imageProcess:[UIImage imageNamed:@"111.jpg"]];
}


@end
