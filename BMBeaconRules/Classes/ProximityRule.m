//
//  ProximityRule.m
//  Beaconer
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "ProximityRule.h"

@implementation ProximityRule
- (void)didRangeWithBeacons:(NSArray *)beacons {
    [super didRangeWithBeacons:beacons];
    
    for (CLBeacon *beacon in beacons) {
        if (beacon.proximity == self.activationProximity) {
            [self activateRule:YES];
            return;
        }
    }
    [self activateRule:NO];
}
@end
