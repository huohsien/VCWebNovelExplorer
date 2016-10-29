//
//  ViewController.h
//  VCWebNovelExplorer
//
//  Created by victor on 10/19/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate, WKNavigationDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIView *webViewContainerView;
@end

