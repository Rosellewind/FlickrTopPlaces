//
//  TopPlacesTVC.h
//  TopPlaces
//
//  Created by Roselle Milvich on 10/7/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopPlacesTVC : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *tableData;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
-(void) showSpinnerInToolBar;
@end
