//
//  BaseViewController.m
//  BMBeaconRules
//
//  Created by Brian Michel on 12/16/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "BaseViewController.h"
#import "BMBeaconRules.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconRuleManagerErrorNotification:) name:BMBeaconRuleManagerDidReceiveErrorNotification object:nil];
    _manager = [[BMBeaconRuleManager alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.manager.suspendRules = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.manager.suspendRules = YES;
}

#pragma mark - Notification
- (void)beaconRuleManagerErrorNotification:(NSNotification *)notification {
    NSLog(@"Beacon Manager Error: %@", notification.object);
}

@end
