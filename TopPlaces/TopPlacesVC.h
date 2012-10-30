//
//  TopPlacesVC.h
//  TopPlaces
//
//  Created by Roselle Milvich on 10/29/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import <UIKit/UIKit.h>

#define USING_MAP 1
#define USING_TABLE 0

@class TopPlacesTVC;
@class TopPlacesMVC;

@interface TopPlacesVC : UIViewController
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, strong) TopPlacesTVC *tvc;
@property (nonatomic, strong) TopPlacesMVC *mvc;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *refreshButton; //strong to reuse
@property (nonatomic, assign) BOOL isUsingMapOrTable;

-(void) showSpinnerInToolBar;
- (IBAction)choseView:(UISegmentedControl *)sender;
- (IBAction)refresh:(id)sender;

@end
