//
//  EntranceTimerRule.m
//  Beaconer
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "ProximityTimerRule.h"

@interface ProximityTimerRule ()
@property (strong) NSTimer *timer;
@property (assign) NSTimeInterval timeLimit;
@property (assign) NSTimeInterval timeRemaining;
@property (assign) CLProximity lastAverageProximity;
@end

@implementation ProximityTimerRule

- (instancetype)initWithRegion:(CLBeaconRegion *)region activationProximity:(CLProximity)proxmity andCallback:(BMBeaconRuleCallback)callback {
    self = [super initWithRegion:region activationProximity:proxmity andCallback:callback];
    if (self) {
        self.timeLimit = self.timeRemaining = 5.0;
        self.lastAverageProximity = CLProximityUnknown;
    }
    return self;
}

- (void)didRangeWithBeacons:(NSArray *)beacons {
    [super didRangeWithBeacons:beacons];
    
    //get the average proximity of all beacons in the region
    NSNumber *averageState = [beacons valueForKeyPath:@"@avg.proximity"];
    CLProximity currentAverageProximity = [averageState integerValue];
    if (self.lastAverageProximity != currentAverageProximity && self.activationProximity == currentAverageProximity) {
        [self setupTimer];
    } else if (self.activationProximity != currentAverageProximity) {
        [self tearDownTimer];
        [self activateRule:NO];
    }
    
    self.lastAverageProximity = currentAverageProximity;
}

- (void)setupTimer {
    [self tearDownTimer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    });
}

- (void)tearDownTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.timeRemaining = self.timeLimit;
    }
}

- (void)timerFired:(NSTimer *)timer {
    if (self.timeRemaining <= 0) {
        [self activateRule:YES];
        [self tearDownTimer];
        [self activateRule:NO];
    } else {
        if (self.countdownBlock) {
            self.countdownBlock(self.timeRemaining);
        }
        self.timeRemaining -= 1.0;
    }
}

@end
