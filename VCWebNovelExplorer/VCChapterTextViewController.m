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

    
    BOOL selectable = self.textView.isSelectable;
    [self.textView setSelectable:YES];
    
    self.textView.text = self.text;
    
    [self.textView setSelectable:selectable];
    
    [self.textView setResponder:self];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
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
    
    CGRect frame = self.navigationController.navigationBar.bounds;
    
    if (self.navigationController.navigationBar.hidden == YES) {
        // show bars
        
        self.navigationController.navigationBar.hidden = NO;
        
        // prepare the animation for both the navi and the tool bars appearing from outside visible screen
        [self.navigationController.navigationBar setFrame:CGRectMake(0, -20 - frame.size.height, frame.size.width, frame.size.height)];
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self showStatusBar:YES];
            [self.navigationController.navigationBar setFrame:CGRectMake(0, 20, frame.size.width, frame.size.height)];
            
        } completion:nil];
        
    } else {
        //hide bars
        
        // prepare the animation for both the navi and the tool bars disappearing from the visible screen
        [self.navigationController.navigationBar setFrame:CGRectMake(0, 20, frame.size.width, frame.size.height)];
        
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self showStatusBar:NO];
            [self.navigationController.navigationBar setFrame:CGRectMake(0,  -frame.size.height - 20, frame.size.width, frame.size.height)];
            
        } completion:^(BOOL finished) {
            self.navigationController.navigationBar.hidden = YES;
            
        }];
    }
    
    
}

@end
