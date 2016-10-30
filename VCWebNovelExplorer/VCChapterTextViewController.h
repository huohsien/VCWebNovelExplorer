//
//  VCChapterTextViewController.h
//  VCWebNovelExplorer
//
//  Created by victor on 10/31/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCChapterTextViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString *text;
@end
