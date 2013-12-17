//
//  BMProximityTimerRule.h
//  Beaconer
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "BMProximityRule.h"

/**
 Similar to the regular BMProximityRule, however,
 this requires a user to remain in the proximity for
 the length of time specified by the timeLimit parameter.
 */
@interface BMProximityTimerRule : BMProximityRule

/**
 The amount of time a user must wait in the activationProximity
 in order to trigger the rule.
 */
@property (assign, readonly) NSTimeInterval timeLimit;

/**
 A block called with the number of seconds remaining.
 
 @note This is called on the main thread.
 */
@property (copy) void (^countdownBlock)(NSTimeInterval);

/**
 Default initializer for the BMProximityTimerRule
 
 @param region The region in which the rule is associated with.
 @param activationProximity The proximity which should activate the rule.
 @param timeLimit The amount of time (in seconds) that the user must remain in the zone to trigger the rule.
 @param callback A block representing what to call when the rule is toggled on and off.
 
 @return A fully initialized BMProximityRule object ready to be added to a BMBeaconRuleManager
 
 @warning if promximity is passed as CLProximityUnknown range monitoring will be disabled.
 */
- (instancetype)initWithRegion:(CLBeaconRegion *)region activationProximity:(CLProximity)activationProximity timeLimit:(NSTimeInterval)timeLimit andCallback:(BMBeaconRuleCallback)callback;
@end
