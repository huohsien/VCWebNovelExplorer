//
//  ViewController.h
//  VCWebNovelExplorer
//
//  Created by victor on 10/19/16.
//  Copyright © 2016 VHHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCWebNovelDownloader.h"


@interface ViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, VCWebNovelDownloaderDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

