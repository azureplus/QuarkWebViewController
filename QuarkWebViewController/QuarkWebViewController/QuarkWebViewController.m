//
//  QuarkWebViewController.m
//  QuarkWebViewController
//
//  Created by lanfeng on 2017/11/27.
//  Copyright © 2017年 lanfeng. All rights reserved.
//

#import "QuarkWebViewController.h"
#import <WebKit/WebKit.h>
#import <NJKWebViewProgress.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface QuarkWebViewController ()<NJKWebViewProgressDelegate, UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) UIView *currentWebView;
@property (nonatomic, strong) UIWebView *uiWebView;
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) JPWebViewType webViewType;
@property (nonatomic, strong) NJKWebViewProgress *uiwebViewProgress;
@property (nonatomic, strong) WKWebViewConfiguration *wkConfig;
@property (nonatomic, strong) NSString *url;
@end

@implementation QuarkWebViewController
#pragma mark - lifecycle
- (instancetype)initWith:(JPWebViewType)webViewType url:(NSString *)url {
    if (self = [super init]) {
        self.webViewType = webViewType;
        self.url = url;
        self.view.backgroundColor = [UIColor whiteColor];
        switch (self.webViewType) {
            case JPWebViewTypeUIWebView:
            {
                self.currentWebView = self.uiWebView;
                self.uiWebView.delegate = self.uiwebViewProgress;
            }
                break;
            case JPWebViewTypeWKWebView:
            {
                self.currentWebView = self.wkWebView;
                [self.currentWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
            }
                break;
            case JPWebViewTypeSonicWebView:
            {}
                break;
            default:
                self.currentWebView = self.uiWebView;
        }
        [self.view addSubview:self.currentWebView];
        [self.view addSubview:self.progressView];
        
        [self LF_setupSubviews];
        [self startLoad];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    if (_wkWebView) {
        [self.currentWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
}

#pragma mark private methods
- (void)LF_setupSubviews {
    
}

- (void)startLoad {
    NSString *urlString = @"http://www.baidu.com";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.timeoutInterval = 15.0f;
//    [self.wkWebView loadRequest:request];
    switch (self.webViewType) {
        case JPWebViewTypeUIWebView:
        {
            [self.uiWebView loadRequest:request];
        }
            break;
        case JPWebViewTypeWKWebView:
        {
            [self.wkWebView loadRequest:request];
        }
            break;
        case JPWebViewTypeSonicWebView:
        {}
            break;
    }
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        switch (self.webViewType) {
            case JPWebViewTypeUIWebView:
            {
                
            }
                break;
            case JPWebViewTypeWKWebView:
            {
                self.progressView.progress = self.wkWebView.estimatedProgress;
            }
                break;
            case JPWebViewTypeSonicWebView:
            {}
                break;
            
                
        }
//        self.progressView.progress = self.wkWebView.estimatedProgress;
        if (self.progressView.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
//                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
                
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKNavigationDelegate
//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
//    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}

//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
    //加载完成后隐藏progressView
    //self.progressView.hidden = YES;
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败");
    //加载失败同样需要隐藏progressView
    //self.progressView.hidden = YES;
}

#pragma mark - UIWebViewDelegate
// 网页开始加载的时候调用
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"开始加载网页");
    self.progressView.hidden = NO;
    [self.view bringSubviewToFront:self.progressView];
}

// 网页加载完成的时候调用
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"加载完成");
}

// 网页加载出错的时候调用
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"加载失败");
}

// 网页中的每一个请求都会被触发这个方法，返回NO代表不执行这个请求(常用于JS与iOS之间通讯)
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//
//}

#pragma mark - NJKWebViewProgress
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:NO];
    if (self.progressView.progress == 1) {
        __weak typeof (self)weakSelf = self;
        [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{

        } completion:^(BOOL finished) {
            weakSelf.progressView.hidden = YES;
            
        }];
    }
}



#pragma mark - getters and setters
- (UIWebView *)uiWebView {
    if (!_uiWebView) {
        _uiWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight)];
    }
    return _uiWebView;
}

- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight) configuration:self.wkConfig];
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
    }
    return _wkWebView;
}

- (WKWebViewConfiguration *)wkConfig {
    if (!_wkConfig) {
        _wkConfig = [[WKWebViewConfiguration alloc] init];
        _wkConfig.allowsInlineMediaPlayback = YES;
        _wkConfig.allowsPictureInPictureMediaPlayback = YES;
    }
    return _wkConfig;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 2)];
        _progressView.backgroundColor = [UIColor blueColor];
//        _progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    }
    return _progressView;
}

- (NJKWebViewProgress *)uiwebViewProgress {
    if (!_uiwebViewProgress) {
        _uiwebViewProgress = [[NJKWebViewProgress alloc] init];
        _uiwebViewProgress.webViewProxyDelegate = self;
        _uiwebViewProgress.progressDelegate = self;
    }
    return _uiwebViewProgress;
}

@end