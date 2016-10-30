//
//  VCWebNovelDownloader.h
//  VCWebNovelExplorer
//
//  Created by victor on 10/30/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class VCWebNovelDownloader;
@protocol VCWebNovelDownloaderDelegate <NSObject>

- (void)downloader:(VCWebNovelDownloader *)downloader didFinishRetrieveChapterList:(NSArray *)chapterList;
- (void)downloader:(VCWebNovelDownloader *)downloader didFailRetrieveChapterListWithError:(NSError *)error;
- (void)downloader:(VCWebNovelDownloader *)downloader didDownloadChapterContent:(NSString *)chapterContent;

@end

@interface VCWebNovelDownloader : NSObject<WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *wkWebView;
@property (strong, nonatomic) NSString *bookName;
@property (strong, nonatomic) NSArray *chapterList;
@property (strong, nonatomic) id<VCWebNovelDownloaderDelegate>delegate;

+ (instancetype) downloadBookNamed:(NSString *)bookName;
- (void) downloadChapterNumber:(NSUInteger)number;

@end
