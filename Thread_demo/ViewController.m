//
//  ViewController.m
//  Thread_demo
//
//  Created by 24hmb on 2016/11/18.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import "ViewController.h"
#import "GCDViewController.h"
#import "NSOperationViewController.h"

@interface ViewController ()
{
    NSInteger _tickets;//总票数
    NSInteger _soldCounts;//当前卖出去票数
}

@property (strong, nonatomic) UIImageView *imageView;


@property (nonatomic, strong) NSThread* ticketsThread_01;

@property (nonatomic, strong) NSThread* ticketsThread_02;

@property (nonatomic, strong) NSLock *ticketsLock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
    [self.view addSubview:_imageView];
    _imageView.center = self.view.center;

    //NSThread 的使用
    //使用类方法创建
    [NSThread detachNewThreadWithBlock:^{
        
    }];
    
    [NSThread detachNewThreadSelector:@selector(downloadImage) toTarget:self withObject:nil];
    
    //方法1：使用对象方法
    //创建一个线程，第一个参数是请求的操作，第二个参数是操作方法的参数
    NSThread *thread=[[NSThread alloc]initWithTarget:self selector:@selector(downloadImage) object:nil];
    
    NSThread *thread_0 = [[NSThread alloc]initWithBlock:^{
        
    }];
    //启动一个线程，注意启动一个线程并非就一定立即执行，而是处于就绪状态，当系统调度时才真正执行
    [thread start];
    [thread_0 start];
    
    
    //[self threadLock];
    
}

- (void)threadLock {
    _tickets = 100;
    _soldCounts = 0;
    
    //锁对象
    self.ticketsLock = [[NSLock alloc] init];
    
    self.ticketsThread_01 = [[NSThread alloc] initWithTarget:self selector:@selector(sellAction) object:nil];
    self.ticketsThread_01.name = @"thread-1";
    [self.ticketsThread_01 start];
    
    self.ticketsThread_02 = [[NSThread alloc] initWithTarget:self selector:@selector(sellAction) object:nil];
    self.ticketsThread_02.name = @"thread-2";
    [self.ticketsThread_02 start];
}

- (void)sellAction {
    while (true) {
        //上锁
        [self.ticketsLock lock];
        if (_tickets >= 0) {
            [NSThread sleepForTimeInterval:0.5];
            _soldCounts = 100 - _tickets;
            NSLog(@"当前总票数是：%ld----->卖出：%ld----->线程名:%@",_tickets,_soldCounts,[NSThread currentThread]);
            _tickets--;
        }else{
            break;
        }
        //解锁
        [self.ticketsLock unlock];
    }
}


- (void)downloadImage {
    
    NSURL *url = [NSURL URLWithString:@"http://imgsrc.baidu.com/forum/w%3D580/sign=07bcb87477f082022d9291377bfafb8a/2da7adec54e736d185d9d05f9f504fc2d76269cd.jpg"];
    
    //线程延迟3s
    //线程可以设置name ，这里可以指定name 来进行休眠
    [NSThread sleepForTimeInterval:3.0];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSLog(@"downLoadImage:%@",[NSThread currentThread]);//在子线程中下载图片
    
    /*将数据显示到UI控件,注意只能在主线程中更新UI,
     另外performSelectorOnMainThread方法是NSObject的分类方法，每个NSObject对象都有此方法，
     它调用的selector方法是当前调用控件的方法，例如使用UIImageView调用的时候selector就是UIImageView的方法
     Object：代表调用方法的参数,不过只能传递一个参数(如果有多个参数请使用对象进行封装)
     waitUntilDone:是否线程任务完成执行
     */
    if (data) {
        [self performSelectorOnMainThread:@selector(updateImage:) withObject:data waitUntilDone:YES];
    }
}


- (void)updateImage:(NSData *)imageData {
    //更新image
    UIImage *image = [UIImage imageWithData:imageData];
    _imageView.image=image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
