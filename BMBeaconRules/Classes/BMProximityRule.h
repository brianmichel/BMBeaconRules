//
//  BMProximityRule.h
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
@interface BMProximityRule : BMBeaconRule

/**
 The proximity in which the rule should activate
 */
@property (assign, readonly) CLProximity activationProximity;

/**
 The last proximity derived from all of the beacons passed into 
 -didRangeWithBeacons:
 
 @note The averaging of location simply takes the average of all
 beacon proximity properties.
 */
@property (assign, readonly) CLProximity lastAverageProximity;

/**
 Default initializer for the BMProximityRule
 
 @param region The region in which the rule is associated with.
 @param activationProximity The proximity which should activate the rule.
 @param callback A block representing what to call when the rule is toggled on and off.
 
 @return A fully initialized BMProximityRule object ready to be added to a BMBeaconRuleManager
 
 @warning if promximity is passed as CLProximityUnknown range monitoring will be disabled.
 */
- (instancetype)initWithRegion:(CLBeaconRegion *)region activationProximity:(CLProximity)activationProximity andCallback:(BMBeaconRuleCallback)callback;

/**
 Called when the user has entered the specified activationProximity
 
 @note Subclassers should NOT call super, this will end up triggering
 the activateRule: logic for this baseclass. I'd love to figure out a
 cleaner way to do this, I'm open to ideas...
 */
- (void)didEnterProximity;

/**
 Called when the user has exited the specified activationProximity
 
 @note Subclassers should NOT call super, this will end up triggering
 the activateRule: logic for this baseclass. I'd love to figure out a
 cleaner way to do this, I'm open to ideas...
 */
- (void)didExitProximity;

@end
