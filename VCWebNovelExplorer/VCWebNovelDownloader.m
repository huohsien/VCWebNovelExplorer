//
//  VCWebNovelDownloader.m
//  VCWebNovelExplorer
//
//  Created by victor on 10/30/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCWebNovelDownloader.h"

NSString* const baseUrl = @"http://www.hjwzw.com/";

@implementation VCWebNovelDownloader

@synthesize bookName = _bookName;
@synthesize wkWebView = _wkWebView;
@synthesize chapterList = _chapterList;

- (instancetype)initWithBookNamed:(NSString *)bookName {
    self = [super init];
    if (self) {
        
        _bookName = bookName;
        
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
        _wkWebView.navigationDelegate = self;
        
        NSURL *nsurl=[NSURL URLWithString:baseUrl];
        NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
        [_wkWebView loadRequest:nsrequest];
    }
    return self;
}

+ (instancetype)downloadBookNamed:(NSString *)bookName {
    
    return [[self alloc] initWithBookNamed:bookName];
}

- (void)downloadChapterNumber:(NSUInteger)number {

    if (number > _chapterList.count - 1) return;
    NSString *path = [[_chapterList objectAtIndex:number] objectForKey:@"path"];
    NSString *link = [NSString stringWithFormat:@"%@%@", baseUrl, path];
    VCLOG(@"go to %@", link);
    NSURL *nsurl=[NSURL URLWithString:link];
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
//        [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(NSString *result, NSError *error) {
//            VCLOG(@"source code = %@", result);
//        }];
    
    VCLOG(@"url=%@", webView.URL);
    
    if ([webView.URL.absoluteString isEqualToString:baseUrl]) {
        
        [webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('top1_Txt_Keywords').value = '%@'", _bookName] completionHandler:^(NSString *result, NSError *error) {
            
            [webView evaluateJavaScript:@"Search('#top1_Txt_Keywords')" completionHandler:^(NSString *result, NSError *error) {
                VCLOG(@"search book");
            }];
        }];
    }
    
    if ([webView.URL.absoluteString containsString:@"Book"] && ![webView.URL.absoluteString containsString:@"Chapter"] && ![webView.URL.absoluteString containsString:@"Read"]) {
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
    
    if ([webView.URL.absoluteString containsString:@"Book/Chapter"]) {
        VCLOG(@"list chapters");
        
        __block NSMutableArray *chapterList = [NSMutableArray new];
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
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[self getPathFromString:entry], @"path", [self getChapterTitleFromString:entry], @"title", [self getUpdateTimeFromString:entry], @"time", nil];
                [chapterList addObject:dict];
//                VCLOG(@"path = %@", [self getPathFromString:entry]);
//                VCLOG(@"chapter title = %@", [self getChapterTitleFromString:entry]);
//                VCLOG(@"update time = %@", [self getUpdateTimeFromString:entry]);
                
            }];
            _chapterList = [NSArray arrayWithArray:chapterList];
            VCLOG(@"call delegate fuction downloader did finish retrieve chapter list");
            [self.delegate downloader:self didFinishRetrieveChapterList:_chapterList];
        }];
    }
    
    if ([webView.URL.absoluteString containsString:@"Book/Read"]) {
        [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(NSString *result, NSError *error) {
            VCLOG(@"strip content string from the html");
//            VCLOG(@"content = %@",[self getContentString:result]);
            [self.delegate downloader:self didDownloadChapterContent:[self getContentString:result]];
        }];

    }
    
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    VCLOG(@"call delegate function downloader did Fail Retrieve Chapter List With Error");
    [self.delegate downloader:self didFailRetrieveChapterListWithError:error];
}

#pragma mark - parsing tools

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

- (NSString *)getUpdateTimeFromString:(NSString *)string {
    
    NSError *error = nil;
    __block NSString *updateTime;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"更新时间:\\s+(.*)\""
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    
    [regex enumerateMatchesInString:string options:0 range:NSMakeRange(0, [string length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        NSRange range = [match rangeAtIndex:1];
        updateTime = [string substringWithRange:range];
    }];
    return updateTime;
}

- (NSString *)getContentString:(NSString *)string {
    
    NSMutableString *result = [NSMutableString stringWithCapacity:5000];
    NSRange pRange = NSMakeRange(0, [string length]);
    NSRange endPRange;
    int skipTimes = 1;
    
    while (YES) {
        // Determine "<p>" location
        pRange = [string rangeOfString:@"<p>" options:NSCaseInsensitiveSearch range:pRange];
        
        if (pRange.location != NSNotFound) {
            // Determine "</p>" location according to "<p>" location
            
            endPRange.location = pRange.length + pRange.location;
            endPRange.length   = [string length] - endPRange.location;
            endPRange = [string rangeOfString:@"</p>" options:NSCaseInsensitiveSearch range:endPRange];
            
            if (endPRange.location != NSNotFound) {
                // Tags found: retrieve string between them
                pRange.location += pRange.length;
                pRange.length = endPRange.location - pRange.location;
                
                NSString *paragraph = [string substringWithRange:pRange];
                paragraph = [[paragraph componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
                if (skipTimes == 0) {
                    [result appendFormat:@"%@\n", paragraph];
                } else {
                    skipTimes--;
                }
        
                pRange.location = NSMaxRange(pRange);
                pRange.length = [string length] - pRange.location;
            } else break;
            
        } else break;
    }
    return result;
}
@end
