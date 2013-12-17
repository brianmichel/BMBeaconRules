//
//  BMBeaconRules.h
//  Beaconer
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Notification posted when an error is encountered from the underlying
 CLLocationManager. The object on this notification will always be an NSError
 object, and SHOULD be in the kCLError domain.
 */
extern NSString * const BMBeaconRuleManagerDidReceiveErrorNotification;

@import CoreLocation;

@class BMBeaconRule;

/**
 A rules engine for managing logic dealing with iBeacons.
 
 The basic idea is that you move your individual logic into 
 some class derived from BMBeaconRule and then add it to an
 instance of BMBeaconRuleManager. 

 In turn the rule manager will periodically call back to
 the registered set of rules which can be the trigger to various
 activation events. When activated, a rule will call it's activationBlock
 which has been provided by the user of the framework.
 */
@interface BMBeaconRuleManager : NSObject

/**
 Determines whether or not iBeacon events should
 be sent to rules.
 */
@property (assign) BOOL suspendRules;

- (BOOL)addRule:(BMBeaconRule *)rule;
- (BOOL)removeRule:(BMBeaconRule *)rule;
@end

/**
 Callback used for activation events on a rule.
 */
typedef void(^BMBeaconRuleCallback)(BMBeaconRule *rule, BOOL activated);

/**
 The basic unit of measure for the BMBeaconRuleManager.
 
    This should be subclassed and used as a container for
 your logic. The rule will receive events from the manager
 such as entering the region, exiting the region, and ranging
 beacons in a region. Any combination of these events or other
 things can be used as activation criteria on a rule.
 */
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
 */
- (instancetype)initWithRegion:(CLBeaconRegion *)region andCallback:(BMBeaconRuleCallback)callback;

/**
 Called when the user enters into the specified region.
 
 @note This will be called asynchronously on a private dispatch queue.
 */
- (void)didEnterRegion;

/**
 Called when the user exits the specified region.
 
 @note This will be called asynchronously on a private dispatch queue.
 */
- (void)didExitRegion;

/**
 Called while ranging beacons in a range that has been entered.
 
 @note This will be called asynchronously on a private dispatch queue.
 */
- (void)didRangeWithBeacons:(NSArray *)beacons;

/**
 Trigger used to activate or deactivate a rule.
 
 This will cause the activationCallback block to be called with 
 the activated property, and the rule that has been triggered passed
 in.
 
 @note This will be called on the main thread.
 */
- (void)activateRule:(BOOL)activate;
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
