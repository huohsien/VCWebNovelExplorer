//
//  ViewController.m
//  VCWebNovelExplorer
//
//  Created by victor on 10/19/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "ViewController.h"
#import "WKWebViewJavascriptBridge.h"

@interface ViewController ()

@property WKWebViewJavascriptBridge* bridge;

@end

@implementation ViewController {
    WKWebView *_webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchTextField.layer.borderWidth = 1.0f;
    self.searchTextField.layer.cornerRadius = 8.0f;
    self.searchTextField.layer.borderColor = [UIColor grayColor].CGColor;
    [self.view setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (_bridge) { return; }
    CGRect fullScreenRect = [[UIScreen mainScreen] bounds];
    NSString *jScript = [NSString stringWithFormat:@"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=%d'); meta.setAttribute('content', 'shrink-to-fit=YES'); document.getElementsByTagName('head')[0].appendChild(meta);", (int)fullScreenRect.size.width];
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;

    WKWebView* webView = [[WKWebView alloc] initWithFrame:self.webViewContainerView.bounds configuration:wkWebConfig];
    webView.navigationDelegate = self;
    [self.webViewContainerView addSubview:webView];
    
//    [WKWebViewJavascriptBridge enableLogging];
//    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:webView];
//    [_bridge setWebViewDelegate:self];
//    
//    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"testObjcCallback called: %@", data);
//        responseCallback(@"Response from testObjcCallback");
//    }];
//    
//    [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
//    
//    [self renderButtons:webView];
    
    NSURL *nsurl=[NSURL URLWithString:@"http://www.hjwzw.com"];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [webView loadRequest:nsrequest];

    
}

//- (void)renderButtons:(WKWebView*)webView {
//    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
//    
//    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
//    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view insertSubview:callbackButton aboveSubview:webView];
//    callbackButton.frame = CGRectMake(10, 400, 100, 35);
//    callbackButton.titleLabel.font = font;
//    
//    UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [reloadButton setTitle:@"Reload webview" forState:UIControlStateNormal];
//    [reloadButton addTarget:webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
//    [self.view insertSubview:reloadButton aboveSubview:webView];
//    reloadButton.frame = CGRectMake(110, 400, 100, 35);
//    reloadButton.titleLabel.font = font;
//}
//
//- (void)callHandler:(id)sender {
//    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
//    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
//        NSLog(@"testJavascriptHandler responded: %@", response);
//    }];
//}
//
//- (void)loadExamplePage:(WKWebView*)webView {
//
//    NSURL *nsurl=[NSURL URLWithString:@"http://www.hjwzw.com"];
//    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
//    [webView loadRequest:nsrequest];
//
//}
#pragma mark - WKNavigationDelegates

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    VCLOG(@"WKwebViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    VCLOG(@"WKwebViewDidFinishLoad");
    
//    [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(NSString *result, NSError *error) {
//        VCLOG(@"source code = %@", result);
//    }];
//    [webView evaluateJavaScript:@"document.getElementById('top1_Txt_Keywords').value = '一念永恒'" completionHandler:^(NSString *result, NSError *error) {
//        VCLOG(@"result = %@", result);
//        if (error) {
//            VCLOG(@"error: %@", error.debugDescription);
//        }
//        [webView evaluateJavaScript:@"Search('#top1_Txt_Keywords')" completionHandler:^(NSString *result, NSError *error) {
//            VCLOG(@"result = %@", result);
//            if (error) {
//                VCLOG(@"error: %@", error.debugDescription);
//            }
//            [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(NSString *result, NSError *error) {
//                VCLOG(@"source code = %@", result);
//            }];
//        }];
//    }];
}

#pragma mark - UIWebView delegates

-(void)webViewDidStartLoad:(UIWebView *)webView {
    VCLOG(@"UIwebViewDidStartLoad");
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    VCLOG(@"UIwebViewDidFinishLoad");
}
#pragma mark - text field delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    VCLOG();

    [self.view endEditing:YES];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    VCLOG();
} 
#pragma mark - callbacks
- (IBAction)searchButtonClicked:(id)sender {
    VCLOG();

    [self.view endEditing:YES];
}
@end
