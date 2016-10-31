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
@synthesize isLoading = _isLoading;

- (instancetype)initWithBookNamed:(NSString *)bookName {
    self = [super init];
    if (self) {
        
        _bookName = bookName;
        
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
        _wkWebView.navigationDelegate = self;
        _isLoading = YES;
        NSURL *nsurl=[NSURL URLWithString:baseUrl];
        NSURLRequest *nsrequest = [NSURLRequest requestWithURL:nsurl];
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
    
    _isLoading = YES;
    NSURL *nsurl=[NSURL URLWithString:link];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [_wkWebView loadRequest:nsrequest];
}

#pragma mark - WKNavigationDelegates

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    VCLOG();
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
        
    if (_bookName == nil) {
        return;
    }
    
    VCLOG(@"url=%@", webView.URL);
    
    if ([webView.URL.absoluteString isEqualToString:baseUrl]) {
        
        VCLOG(@"searching book");
        [webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('top1_Txt_Keywords').value = '%@'; Search('#top1_Txt_Keywords');", _bookName] completionHandler:^(NSString *result, NSError *error) {
            
            
            if (error) {
                VCLOG(@"error = %@", error.debugDescription);
            } else {
                VCLOG(@"finish searching book");
            }
            
        }];
    } else if ([webView.URL.absoluteString containsString:@"Book"] && ![webView.URL.absoluteString containsString:@"Chapter"] && ![webView.URL.absoluteString containsString:@"Read"]) {
        
        VCLOG(@"book found");
        [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(NSString *result, NSError *error) {
        
            NSString *relativePath = [self getRelativeLinkToBookChapterFromSource:result];
            if (relativePath) {
            
                VCLOG(@"found the link of the page that contains the chapter list of the book. navigate to that page");
                
                NSString *link = [NSString stringWithFormat:@"%@%@", baseUrl, relativePath];
                NSURL *nsurl=[NSURL URLWithString:link];
                NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
                [webView loadRequest:nsrequest];
            }
        }];
        
    } else if ([webView.URL.absoluteString containsString:@"Book/Chapter"]) {
        
        VCLOG(@"on the page that contains the chapter list");
        
        __block NSMutableArray *chapterList = [NSMutableArray new];
        
        [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(NSString *result, NSError *error) {
        
            VCLOG(@"parse to find meta data of each chapter. store them in a plist structure");
            
            NSRegularExpression *regex = [NSRegularExpression
                                          regularExpressionWithPattern:@"<a href=\"/Book/Read/[0-9]*,[0-9]*.*</a>"
                                          options:NSRegularExpressionCaseInsensitive
                                          error:&error];
            
            [regex enumerateMatchesInString:result options:0 range:NSMakeRange(0, [result length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                
                NSRange range = [match rangeAtIndex:0];
                NSString *entry = [result substringWithRange:range];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[self getPathFromString:entry], @"path", [self getChapterTitleFromString:entry], @"title", [self getUpdateTimeFromString:entry], @"time", nil];
                [chapterList addObject:dict];

                
            }];
            
            _chapterList = [NSArray arrayWithArray:chapterList];
            _isLoading = NO;
            
            VCLOG(@"call the delegate function:didFinishRetrieveChapterList");
            [self.delegate downloader:self didFinishRetrieveChapterList:_chapterList];
        }];
        
    } else if ([webView.URL.absoluteString containsString:@"Book/Read"]) {
        
        VCLOG(@"on the page that contains content of the requested chapter");

        [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(NSString *result, NSError *error) {
        
            VCLOG(@"strip content from the page and store it in a nsstring");
    
            _isLoading = NO;
            [self.delegate downloader:self didDownloadChapterContent:[self getContentString:result]];
        }];
    
    } else {
        
        VCLOG(@"on unknown state!!");
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"VCWebNovelDownloader is in an unknown state" forKey:@"description"];
        NSError *error = [NSError errorWithDomain:@"VCWebNovelDownloader error" code:-1 userInfo:userInfo];
        [self.delegate downloader:self encounterError:error];

    }
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    VCLOG(@"call delegate function downloader did Fail Retrieve Chapter List With Error");
    
    _isLoading = NO;
    [self.delegate downloader:self encounterError:error];
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
