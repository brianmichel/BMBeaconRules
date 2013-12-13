//
//  MultiViewController.m
//  BLETester
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "MultiViewController.h"
#import "BMBeaconRules.h"
#import "RemoteOccupancyRule.h"

@interface MultiViewController ()
@property (strong) BMBeaconRuleManager *manager;
@end

@implementation MultiViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.manager = [[BMBeaconRuleManager alloc] init];
    
    RemoteOccupancyRule *rule = [[RemoteOccupancyRule alloc] initWithRegion:kEstimoteBeaconRegion activationProximity:CLProximityImmediate andCallback:^(BMBeaconRule *rule, BOOL activated) {
        if (activated) {
            NSLog(@"%@: ACTIVATED REMOTE OCCUPANCY RULE!", [UIDevice currentDevice].name);
        } else {
            NSLog(@"%@: DEACTIVATED REMOTE OCCUPANCY RULE!", [UIDevice currentDevice].name);
        }
    }];
    
    [self.manager addRule:rule];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
