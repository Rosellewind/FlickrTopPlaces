//
//  PhotoVC.m
//  TopPlaces
//
//  Created by Roselle Milvich on 10/8/12.
//  Copyright (c) 2012 class. All rights reserved.
//

#import "PhotoVC.h"
#import "FlickrFetcher.h"
#import "ButtonDancer.h"
#import "Cacher.h"

@interface PhotoVC()<UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSMutableArray *cachedPhotos;

@end

@implementation PhotoVC
@synthesize photo = _photo;
@synthesize description = _description;

@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize toolbar = _toolbar;
@synthesize spinner = _spinner;
@synthesize cachedPhotos = _cachedPhotos;

@synthesize buttonDancerbbi = _buttonDancerbbi;

#pragma mark - Image Methods

-(void)loadImage{
    NSString *key = [self.photo objectForKey:@"id"];
    
    //show spinner while getting photo
    [self.spinner startAnimating];
    
    //check to see if photo is cached
    UIImage *cachedImage = [Cacher cachedImageForKey:key isThumb:NO];
    if (cachedImage){
        [self.spinner stopAnimating];
        self.imageView.image = cachedImage;
        [self prepareImage];
    }
    else {
        //get photo
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr image downloader", NULL);
        dispatch_async(downloadQueue, ^{
//            NSLog(@"fetching: loadImage");
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinner stopAnimating];
                self.imageView.image = image;
                [self prepareImage];
            });
            
            //manage cache
            [self.cachedPhotos insertObject:key atIndex:0];
            if ([Cacher isOverLimitIsThumb:NO]){
                [Cacher removeCacheForKey:[self.cachedPhotos lastObject] isThumb:NO];
                [self.cachedPhotos removeLastObject];
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.cachedPhotos forKey:@"cachedPhotos"];
            [defaults synchronize];
            [Cacher cacheImage:image withKey:key isThumb:NO];
        });
    }
}

-(void)prepareImage{
    UIImage *image = self.imageView.image;
    float zoom = [self initialZoomScaleForImage:image inBounds:self.scrollView.frame];
    self.scrollView.zoomScale = zoom;
    double adjWidth = image.size.width * self.scrollView.zoomScale;
    double adjHeight = image.size.height * self.scrollView.zoomScale;
    self.imageView.frame = CGRectMake(0, 0, adjWidth, adjHeight);
    self.scrollView.contentSize = CGSizeMake(adjWidth, adjHeight);
}

-(float) initialZoomScaleForImage:(UIImage*) image inBounds:(CGRect) bounds{
    float heightZoom = bounds.size.height/image.size.height;
    float widthZoom = bounds.size.width/image.size.width;
    float max = MAX(heightZoom, widthZoom);
    return max;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.cachedPhotos = [[defaults arrayForKey:@"cachedPhotos"]mutableCopy];
    if (!self.cachedPhotos) self.cachedPhotos = [[NSMutableArray alloc]init];
    
    if (!self.splitViewController)[self loadImage];
    self.navigationItem.title = self.description;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    if (!self.splitViewController)[self prepareImage];
}

-(void) awakeFromNib{
    self.splitViewController.delegate = self;
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setTitle:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

#pragma mark - Split View Methods

-(BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return ([self buttonDancer]) ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

-(void) splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc{
    barButtonItem.title = @"Pictures";
    [self buttonDancer].buttonDancerbbi = barButtonItem;
}

-(void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem{
    [self buttonDancer].buttonDancerbbi = nil;
}

-(void)setButtonDancerbbi:(UIBarButtonItem *)buttonDancerbbi{
    if (_buttonDancerbbi != buttonDancerbbi){
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_buttonDancerbbi) [toolbarItems removeObject:_buttonDancerbbi];
        if (buttonDancerbbi)
            [toolbarItems insertObject:buttonDancerbbi atIndex:0];
        self.toolbar.items = toolbarItems;
        _buttonDancerbbi = buttonDancerbbi;
    }
}

-(id <ButtonDancer>)buttonDancer{
    id vc = [self.splitViewController.viewControllers lastObject];
    if (![vc conformsToProtocol:@protocol(ButtonDancer)])
        vc = nil;
    return vc;
}

#pragma mark - ScrollView Delegate

-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

@end
