//
//  ViewController.m
//  VCWebNovelExplorer
//
//  Created by victor on 10/19/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "ViewController.h"
#import "WKWebViewJavascriptBridge.h"

NSString* const baseUrl = @"http://www.hjwzw.com/";

@interface ViewController ()

@property WKWebViewJavascriptBridge* bridge;

@end

@implementation ViewController {
    NSMutableArray *_chapterList;
}

@synthesize bookName = _bookName;
@synthesize wkWebView = _wkWebView;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchTextField.layer.borderWidth = 1.0f;
    self.searchTextField.layer.cornerRadius = 8.0f;
    self.searchTextField.layer.borderColor = [UIColor grayColor].CGColor;
    [self.view setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (_bridge) { return; }

    _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
    _wkWebView.navigationDelegate = self;
    
    NSURL *nsurl=[NSURL URLWithString:baseUrl];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [_wkWebView loadRequest:nsrequest];

    
}

#pragma mark - WKNavigationDelegates

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    VCLOG();
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    VCLOG();
    if (_bookName == nil) {
        return;
    }
//    [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(NSString *result, NSError *error) {
//        VCLOG(@"source code = %@", result);
//    }];
    
    VCLOG(@"url=%@", webView.URL);
    
    if ([webView.URL.absoluteString isEqualToString:baseUrl]) {
        
        [webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('top1_Txt_Keywords').value = '%@'", _bookName] completionHandler:^(NSString *result, NSError *error) {
            
            [webView evaluateJavaScript:@"Search('#top1_Txt_Keywords')" completionHandler:^(NSString *result, NSError *error) {
                VCLOG(@"search book");
            }];
        }];
    }
    
    if ([webView.URL.absoluteString containsString:@"Book"] && ![webView.URL.absoluteString containsString:@"Chapter"]) {
        VCLOG(@"book found");
        [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(NSString *result, NSError *error) {
            NSString *relativePath = [self getRelativeLinkToBookChapterFromSource:result];
            if (relativePath) {
                VCLOG(@"go to content list");
                NSString *link = [NSString stringWithFormat:@"%@%@", baseUrl, relativePath];
                NSURL *nsurl=[NSURL URLWithString:link];
                NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
                [webView loadRequest:nsrequest];
            }
        }];

    }
    
    if ([webView.URL.absoluteString containsString:@"Book"] && [webView.URL.absoluteString containsString:@"Chapter"]) {
        VCLOG(@"list chapters");
        
        _chapterList = [NSMutableArray new];
        [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(NSString *result, NSError *error) {
            VCLOG(@"parse entry of chapter");
            NSRegularExpression *regex = [NSRegularExpression
                                          regularExpressionWithPattern:@"<a href=\"/Book/Read/[0-9]*,[0-9]*.*</a>"
                                          options:NSRegularExpressionCaseInsensitive
                                          error:&error];
            [regex enumerateMatchesInString:result options:0 range:NSMakeRange(0, [result length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
               
                NSRange range = [match rangeAtIndex:0];
                NSString *entry = [result substringWithRange:range];
//                VCLOG(@"entry = %@", entry);
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[self getPathFromString:entry], @"relative path", [self getChapterTitleFromString:entry], @"title", nil];
                [_chapterList addObject:dict];
//                VCLOG(@"path = %@", [self getPathFromString:entry]);
//                VCLOG(@"chapter title = %@", [self getChapterTitleFromString:entry]);
            }];
            NSLog(@"%@", _chapterList);
        }];
    }
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    VCLOG(@"error code = %ld", (long)error.code);
}

- (NSString *)getRelativeLinkToBookChapterFromSource:(NSString *)sourceString {
    
    NSError *error = nil;
    __block NSString *relativeLink;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"/Book/Chapter/[0-9]*"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:sourceString options:0 range:NSMakeRange(0, [sourceString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        NSRange range = [match rangeAtIndex:0];
        relativeLink = [sourceString substringWithRange:range];
    }];
    return relativeLink;
}

- (NSString *)getPathFromString:(NSString *)string {
    
    NSError *error = nil;
    __block NSString *path;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"<a\\s+href=\"([^\"]+)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:string options:0 range:NSMakeRange(0, [string length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        NSRange range = [match rangeAtIndex:1];
        path = [string substringWithRange:range];
    }];
    return path;
}

- (NSString *)getChapterTitleFromString:(NSString *)string {
    
    NSError *error = nil;
    __block NSString *chapterTitle;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@">(.*?)</a>"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:string options:0 range:NSMakeRange(0, [string length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        NSRange range = [match rangeAtIndex:1];
        chapterTitle = [string substringWithRange:range];
    }];
    return chapterTitle;
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
    
    _bookName = self.searchTextField.text;
    [_wkWebView reload];
    [self.view endEditing:YES];
}

@end
