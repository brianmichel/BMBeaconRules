//
//  BMProximityRule.m
//  Beaconer
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "BMProximityRule.h"

@implementation BMProximityRule
- (instancetype)initWithRegion:(CLBeaconRegion *)region activationProximity:(CLProximity)activationProximity andCallback:(BMBeaconRuleCallback)callback {
    self = [super initWithRegion:region andCallback:callback];
    if (self) {
        _activationProximity = activationProximity;
        _lastAverageProximity = CLProximityUnknown;
    }
    return self;
}

- (void)didRangeWithBeacons:(NSArray *)beacons {
    [super didRangeWithBeacons:beacons];
    
    if (self.activationProximity == CLProximityUnknown) return; //if none has been specified, bail
    
    //get the average proximity of all beacons in the region
    NSNumber *averageState = [beacons valueForKeyPath:@"@avg.proximity"];
    CLProximity currentAverageProximity = [averageState integerValue];
    
    if (self.lastAverageProximity != currentAverageProximity && self.activationProximity == currentAverageProximity) {
        [self didEnterProximity];
    } else if (self.activationProximity != currentAverageProximity) {
        [self didExitProximity];
    }
    
    _lastAverageProximity = currentAverageProximity;
}

- (void)didEnterProximity {
    [self activateRule:YES];
}

- (void)didExitProximity {
    [self activateRule:NO];
}
@end
