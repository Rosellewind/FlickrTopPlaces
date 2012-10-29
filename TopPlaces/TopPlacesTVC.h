//
//  TopPlacesTVC.h
//  TopPlaces
//
//  Created by Roselle Milvich on 10/7/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class TopPlacesTVC;
@protocol MapDelegate <NSObject>
-(UIImage*) viewController:(TopPlacesTVC*) vc imageForAnnotation:(id <MKAnnotation>) annotation;
@end


@interface TopPlacesTVC : UIViewController<UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, MapDelegate>
@property (nonatomic, strong) NSArray *tableData;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) id <MapDelegate> mapDelegate;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *annotations;
-(void) showSpinnerInToolBar;
- (IBAction)choseView:(UISegmentedControl *)sender;
- (IBAction)refresh:(id)sender;

@end
