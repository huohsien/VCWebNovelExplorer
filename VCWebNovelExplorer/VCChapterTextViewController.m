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

@implementation VCChapterTextViewController {
    
    // touch
    
    CGFloat _lastTouchedPointX;
    CGFloat _lastTouchedPointY;
    CFTimeInterval _startTime;
    CFTimeInterval _elapsedTime;
    
    BOOL _statusBarHidden;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    // set text to text view
    BOOL selectable = self.textView.isSelectable;
    [self.textView setSelectable:YES];
    
    NSMutableAttributedString *attrubutedString = [[NSMutableAttributedString alloc] initWithAttributedString:[self createAttributiedChapterContentStringFromString:self.text]];

    self.textView.attributedText = attrubutedString;
    
    [self.textView setSelectable:selectable];
    
    [self.textView setResponder:self];
    
    // set text to label
    [self.chapterTitleLabel setText:self.chapterTitle];
    
}

-(NSAttributedString *) createAttributiedChapterContentStringFromString:(NSString *)string {
    
    CGFloat _textLineSpacing = 14.0;
    CGFloat _charactersSpacing = 2.5;
    CGFloat _chapterContentFontSize = 26.0;
    
    
    NSMutableAttributedString *workingAttributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = _textLineSpacing;
    paragraphStyle.firstLineHeadIndent = _chapterContentFontSize * 2.0 + _charactersSpacing * 3.0;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    UIFont *font = [UIFont systemFontOfSize:_chapterContentFontSize];
    //    UIFont *font = [UIFont fontWithName:@"STFangSong" size:_chapterContentFontSize];
    
    
    UIColor *backgroundColor = [UIColor clearColor];
    UIColor *foregroundColor = self.textView.textColor;
    NSDictionary *attributionDict = @{NSParagraphStyleAttributeName : paragraphStyle , NSFontAttributeName : font, NSBackgroundColorAttributeName : backgroundColor, NSForegroundColorAttributeName : foregroundColor};
    
    [workingAttributedString addAttributes:attributionDict range:NSMakeRange(0, [string length])];
    [workingAttributedString addAttribute:NSKernAttributeName value:@(_charactersSpacing) range:NSMakeRange(0, [string length])];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithAttributedString:workingAttributedString];
    return attributedString;
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController.navigationBar setTranslucent:YES];

    [self showStatusBar:NO];

}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.textView setContentOffset:CGPointZero animated:NO];
}

-(BOOL)prefersStatusBarHidden {
    
    return _statusBarHidden;
}

- (void)showStatusBar:(BOOL)show {
    
    [UIView animateWithDuration:0.3 animations:^{
        _statusBarHidden = !show;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

#pragma mark - touch functions

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    _lastTouchedPointX = point.x;
    _lastTouchedPointY = point.y;
    _startTime = CACurrentMediaTime();
    
}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    _elapsedTime = CACurrentMediaTime() - _startTime;

    CGFloat pointX = point.x;
    CGFloat pointY = point.y;
    CGFloat xDisplacement = (pointX - _lastTouchedPointX);
    CGFloat yDisplacement = (pointY - _lastTouchedPointY);

    if (yDisplacement < 10 && yDisplacement > -10 && _elapsedTime < 1.5 && xDisplacement < 300) {
            
        [self toggleBars];
    
    }
}

#pragma mark - navigation bar

-(void) toggleBars {
    
    if (self.navigationController.navigationBar.hidden == YES) {
        // show bars
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self showStatusBar:YES];
            
        } completion:nil];
        
    } else {
        //hide bars
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self showStatusBar:NO];
            
        } completion:nil];
    }
    
    
}

@end
