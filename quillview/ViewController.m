//
//  ViewController.m
//  quillview
//
//  Created by LIN on 2017/8/31.
//  Copyright © 2017年 hive. All rights reserved.
//

#import "ViewController.h"

#import "Masonry.h"
#import "DetailViewController.h"
#import "EditorViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)test1
{
    NSString *contents = @"{\"ops\":[{\"insert\":\"Quill uses classes for most inline styles.\\n\\nThe exception is \"},{\"attributes\":{\"background\":\"yellow\"},\"insert\":\"background\"},{\"insert\":\" and \"},{\"attributes\":{\"color\":\"purple\"},\"insert\":\"color\"},{\"insert\":\",\\nwhere it uses inline styles.\\n\\nThis \"},{\"attributes\":{\"font\":\"PingFang TC\",\"strike\":\"true\"},\"insert\":\"demo\"},{\"insert\":\" shows how to \"},{\"attributes\":{\"size\":\"32px\"},\"insert\":{\"formula\":\"change\"}},{\"insert\":\" this.\\n\"}]}";
    DetailViewController *vc = [[DetailViewController alloc] init];
    vc.contents = contents;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)test2
{
    NSString *contents = @"{\"ops\":[{\"insert\":{\"image\":\"http://img.mp.itc.cn/upload/20160621/b2404cc3b6604e5a95a47052b3cee690.jpg\"}},{\"insert\":\"\\n\"},{\"insert\":\"\\n\\n\"},{\"insert\":{\"video\":\"http://27.148.180.112/youku/656B524E5A39821ECCED660DD/030008010059B632B8D24130AC14D874F79433-1172-38F0-2CE6-9E1576C0346A.mp4?sid=050547043700010009958_00&sign=51d4e86bb0a01aa58925413eeb94f3f5&ctype=50\"}},{\"insert\":\"\\n\"},{\"insert\":\"\\n\\n\"}]}";
    DetailViewController *vc = [[DetailViewController alloc] init];
    vc.contents = contents;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)test3
{
    NSString *contents = @"{\"ops\":[{\"insert\":\"One Ring to Rule Them All\"},{\"attributes\":{\"header\":2},\"insert\":\"\\n\"},{\"attributes\":{\"link\":\"https://en.wikipedia.org/wiki/One_Ring\"},\"insert\":\"http://en.wikipedia.org/wiki/One_Ring\"},{\"insert\":\"\\n\\nThree Rings for the \"},{\"attributes\":{\"italic\":true},\"insert\":\"Elven-kings\"},{\"insert\":\" under the sky,\\nSeven for the \"},{\"attributes\":{\"underline\":true},\"insert\":\"Dwarf-lords\"},{\"insert\":\" in halls of stone,\\nNine for \"},{\"attributes\":{\"underline\":true},\"insert\":\"Mortal Men\"},{\"insert\":\", doomed to die,\\nOne for the \"},{\"attributes\":{\"underline\":true},\"insert\":\"Dark Lord\"},{\"insert\":\" on his dark throne.\\n\\nIn the Land of Mordor where the Shadows lie.\\nOne Ring to \"},{\"attributes\":{\"bold\":true},\"insert\":\"rule\"},{\"insert\":\" them all, One Ring to \"},{\"attributes\":{\"bold\":true},\"insert\":\"find\"},{\"insert\":\" them,\\nOne Ring to \"},{\"attributes\":{\"bold\":true},\"insert\":\"bring\"},{\"insert\":\" them all and in the darkness \"},{\"attributes\":{\"bold\":true},\"insert\":\"bind\"},{\"insert\":\" them.\\nIn the Land of Mordor where the Shadows lie.\\n\\n12345\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"222\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"333\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"444\\n555\"},{\"attributes\":{\"list\":\"bullet\"},\"insert\":\"\\n\"},{\"insert\":\"666\"},{\"attributes\":{\"list\":\"bullet\"},\"insert\":\"\\n\"},{\"insert\":\"777\"},{\"attributes\":{\"list\":\"bullet\"},\"insert\":\"\\n\"},{\"insert\":\"888\\n999\\n\\n\"}]}";
    DetailViewController *vc = [[DetailViewController alloc] init];
    vc.contents = contents;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)test4
{
    NSString *contents = @"{\"ops\":[{\"attributes\":{\"underline\":true},\"insert\":\"111\"},{\"attributes\":{\"bold\":true},\"insert\":\"222\"},{\"attributes\":{\"italic\":true},\"insert\":\"333\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"222444555\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"333\\n444\\n\"}]}";
    DetailViewController *vc = [[DetailViewController alloc] init];
    vc.contents = contents;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)test5
{
    NSString *contents = @"{\"ops\":[{\"insert\":\"1111\"},{\"attributes\":{\"header\":2},\"insert\":\"\\n\"},{\"insert\":\"123\"},{\"insert\":\"456\"},{\"attributes\":{\"header\":2,\"direction\":\"rtl\",\"indent\":1},\"insert\":\"\\n\"},{\"insert\":\"333\"},{\"attributes\":{\"script\":\"sub\"},\"insert\":\"333\"},{\"attributes\":{\"header\":3},\"insert\":\"\\n\"},{\"insert\":\"444\\n\"}]}";
    DetailViewController *vc = [[DetailViewController alloc] init];
    vc.contents = contents;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)test6
{
    NSString *contents = @"{\"ops\":[{\"insert\":\"111\"},{\"attributes\":{\"list\":\"bullet\"},\"insert\":\"\\n\"},{\"insert\":\"222\"},{\"attributes\":{\"indent\":1,\"list\":\"bullet\"},\"insert\":\"\\n\"},{\"insert\":\"333\"},{\"attributes\":{\"list\":\"bullet\"},\"insert\":\"\\n\"},{\"insert\":\"444\\n555\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"666\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"777\\n888\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"999\"},{\"attributes\":{\"indent\":2,\"list\":\"ordered\"},\"insert\":\"\\n\"}]}";
    DetailViewController *vc = [[DetailViewController alloc] init];
    vc.contents = contents;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)test7
{
    NSString *contents = @"{\"ops\":[{\"insert\":\"888\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"999\"},{\"attributes\":{\"indent\":1,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"1\"},{\"attributes\":{\"indent\":2,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"1\"},{\"attributes\":{\"indent\":3,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"2\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"11\"},{\"attributes\":{\"indent\":1,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"22\"},{\"attributes\":{\"indent\":2,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"22\"},{\"attributes\":{\"indent\":1,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"33\"},{\"attributes\":{\"indent\":1,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"33\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"444\"},{\"attributes\":{\"indent\":2,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"23323\"},{\"attributes\":{\"indent\":3,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"2332\"},{\"attributes\":{\"indent\":1,\"list\":\"ordered\"},\"insert\":\"\\n\"}]}";
    DetailViewController *vc = [[DetailViewController alloc] init];
    vc.contents = contents;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn1 setTitle:@"font color test" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(test1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn2 setTitle:@"image video test" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(test2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64 + 60);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn3 setTitle:@"link test" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(test3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64 + 60 * 2);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
    
//    UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeSystem];
//    [btn4 setTitle:@"test4" forState:UIControlStateNormal];
//    [btn4 addTarget:self action:@selector(test4) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn4];
//    [btn4 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(64 + 60 * 3);
//        make.centerX.equalTo(self.view);
//        make.width.mas_equalTo(60);
//        make.height.mas_equalTo(44);
//    }];
//    
//    UIButton *btn5 = [UIButton buttonWithType:UIButtonTypeSystem];
//    [btn5 setTitle:@"test5" forState:UIControlStateNormal];
//    [btn5 addTarget:self action:@selector(test5) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn5];
//    [btn5 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(64 + 60 * 4);
//        make.centerX.equalTo(self.view);
//        make.width.mas_equalTo(60);
//        make.height.mas_equalTo(44);
//    }];
//    
//    UIButton *btn6 = [UIButton buttonWithType:UIButtonTypeSystem];
//    [btn6 setTitle:@"test6" forState:UIControlStateNormal];
//    [btn6 addTarget:self action:@selector(test6) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn6];
//    [btn6 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(64 + 60 * 5);
//        make.centerX.equalTo(self.view);
//        make.width.mas_equalTo(60);
//        make.height.mas_equalTo(44);
//    }];
    
    UIButton *btn7 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn7 setTitle:@"list test" forState:UIControlStateNormal];
    [btn7 addTarget:self action:@selector(test7) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn7];
    [btn7 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64 + 60 * 3);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
    
    UIButton *btn8 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn8 setTitle:@"quill editor" forState:UIControlStateNormal];
    [btn8 addTarget:self action:@selector(openEditor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn8];
    [btn8 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64 + 60 * 4);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
}

- (void)openEditor
{
    EditorViewController *vc = [[EditorViewController alloc] init];
    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
}

@end
