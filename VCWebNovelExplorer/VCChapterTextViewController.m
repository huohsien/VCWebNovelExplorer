//
//  VCChapterTextViewController.m
//  VCWebNovelExplorer
//
//  Created by victor on 10/31/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "VCChapterTextViewController.h"

@interface VCChapterTextViewController ()

@end

@implementation VCChapterTextViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    
    BOOL selectable = self.textView.isSelectable;
    [self.textView setSelectable:YES];
    
    self.textView.text = self.text;
    
    [self.textView setSelectable:selectable];
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.textView setContentOffset:CGPointZero animated:NO];
}
@end
