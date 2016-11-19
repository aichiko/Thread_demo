//
//  GCDViewController.m
//  Thread_demo
//
//  Created by 24hmb on 2016/11/18.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import "GCDViewController.h"

@interface GCDViewController ()
{
    NSMutableArray *_imageViews;
}
- (IBAction)concurrentQueueSyncMethod:(id)sender;

- (IBAction)concurrentQueueAsyncMethod:(id)sender;

@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //串行队列
    //dispatch_queue_t queue01 = dispatch_queue_create("queue01", DISPATCH_QUEUE_SERIAL);
    //并发队列
    //dispatch_queue_t queue02 = dispatch_queue_create("queue02", DISPATCH_QUEUE_CONCURRENT);
    //全局队列
    //dispatch_queue_t queue03 =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [self serialQueueSyncMethod];
    [self serialQueueAsyncMethod];
    
    [self layoutUI];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[self GCDAutoDispatchGroupMethod];
    });
    
    
    [self GCDManualDispatchGroupMethod];
    
}

//自动执行任务组
- (void)GCDAutoDispatchGroupMethod {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    for (int i = 0; i < 6; i++) {
        dispatch_group_async(group, queue, ^{
            NSLog(@"current Thread = %@----->%d",[NSThread currentThread],i);
            [self loadImage:i];
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"current Thread = %@----->group完成后执行",[NSThread currentThread]);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"图片加载完成" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:sureAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

//手动执行任务组
- (void)GCDManualDispatchGroupMethod {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    for (int i = 0; i < 6; i++) {
        
        dispatch_group_enter(group);//进入队列组
        
        dispatch_async(queue, ^{
            NSLog(@"current Thread = %@----->%d",[NSThread currentThread],i);
            
            dispatch_group_leave(group);//离开队列组
        });
    }
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    
    long result = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);//阻塞当前线程，直到所有任务执行完毕才会继续往下执行
    if (result == 0) {
        //属于Dispatch Group 的block任务全部处理结束
        NSLog(@"Dispatch Group全部处理完毕");
        
    }else{
        //属于Dispatch Group 的block任务还在处理中
        NSLog(@"Dispatch Group正在处理");
    }
    
    for (int i = 0; i < 6; i++) {
        
        dispatch_group_enter(group);//进入队列组
        
        dispatch_async(queue, ^{
            NSLog(@"current Thread = %@----->%d",[NSThread currentThread],i);
            
            dispatch_group_leave(group);//离开队列组
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"current Thread = %@----->这是最后执行",[NSThread currentThread]);
    });
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

#pragma mark - 串行队列同步和串行队列异步
//串行队列同步
- (void)serialQueueSyncMethod {
    //创建队列
    dispatch_queue_t queue = dispatch_queue_create("serialQueueSyncMethod", DISPATCH_QUEUE_SERIAL);
    //执行任务
    for (int i = 0; i < 6; i++) {
        NSLog(@"mainThread--->%d",i);
        dispatch_sync(queue, ^{
            NSLog(@"Current Thread=%@---->%d-----",[NSThread currentThread],i);
        });
    }
    NSLog(@"串行队列同步end");
}

//串行队列异步
- (void)serialQueueAsyncMethod {
    dispatch_queue_t queue = dispatch_queue_create("serialQueueAsyncMethod", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i < 6; i++) {
        NSLog(@"mainThread--->%d",i);
        dispatch_async(queue, ^{
            NSLog(@"Current Thread=%@---->%d-----",[NSThread currentThread],i);
        });
    }
    NSLog(@"串行队列异步end");
}

- (void)concurrentLoadImage {
    
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

#pragma mark - 并行队列同步和并行队列异步
//并行队列同步
- (IBAction)concurrentQueueSyncMethod:(id)sender {
    dispatch_queue_t queue = dispatch_queue_create("concurrentQueueSyncMethod", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i < 6; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"Current Thread=%@---->%d-----",[NSThread currentThread],i);
            [self loadImage:i];
        });
    }
    NSLog(@"并行队列同步end");
}

//并行队列异步
- (IBAction)concurrentQueueAsyncMethod:(id)sender {
    dispatch_queue_t queue = dispatch_queue_create("concurrentQueueAsyncMethod", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i < 6; i++) {
        dispatch_async(queue, ^{
            NSLog(@"Current Thread=%@---->%d-----",[NSThread currentThread],i);
            [self loadImage:i];
        });
    }
    
    NSLog(@"并行队列异步end");
    
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


@end
