//
//  ViewController.m
//  NAU_LIPENG_FinalProject
//
//  Created by lee on 2023/5/22.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "LPRequestBlock.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *LPAPICaptureView;
@property (weak, nonatomic) IBOutlet UIView *LPWebCaptureView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *LPMainSwitchView;

/*********LPAPICaptureView********/
@property (weak, nonatomic) IBOutlet UISegmentedControl *LPGetOrPostSwitchView;
@property (weak, nonatomic) IBOutlet UITextField *LPAPIUrlTextView;
@property (weak, nonatomic) IBOutlet UITextView *LPRequestBodyTextView;
@property (weak, nonatomic) IBOutlet UITextView *LPRequestResultTextView;
@property (weak, nonatomic) IBOutlet UITextView *LPBlockRequestTextView;
/*********************************/




/*********LPWebCaptureView********/
@property (weak, nonatomic) IBOutlet UITextField *LPWebUrlTextView;
@property (weak, nonatomic) IBOutlet UITextView *LPBlockWebRequestTextView;
@property (weak, nonatomic) IBOutlet UITextView *LPBlockWebResponseTextView;
@property (weak, nonatomic) IBOutlet UIWebView *LPWebBrowserView;

/*********************************/

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self switchMainTabToIndex];
    [self switchGetOrPostMethod];
    [self requestBlock];
}


#pragma mark 拦截全局请求
- (void)requestBlock{
//    [ZXRequestBlock handleRequest:^NSURLRequest *(NSURLRequest *request) {
//        NSLog(@"拦截到请求-%@",request);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.blockTv.text = [self.blockTv.text stringByAppendingString:[NSString stringWithFormat:@"拦截到请求--%@\n",request]];
//        });
//        return request;
//    }];
    
    
    //拦截请求与响应
    [LPRequestBlock handleRequest:^NSURLRequest *(NSURLRequest *request) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (0 == self.LPMainSwitchView.selectedSegmentIndex) {
                [self displayLogsOnTextView:self.LPBlockRequestTextView withStr:[NSString stringWithFormat:@"拦截到请求--%@\n",request]];
            }else{
                [self displayLogsOnTextView:self.LPBlockWebRequestTextView withStr:[NSString stringWithFormat:@"拦截到请求--%@\n",request]];
            }
        });
        return request;
    } responseBlock:^NSData *(NSURLResponse *response, NSData *data) {
        //如果为http请求，则响应为NSHTTPURLResponse，可进行强制转换
        //这里返回的data就是最终的响应数据，可以自行修改
        //可以通过[str dataUsingEncoding:NSUTF8StringEncoding];来将字符串转NSData
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *blockResponseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (1 == self.LPMainSwitchView.selectedSegmentIndex) {
            [self displayLogsOnTextView:self.LPBlockWebResponseTextView withStr:[NSString stringWithFormat:@"拦截到响应url-%@\n 拦截到响应数据--%@\n",httpResponse.URL, blockResponseString]];
        }else{
            [self displayLogsOnTextView:self.LPBlockRequestTextView withStr:[NSString stringWithFormat:@"拦截到响应url-%@\n 拦截到响应数据--%@\n",httpResponse.URL, blockResponseString]];
        }
        return data;
    }];
    
}


#pragma -mark 按钮响应事件
- (IBAction)mainTabSwitch:(id)sender {
    [self switchMainTabToIndex];
}
- (IBAction)getOrPostMethodSwitch:(id)sender {
    [self switchGetOrPostMethod];
}

- (IBAction)sendAPIButtonClick:(id)sender {
    if(!self.LPAPIUrlTextView.text.length){
        [self showAlertWithStr:@"请输入网址"];
        return;
    }
    if (0 == self.LPMainSwitchView.selectedSegmentIndex) {
        //get请求
        [self reqWithMethod:0];
    }else{
        //post请求
        [self reqWithMethod:1];
    }
}

- (IBAction)goToWebButtonClick:(id)sender {
    if(!self.LPWebUrlTextView.text.length){
        [self showAlertWithStr:@"请输入网址"];
        return;
    }
    [self.LPWebBrowserView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.LPWebUrlTextView.text]]];
}

- (IBAction)clearBlockWebRequestText:(id)sender {
    self.LPBlockWebRequestTextView.text = @"";
}

- (IBAction)clearBlockWebReponseText:(id)sender {
    self.LPBlockWebResponseTextView.text = @"";
}

- (IBAction)enableHttpDnsAction:(id)sender {
    UIButton *curBtn = (UIButton *)sender;
    if([curBtn.currentTitle isEqualToString:@"启用HTTPDNS"]){
        [curBtn setTitle:@"禁用HTTPDNS" forState:UIControlStateNormal];
        curBtn.backgroundColor = [UIColor redColor];
       [LPRequestBlock enableHttpDns];
    }else{
        [curBtn setTitle:@"启用HTTPDNS" forState:UIControlStateNormal];
        curBtn.backgroundColor = [UIColor colorWithRed:72/255.0 green:185/255.0 blue:34/255.0 alpha:1];
        [LPRequestBlock disableHttpDns];
    }
}

- (IBAction)enableHttpProxy:(id)sender {
    UIButton *curBtn = (UIButton *)sender;
    if([curBtn.currentTitle isEqualToString:@"禁止代理网络"]){
        [curBtn setTitle:@"已禁止代理网络" forState:UIControlStateNormal];
        curBtn.backgroundColor = [UIColor redColor];
        [LPRequestBlock disableHttpProxy];
    }else{
        [curBtn setTitle:@"禁止代理网络" forState:UIControlStateNormal];
        curBtn.backgroundColor = [UIColor colorWithRed:72/255.0 green:185/255.0 blue:34/255.0 alpha:1];
        [LPRequestBlock enableHttpProxy];
    }
}

#pragma mark - Private
#pragma mark 显示弹窗
-(void)showAlertWithStr:(NSString *)str{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)displayLogsOnTextView:(UITextView *)textView withStr:(NSString *)str{
    textView.text = [textView.text stringByAppendingString:str];
    CGPoint bottomOffset = CGPointMake(0, textView.contentSize.height - textView.bounds.size.height);
    [textView setContentOffset:bottomOffset animated:NO];
}

-(void)switchMainTabToIndex{
    if (0 == self.LPMainSwitchView.selectedSegmentIndex) {
        self.LPAPICaptureView.hidden = NO;
        self.LPWebCaptureView.hidden = YES;
    }else{
        self.LPAPICaptureView.hidden = YES;
        self.LPWebCaptureView.hidden = NO;
    }
}

-(void)switchGetOrPostMethod{
    if (0 == self.LPGetOrPostSwitchView.selectedSegmentIndex) {
        self.LPRequestBodyTextView.editable = NO;
        self.LPRequestBodyTextView.backgroundColor = UIColor.grayColor;
        self.LPRequestBodyTextView.text = @"";
    }else{
        self.LPRequestBodyTextView.editable = YES;
        self.LPRequestBodyTextView.backgroundColor = UIColor.yellowColor;
    }
}

-(void)reqWithMethod:(int)method{
    NSURL *url = [NSURL URLWithString:self.LPAPIUrlTextView.text];
    NSMutableURLRequest *mr = [NSMutableURLRequest requestWithURL:url];
    if(method == 0){
        mr.HTTPMethod = @"GET";
    }else{
        mr.HTTPMethod = @"POST";
        mr.HTTPBody = [self.LPRequestBodyTextView.text dataUsingEncoding:NSUTF8StringEncoding];
    }
    mr.timeoutInterval = 10;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [NSURLConnection sendAsynchronousRequest:mr queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (connectionError) {
            [self displayLogsOnTextView:self.LPRequestResultTextView withStr:[NSString stringWithFormat:@"请求失败--%@\n",connectionError]];
            NSLog(@"请求失败--%@",connectionError);
            return;
        }
        NSString *responseStr = [[NSString alloc]initWithData:data encoding:kCFStringEncodingUTF8];
        [self displayLogsOnTextView:self.LPRequestResultTextView withStr:[NSString stringWithFormat:@"请求成功--%@\n",responseStr]];
        NSLog(@"请求成功--%@",responseStr);
    }];
}

@end
