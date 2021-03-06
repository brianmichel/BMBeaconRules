//
//  VotingViewController.m
//  BLETester
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "VotingViewController.h"
#import "BMBeaconRules.h"
#import "BMProximityRule.h"

@interface VotingViewController ()
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@end

@implementation VotingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.yesButton.backgroundColor = [UIColor emerlandColor];
    
    self.noButton.backgroundColor = [UIColor pomegranateColor];
    
    self.yesButton.enabled = self.noButton.enabled = NO;
    self.yesButton.alpha = self.noButton.alpha = 0.4;
    
    __weak typeof(self) weakSelf = self;
    
    BMProximityRule *buttonToggle = [[BMProximityRule alloc] initWithRegion:kEstimoteBeaconRegion activationProximity:CLProximityImmediate andCallback:^(BMBeaconRule *rule, BOOL activated) {
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.yesButton.enabled = activated;
            weakSelf.noButton.enabled = !weakSelf.yesButton.enabled;
            
            weakSelf.yesButton.alpha = activated ? 1.0 : 0.4;
            weakSelf.noButton.alpha = activated ? 0.4 : 1.0;
        }];
    }];
    
    [self.manager addRule:buttonToggle];
	// Do any additional setup after loading the view.
}

@end
