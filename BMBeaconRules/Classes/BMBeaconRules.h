//
//  BMBeaconRules.h
//  Beaconer
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;

@class BMBeaconRule;

@interface BMBeaconRuleManager : NSObject

/**
 Determines whether or not iBeacon events should
 be sent to rules.
 */
@property (assign) BOOL suspendRules;

- (BOOL)addRule:(BMBeaconRule *)rule;
- (BOOL)removeRule:(BMBeaconRule *)rule;
@end

typedef void(^BMBeaconRuleCallback)(BMBeaconRule *rule, BOOL activated);

@interface BMBeaconRule : NSObject

/**
 The region in which the rule is active
 */
@property (strong, readonly) CLBeaconRegion *ruleRegion;

/**
 Callback to be called when activated/deactivated.
 */
@property (copy) BMBeaconRuleCallback activationCallback;

/**
 Whether or not the rule is activated.
 */

/**TODO: this should probably be kvo-able, or something similar
 so that asychronous rules can join the fun. If you have a single
 asychronous rule, you should be fine. This just become an issue when
 using the composite rules.
*/
@property (assign, readonly) BOOL activated;

/**
 Default initializer
 
 @param region The region in which the rule should be active for.
 @param callback The callback which will be called when the rule criteria has been met.
 
 @throws NSInvalidArgumentException if region is nil.
 
 @warning if promximity is passed as `CLProximityUnknown` range monitoring will be disabled.
 */
- (instancetype)initWithRegion:(CLBeaconRegion *)region andCallback:(BMBeaconRuleCallback)callback;

- (void)didEnterRegion; //will be called asynchronously on a private dispatch queue.
- (void)didExitRegion;  //will be called asynchronously on a private dispatch queue.

- (void)didRangeWithBeacons:(NSArray *)beacons; //will be called asynchronously on a private dispatch queue.

- (void)activateRule:(BOOL)activate;    //will call the `activationCallback` if one exists.
@end

/**
 Your composite rule should have the same region as your subrules, otherwise
 it will never end up calling back any of it's subrules for validation (for the time being)
 */
@interface BMCompositeBeaconRule : BMBeaconRule
- (void)addRules:(NSArray *)rules;
@end

/**
 Will perform a logical AND on the subrules and activate accordingly.
 */
@interface BMCompositeAndRule : BMCompositeBeaconRule

@end

/**
 Will perform a logical OR on the subrules and activate accordingly.
 */
@interface BMCompositeOrRule : BMCompositeBeaconRule

@end
