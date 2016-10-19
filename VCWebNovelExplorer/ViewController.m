//
//  ViewController.m
//  VCWebNovelExplorer
//
//  Created by victor on 10/19/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchTextField.layer.borderWidth = 1.0f;
    self.searchTextField.layer.cornerRadius = 8.0f;
    self.searchTextField.layer.borderColor = [UIColor grayColor].CGColor;
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
