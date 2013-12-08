//
//  TimerViewController.m
//  BLETester
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "TimerViewController.h"
#import "BMBeaconRules.h"
#import "EnterExitRule.h"
#import "ProximityRule.h"
#import "ProximityTimerRule.h"

@interface TimerViewController ()
@property (strong) BMBeaconRuleManager *rulesManager;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@end

@implementation TimerViewController

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
	// Do any additional setup after loading the view.
    
    self.rulesManager = [[BMBeaconRuleManager alloc] init];
    
    __weak typeof(self) weakSelf = self;
    
    ProximityRule *regularProximityRule = [[ProximityRule alloc] initWithRegion:kEstimoteBeaconRegion activationProximity:CLProximityImmediate andCallback:^(BMBeaconRule *rule, BOOL activated) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIColor *backgroundColor = activated ? [UIColor greenSeaColor] : [UIColor pomegranateColor];
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.view.backgroundColor = backgroundColor;
            }];
        });
    }];
    
    ProximityTimerRule *proximityTimerRule = [[ProximityTimerRule alloc] initWithRegion:kEstimoteBeaconRegion activationProximity:CLProximityImmediate andCallback:^(BMBeaconRule *rule, BOOL activated) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (activated) {
                [UIView animateWithDuration:0.3 animations:^{
                    weakSelf.countdownLabel.text = @"Vote Cast!";
                    weakSelf.view.backgroundColor = [UIColor emerlandColor];
                }];
            } else {
                weakSelf.countdownLabel.text = nil;
            }
        });
    }];
    proximityTimerRule.countdownBlock = ^(NSTimeInterval timeRemaining) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.countdownLabel.text = [NSString stringWithFormat:@"%f", timeRemaining];
        });
    };
    
    [self.rulesManager addRule:regularProximityRule];
    [self.rulesManager addRule:proximityTimerRule];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.rulesManager.suspendRules = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.rulesManager.suspendRules = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
