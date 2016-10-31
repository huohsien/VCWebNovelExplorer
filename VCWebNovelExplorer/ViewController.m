//
//  ViewController.m
//  VCWebNovelExplorer
//
//  Created by victor on 10/19/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "ViewController.h"
#import "VCChapterTextViewController.h"
#import "VCTraditionalSimplifiedChineseExchanger.h"
#import "UIAlertController+Window.h"

@interface ViewController ()

@end

@implementation ViewController {
    VCWebNovelDownloader *_downloader;
    NSArray *_chapterArray;
    NSString *_text;
    long _indexOfSelectedRow;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;

    self.searchTextField.layer.borderWidth = 1.0f;
    self.searchTextField.layer.cornerRadius = 8.0f;
    self.searchTextField.layer.borderColor = [UIColor grayColor].CGColor;
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.searchTextField becomeFirstResponder];
    
    _indexOfSelectedRow = 0;
}

- (void)viewWillAppear:(BOOL)animated {

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"toVCChapterTextViewController"]) {
        
        VCChapterTextViewController  *viewController = segue.destinationViewController;
        viewController.text = _text;
        viewController.chapterTitle = [[_chapterArray objectAtIndex:_indexOfSelectedRow] objectForKey:@"title"];
    }
}

#pragma mark - table view

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_chapterArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_chapterArray.count > 0) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;
        
    } else {
        
        CGFloat padding = 4.0;
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, self.view.bounds.size.width - 2 * padding, self.view.bounds.size.height)];
        
        messageLabel.text = @"No Data";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *chapterTableIdentifier = @"chapterTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:chapterTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:chapterTableIdentifier];
    }
    NSDictionary *dict = [_chapterArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"title"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSUInteger chapterIndex = indexPath.row;
    _indexOfSelectedRow = chapterIndex;
    [_downloader downloadChapterNumber:chapterIndex];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - text field delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    VCLOG();

    [self searchButtonClicked:nil];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    VCLOG();
}

#pragma mark - callbacks

- (IBAction)searchButtonClicked:(id)sender {
    VCLOG();
    
    NSString *bookName = [VCTraditionalSimplifiedChineseExchanger getSimpleStringFromTraditionString:self.searchTextField.text];
    self.searchTextField.text = bookName;
    _downloader = [VCWebNovelDownloader downloadBookNamed:bookName withDelegate:self];
    [self.view endEditing:YES];
}

#pragma mark - VCWebNovelDownloaderDelegate

- (void)downloader:(VCWebNovelDownloader *)downloader didFinishRetrieveChapterList:(NSArray *)chapterList {

//    NSLog(@"chapter list = %@", chapterList);
    _chapterArray = chapterList;
    [self.tableView reloadData];
}

- (void)downloader:(VCWebNovelDownloader *)downloader encounterError:(NSError *)error {
    
    VCLOG(@"error = %@", error.debugDescription);
    [VCTool showAlertViewWithMessage:error.debugDescription];
}

-(void)downloader:(VCWebNovelDownloader *)downloader didDownloadChapterContent:(NSString *)chapterContent {

    _text = chapterContent;
    [self performSegueWithIdentifier:@"toVCChapterTextViewController" sender:self];
}

-(void)downloader:(VCWebNovelDownloader *)downloader statusUpdateForIsLoading:(BOOL)isLoading {
    
    VCLOG(@"isLoading = %@", isLoading ? @"Yes" : @"No");
    if (isLoading) {
        [VCTool showActivityView];
    } else {
        [VCTool hideActivityView];
    }
}


@end
