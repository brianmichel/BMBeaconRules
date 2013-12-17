//
//  ProximityRule.h
//  Beaconer
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "BMBeaconRules.h"

/**
    This rule will activate when beacons in the appropriate region
 come into the associated proximity zone. It will also toggle itself
 off if the listening device (phone/pad) is moved out of the required 
 proximity.
 */
@interface ProximityRule : BMBeaconRule

/**
 The proximity in which the rule should activate
 */
@property (assign, readonly) CLProximity activationProximity;

/**
 Default initializer for the ProximityRule
 
 @param region The region in which the rule is associated with.
 @param activationProximity The proximity which should activate the rule.
 @param callback A block representing what to call when the rule is toggled on and off.
 
 @return A fully initialized ProximityRule object ready to be added to a BMBeaconRuleManager
 */
- (instancetype)initWithRegion:(CLBeaconRegion *)region activationProximity:(CLProximity)activationProximity andCallback:(BMBeaconRuleCallback)callback;

@end
