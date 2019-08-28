//
//  ViewController.m
//  NetChina
//
//  Created by bindx on 2019/4/29.
//  Copyright © 2019 bindx. All rights reserved.
//

#import "ViewController.h"
#import <LinkAccount_Lib/LinkAccount.h>

@interface ViewController()

@property (strong, nonatomic) LMCustomModel *model;
@property (copy, nonatomic) NSMutableString *logStr;
@property (copy,nonatomic) NSString *token;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _logStr = [[NSMutableString alloc]init];
}

//预取号,登陆前60s调用此方法
- (IBAction)getphoneNumber:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    
    [self addLog:@"取号中....（请勿重复点击）"];

    [LMAuthSDKManager getMobileAuthWithTimeout:999 complete:^(NSDictionary * _Nonnull resultDic) {
    
        [weakSelf addLog:[self convertToJsonData:resultDic]];
        
    }];
}

- (IBAction)showLogin:(id)sender {
    
    __weak typeof(self) weakSelf = self;
      //自定义Model
    _model = [LMCustomModel new];
    //LOGO
    _model.logoImage = [UIImage imageNamed:@"logo"];
    //是否隐藏其他方式登陆按钮
    _model.changeBtnIsHidden = NO;
    //登录按钮文字
    _model.loginBtnText = @"一键登录";
    //自定义隐私条款1
    _model.privacyOne   = @[@"用户服务条款1",@"https://www.baidu.com"];
    //自定义隐私条款2
    _model.privacyTwo   = @[@"用户服务条款2",@"https://www.baidu.com"];
    //隐私条款复选框非选中状态
    _model.uncheckedImg = [UIImage imageNamed:@"checkBox_unSelected"];
    //隐私条款复选框选中状态
    _model.checkedImg   = [UIImage imageNamed:@"checkBox_selected"];
    //登陆按钮
    _model.logBtnImgs   = [NSArray arrayWithObjects:[UIImage imageNamed:@"loginBtn_Nor"],[UIImage imageNamed:@"loginBtn_Dis"] ,[UIImage imageNamed:@"loginBtn_Pre"],nil];
    //返回按钮
    _model.navReturnImg = [UIImage imageNamed:@"goback_nor"];
    //背景图片
    _model.authPageBackgroundImage = [self createImageWithColor:[UIColor groupTableViewBackgroundColor]];
    //标题
    _model.navTitle = [[NSAttributedString alloc]initWithString:@"一键登录" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //状态栏颜色
    _model.statusBarStyle = UIBarStyleBlackOpaque;
    //导航栏颜色
    _model.navColor = [UIColor blackColor];
    //logo距离屏幕顶部位置
    _model.logoOffsetY = 30;
    //隐私协议距离屏幕底部位置
    _model.privacyOffsetY = 10;
    //隐私协议，默认颜色和高亮颜色
    _model.appPrivacyColor = @[[UIColor grayColor],[UIColor redColor]];

    //自定义控件
    _model.authViewBlock = ^(UIView *customView) {
        NSArray *btnTitles = @[@"微信登录",@"微博登录",@"QQ登录"];
        for (int i = 0; i<3; i++) {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(58 + 110*i, 500, 80, 80)];
            [btn setBackgroundColor:[UIColor redColor]];
            [btn setTitle:btnTitles[i] forState:(UIControlStateNormal)];
            [btn setTag:i + 1000];
            [btn addTarget:weakSelf action:@selector(customBtn:) forControlEvents:UIControlEventTouchDown];
            [btn setTintColor:[UIColor blackColor]];
            [customView addSubview:btn];
        }
    };
    
    //一键登陆
    [[LMAuthSDKManager sharedSDKManager] getLoginTokenWithController:self model:_model timeout:888 complete:^(NSDictionary * _Nonnull resultDic) {
        
        [weakSelf addLog:[self convertToJsonData:resultDic]];

        if ([resultDic[@"resultCode"] isEqualToString:SDKStatusCodeSuccess]) {
            
            NSLog(@"登陆成功");
            
            [[LMAuthSDKManager sharedSDKManager] closeAuthView];
            
        }else{
            
            NSLog(@"%@",resultDic);
            
        }
        
    } otherLogin:^{
        
        [weakSelf addLog:@"用户选择使用其他方式登录"];
        
    }];
}

//获取本机号码校验
- (IBAction)phoneNumValidation:(id)sender {
    [[LMAuthSDKManager sharedSDKManager]getAccessCodeWithcomplete:^(NSDictionary * _Nonnull resultDic) {
        self.token = resultDic[@"accessCode"];
        [self addLog:[self convertToJsonData:resultDic]];
    }];
}

//自定义view点击方法

- (void)customBtn:(UIButton *)btn{
    NSString *str = [NSString stringWithFormat:@"第%ld个按钮被点击了",(long)btn.tag];
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"标题" message:str delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [[LMAuthSDKManager sharedSDKManager] closeAuthView];
}

- (void)addLog:(NSString *)str{
    [self.logStr appendFormat:@"%@:%@\n\n",[self getCurrentTimes],str];
    self.textView.text = self.logStr;
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 1)];
}

-(NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

-(NSDictionary *)convertToDictionary:(NSString *)jsonStr{
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return tempDic;
}


//获取当前的时间
-(NSString*)getCurrentTimes{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

- (UIImage*) createImageWithColor: (UIColor*) color{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
