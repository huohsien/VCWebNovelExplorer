//
//  VCChapterTextViewController.h
//  VCWebNovelExplorer
//
//  Created by victor on 10/31/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCTextView.h"

@interface VCChapterTextViewController : UIViewController
@property (weak, nonatomic) IBOutlet VCTextView *textView;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *chapterTitle;
@property (weak, nonatomic) IBOutlet UILabel *chapterTitleLabel;
@end
