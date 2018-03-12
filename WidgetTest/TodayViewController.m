//
//  TodayViewController.m
//  WidgetTest
//
//  Created by shenzhenshihua on 2018/3/12.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
//@property(nonatomic,copy)void(^completionHandler)(NCUpdateResult);
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 10.0, *)) {
        //大于iOS10设置可折叠
        self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    }
    [self handleVerb:YES];
    _imageView.layer.cornerRadius = 5;
    _bigImageView.layer.cornerRadius = 5;
    [self downloadImage:@"http://d.hiphotos.baidu.com/image/pic/item/7aec54e736d12f2ecac1984643c2d562843568cb.jpg" completion:^(NSURL *path) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:path]];
            _bigImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:path]];
            [self wirteData:[NSData dataWithContentsOfURL:path]];
        });
    }];
    
    // Do any additional setup after loading the view from its nib.
}
/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self downloadImage:@"http://d.hiphotos.baidu.com/image/pic/item/7aec54e736d12f2ecac1984643c2d562843568cb.jpg" completion:^(NSURL *path) {
        //1.看一下数据是否有更新,如果有更新数据，就刷新数据
        self.completionHandler(NCUpdateResultNewData);

        dispatch_async(dispatch_get_main_queue(), ^{
            _imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:path]];
            _bigImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:path]];
        });
    }];
}
*/

- (IBAction)btnAction:(id)sender {
    //点击了内容，要跳转到宿主app
    NSURL *URL = [NSURL URLWithString:@"widgetDemo://data=123456"];
    [self.extensionContext openURL:URL completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"打开成功");
        }
    }];
}
//widget内存入数据
- (void)wirteData:(NSData *)data {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.widgetdemo.message"];
    [userDefaults setObject:data forKey:@"widgetImage"];
    BOOL isok = [userDefaults synchronize];
    NSLog(@"写入成功？%d",isok);
}

//实现折叠 与展开的代理；
- (void) widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    NSLog(@"maxWidth %f maxHeight %f",maxSize.width,maxSize.height);
    if (@available(iOS 10.0, *)) {
        if (activeDisplayMode == NCWidgetDisplayModeCompact) {
            //折叠
            self.preferredContentSize = CGSizeMake(maxSize.width, 100);
            [self handleVerb:YES];
            //处理一些操作
        } else {
            //展开
            self.preferredContentSize = CGSizeMake(maxSize.width, 200);
            [self handleVerb:NO];
            //处理一些操作
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)handleVerb:(BOOL)isVerb {
    if (isVerb) {
        _imageView.hidden = NO;
        _bigImageView.hidden = YES;
    } else {
        _imageView.hidden = YES;
        _bigImageView.hidden = NO;
    }
}

//加载数据
- (void)downloadImage:(NSString *)url completion:(void(^)(NSURL *path))completion {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSString *fileExt = [self fileExtensionForMediaType:@"image"];
    [[session downloadTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSError * error1;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *localURL = [NSURL fileURLWithPath:[location.path stringByAppendingString:fileExt]];
            [fileManager moveItemAtURL:location toURL:localURL error:&error1];
            if (!error1) {
                if (completion) {
                    completion(localURL);
                }
            }
        }
    }] resume];
    
}
- (NSString *)fileExtensionForMediaType:(NSString *)type {
    NSString *ext = type;
    if ([type isEqualToString:@"image"]) {
        ext = @"jpg";
    }
    if ([type isEqualToString:@"video"]) {
        ext = @"mp4";
    }
    if ([type isEqualToString:@"audio"]) {
        ext = @"mp3";
    }
    return [@"." stringByAppendingString:ext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

//    self.completionHandler = completionHandler;
    
    completionHandler(NCUpdateResultNewData);
}

@end
