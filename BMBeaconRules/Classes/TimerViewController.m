//
//  TimerViewController.m
//  BLETester
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "TimerViewController.h"
#import "BMBeaconRules.h"
#import "BMEnterExitRule.h"
#import "BMProximityRule.h"
#import "BMProximityTimerRule.h"

@interface TimerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@end

@implementation TimerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    __weak typeof(self) weakSelf = self;
    
    BMProximityRule *regularProximityRule = [[BMProximityRule alloc] initWithRegion:kEstimoteBeaconRegion activationProximity:CLProximityImmediate andCallback:^(BMBeaconRule *rule, BOOL activated) {
        UIColor *backgroundColor = activated ? [UIColor greenSeaColor] : [UIColor pomegranateColor];
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.view.backgroundColor = backgroundColor;
        }];
    }];
    
    BMProximityTimerRule *proximityTimerRule = [[BMProximityTimerRule alloc] initWithRegion:kEstimoteBeaconRegion activationProximity:CLProximityImmediate timeLimit:5.0 andCallback:^(BMBeaconRule *rule, BOOL activated) {
        if (activated) {
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.countdownLabel.text = @"Vote Cast!";
                weakSelf.view.backgroundColor = [UIColor emerlandColor];
            }];
        } else {
            weakSelf.countdownLabel.text = nil;
        }
    }];
    proximityTimerRule.countdownBlock = ^(NSTimeInterval timeRemaining) {
        weakSelf.countdownLabel.text = [NSString stringWithFormat:@"%f", timeRemaining];
    };
    
    [self.manager addRule:regularProximityRule];
    [self.manager addRule:proximityTimerRule];
}

@end
