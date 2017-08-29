//
//  ViewController.m
//  YALRentalPullToRefresh
//
//  Created by Konstantin Safronov on 12/24/14.
//  Copyright (c) 2014 Konstantin Safronov. All rights reserved.
//

#import "YALExampleViewController.h"
#import "YALSunnyRefreshControl.h"

@interface YALExampleViewController ()

@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;

@end

@implementation YALExampleViewController

# pragma mark - UIView life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = false;

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupRefreshControl];
    [self initOpenSourceView: self];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.sunnyRefreshControl beginRefreshing];
}

# pragma mark - YALSunyRefreshControl methods

-(void)setupRefreshControl{
    
    self.sunnyRefreshControl = [YALSunnyRefreshControl new];
    [self.sunnyRefreshControl addTarget:self
                                 action:@selector(sunnyControlDidStartAnimation)
                       forControlEvents:UIControlEventValueChanged];
    [self.sunnyRefreshControl attachToScrollView:self.tableView];
}

-(void)sunnyControlDidStartAnimation{
    // start loading something
}

-(IBAction)endAnimationHandle{
    
    [self.sunnyRefreshControl endRefreshing];
}

@end
