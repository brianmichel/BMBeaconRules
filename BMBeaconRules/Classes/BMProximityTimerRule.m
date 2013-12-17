//
//  BMProximityTimerRule.m
//  Beaconer
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "BMProximityTimerRule.h"
#import "BMBeaconRules.h"

@interface BMProximityTimerRule ()
@property (strong) NSTimer *timer;
@property (assign) NSTimeInterval timeLimit;
@property (assign) NSTimeInterval timeRemaining;
@property (assign) CLProximity lastAverageProximity;
@end

@implementation BMProximityTimerRule

- (instancetype)initWithRegion:(CLBeaconRegion *)region activationProximity:(CLProximity)proxmity timeLimit:(NSTimeInterval)timeLimit andCallback:(BMBeaconRuleCallback)callback {
    self = [super initWithRegion:region activationProximity:proxmity andCallback:callback];
    if (self) {
        self.timeLimit = self.timeRemaining = timeLimit;
    }
    return self;
}

- (void)didEnterProximity {
    [self setupTimer];
}

- (void)didExitProximity {
    [self tearDownTimer];
    [self activateRule:NO];
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
    } else {
        if (self.countdownBlock) {
            self.countdownBlock(self.timeRemaining);
        }
        self.timeRemaining -= 1.0;
    }
}

@end
