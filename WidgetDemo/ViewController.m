//
//  ViewController.m
//  WidgetDemo
//
//  Created by shenzhenshihua on 2018/3/12.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readMessage) name:UIApplicationDidBecomeActiveNotification object:nil];
    // Do any additional setup after loading the view, typically from a nib.
}
//宿主app内读取数据
- (void)readMessage {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.widgetdemo.message"];
    NSData * date = [userDefaults objectForKey:@"widgetImage"];
    _imageView.image = [UIImage imageWithData:date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
