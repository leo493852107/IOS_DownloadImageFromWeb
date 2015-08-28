//
//  ViewController.m
//  02-表格图片xiazai
//
//  Created by leo on 15/8/27.
//  Copyright (c) 2015年 leo. All rights reserved.
//

#import "ViewController.h"
#import "CZApp.h"


@interface ViewController ()

/**
 *  plist文件数据的容器
 */
@property (nonatomic, copy)NSArray *appList;


/**
 *  管理全局下载操作的队列
 */
@property (nonatomic, strong)NSOperationQueue *opQueue;

/**
 *  所有下载操作的缓冲池
 */
@property (nonatomic, strong)NSMutableDictionary *operationCache;

/**
 *  所有图像的缓存
 */
@property (nonatomic, strong)NSMutableDictionary *imageCache;

@end

@implementation ViewController

- (NSMutableDictionary *)imageCache{
    if (!_imageCache) {
        _imageCache = [NSMutableDictionary dictionary];
    }
    return _imageCache;
}

- (NSMutableDictionary *)operationCache{
    if (!_operationCache) {
        _operationCache = [NSMutableDictionary dictionary];
    }
    return _operationCache;
}

- (NSOperationQueue *)opQueue{
    if (!_opQueue) {
        _opQueue = [[NSOperationQueue alloc]init];
    }
    return _opQueue;
}

//懒加载
- (NSArray *)appList{
    if (!_appList) {
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"apps.plist" ofType:nil]];
        
        //字典转模型
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            CZApp *app = [CZApp appWithDict:dict];
            [arrayM addObject:app];
        }
        _appList = arrayM;
    }
    return _appList;
}

#pragma mark - 数据源的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.appList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"AppCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    //给cell设置数据
    CZApp *app = self.appList[indexPath.row];
    
    
    cell.textLabel.text = app.name;
    cell.detailTextLabel.text = app.download;
    
    //判断模型里面是否有图像
    if ([self.imageCache objectForKey:app.icon]) {
        NSLog(@"没有上网下载");
        cell.imageView.image = self.imageCache[app.icon];
    } else{
        //显示图片
        //显示占位图
        cell.imageView.image = [UIImage imageNamed:@"user_default"];
        
#warning 从这里开始剪代码
        //下载图片
        [self downloadImage:indexPath];
    }
    return cell;
    
    
}

/**
 *  下载图片
 */
- (void)downloadImage:(NSIndexPath *)indexPath{
    
    CZApp *app = self.appList[indexPath.row];
    
    //判断缓冲池中是否存在当前图片的操作
    if (self.operationCache[app.icon]) {
        NSLog(@"正在下载");
        return;
    }
    
    //没有下载操作
    //异步下载图片
    NSBlockOperation *downloadOp = [NSBlockOperation blockOperationWithBlock:^{
        
//        if (indexPath.row == 8) {
//            //0 模拟延迟
//            [NSThread sleepForTimeInterval:5];
//        }
//        [NSThread sleepForTimeInterval:0.5];
        NSLog(@"downloading.....");
        
        //1 下载图片(二进制)
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:app.icon]];
        UIImage *image = [UIImage imageWithData:data];
        
        //2 将下载的数据保存到模型
        // 字典的赋值，不能为nil
        if (image) {
            [self.imageCache setObject:image forKey:app.icon];
            
            //3 将操作从缓存池删除
            [self.operationCache removeObjectForKey:app.icon];
            
        }
        
        //4 更新UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //            cell.imageView.image = image;
            //刷新当前行 会重新调用cell的初始化方法
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        
    }];
    
    //将操作添加到队列
    [self.opQueue addOperation:downloadOp];
    
    NSLog(@"操作的数量--->%tu",self.opQueue.operationCount);
    
    //将操作添加到缓冲池中(使用图片的url作为key)
    [self.operationCache setObject:downloadOp forKey:app.icon];
    
}

/**
 *  清理内存
 */
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
    //清理图片的内存
    [self.imageCache removeAllObjects];
    
    //清理操作的缓存
    [self.operationCache removeAllObjects];
    
    //停止所有没有完成的任务
    [self.opQueue cancelAllOperations];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",self.operationCache);
}


@end
