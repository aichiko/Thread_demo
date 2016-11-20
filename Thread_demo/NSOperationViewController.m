//
//  NSOperationViewController.m
//  Thread_demo
//
//  Created by 24hmb on 2016/11/18.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import "NSOperationViewController.h"

@interface NSOperationViewController ()
{
    NSMutableArray *_imageViews;
}
- (IBAction)loadImageWithMultiThread:(id)sender;

@end

@implementation NSOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self layoutUI];
    
    /*创建一个调用操作
     object:调用方法参数
     */
    NSInvocationOperation *invocationOperation =  [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadImage:) object:nil];
    //创建完NSInvocationOperation对象并不会调用，它由一个start方法启动操作，但是注意如果直接调用start方法，则此操作会在主线程中调用，一般不会这么操作,而是添加到NSOperationQueue中
    //[invocationOperation start];
    
    //创建操作队列
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
    //注意添加到操作队后，队列会开启一个线程执行此操作
    [operationQueue addOperation:invocationOperation];
    
}


- (void)layoutUI {
    //创建多个图片控件用于显示图片
    _imageViews=[NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 2; j++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10+110*i, 100+110*j, 100, 100)];
            [self.view addSubview:imageView];
            [_imageViews addObject:imageView];
        }
    }
}


#pragma mark 加载图片
-(void)loadImage:(int)index{
    NSURL *url = [NSURL URLWithString:@"http://imgsrc.baidu.com/forum/w%3D580/sign=07bcb87477f082022d9291377bfafb8a/2da7adec54e736d185d9d05f9f504fc2d76269cd.jpg"];
    //如果在串行队列中会发现当前线程打印变化完全一样，因为他们在一个线程中
    NSLog(@"thread is :%@",[NSThread currentThread]);
    
    //请求数据
    NSData *data = [NSData dataWithContentsOfURL:url];
    //更新UI界面,此处调用了GCD主线程队列的方法
    
    if ([NSThread isMainThread]) {
        [self updateImageWithData:data andIndex:index];
    }else {
        dispatch_queue_t mainQueue= dispatch_get_main_queue();
        dispatch_sync(mainQueue, ^{
            [self updateImageWithData:data andIndex:index];
        });
    }
}

#pragma mark 将图片显示到界面
-(void)updateImageWithData:(NSData *)data andIndex:(int )index{
    UIImage *image=[UIImage imageWithData:data];
    UIImageView *imageView= _imageViews[index];
    imageView.image=image;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loadImageWithMultiThread:(id)sender {
    //创建操作队列
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
    operationQueue.maxConcurrentOperationCount = 5;//设置最大并发线程数
    
    NSBlockOperation *lastBlockOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self loadImage:5];
    }];
    //创建多个线程用于填充图片
    for (int i=0; i<6-1; ++i) {
        //方法1：创建操作块添加到队列
        //创建多线程操作
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            [self loadImage:i];
        }];
        //设置依赖操作为最后一张图片加载操作
        [blockOperation addDependency:lastBlockOperation];
        
        [operationQueue addOperation:blockOperation];
        
    }
    //将最后一个图片的加载操作加入线程队列
    [operationQueue addOperation:lastBlockOperation];
}

@end
