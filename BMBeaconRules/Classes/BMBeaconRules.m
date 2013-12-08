//
//  BMBeaconRules.m
//  Beaconer
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "BMBeaconRules.h"

@interface BMBeaconRuleManager () <CLLocationManagerDelegate>

@end

@implementation BMBeaconRuleManager {
    CLLocationManager *_manager;
    NSMutableDictionary *_rulesForRegionDictionary;
    dispatch_queue_t _ruleBackgroundQueue;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
        
        _rulesForRegionDictionary = [NSMutableDictionary dictionary];
        
        _ruleBackgroundQueue = dispatch_queue_create("BluetoothRuleManager Background Queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (BOOL)addRule:(BMBeaconRule *)rule {
    NSMutableArray *ruleArrayForKey = _rulesForRegionDictionary[rule.ruleRegion];
    
    // if no array exists we're not yet monitoring this region
    if (!ruleArrayForKey) {
        ruleArrayForKey = [NSMutableArray array];
        [ruleArrayForKey addObject:rule];
        _rulesForRegionDictionary[rule.ruleRegion] = ruleArrayForKey;
        [_manager requestStateForRegion:rule.ruleRegion];
        [_manager startMonitoringForRegion:rule.ruleRegion];
    } else {
        [ruleArrayForKey addObject:rule];
    }
    return YES;
}

- (BOOL)removeRule:(BMBeaconRule *)rule {
    NSMutableArray *ruleArrayForKey = _rulesForRegionDictionary[rule.ruleRegion];
    
    /**
     If we have rules, and the array contains the object, remove the rule.
     If after that, the count of the rules array is zero, remove the array 
     so that the addRule logic will be correct. As a side-effect we also stop
     monitoring/ranging the region if we remove the array.
     */
    if ([ruleArrayForKey count] && [ruleArrayForKey containsObject:rule]) {
        [ruleArrayForKey removeObject:rule];
        if (![ruleArrayForKey count]) {
            [_rulesForRegionDictionary removeObjectForKey:rule.ruleRegion];
            [_manager stopRangingBeaconsInRegion:rule.ruleRegion];
            [_manager stopMonitoringForRegion:rule.ruleRegion];
        }
        return YES;
    }
    return NO;
}

#pragma mark - CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if (self.suspendRules) return;

    switch (state) {
        case CLRegionStateInside:
            [self notifyRegionEntryForRegion:region];
            break;
        case CLRegionStateOutside:
            [self notifyRegionExitFoRregion:region];
            break;
        case CLRegionStateUnknown:
        default:
            //do nothing
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if (self.suspendRules) return;

    [self notifyRegionEntryForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if (self.suspendRules) return;

    [self notifyRegionExitFoRregion:region];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    if (self.suspendRules) return;

    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        dispatch_async(_ruleBackgroundQueue, ^{
            NSArray *rules = _rulesForRegionDictionary[region];
            for (BMBeaconRule *rule in rules) {
                [rule didRangeWithBeacons:beacons];
            }
        });
    }
}

#pragma mark - Helpers
- (void)notifyRegionEntryForRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        dispatch_async(_ruleBackgroundQueue, ^{
            NSArray *rules = _rulesForRegionDictionary[region];
            for (BMBeaconRule *rule in rules) {
                [rule didEnterRegion];
            }
        });
        [_manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)notifyRegionExitFoRregion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        dispatch_async(_ruleBackgroundQueue, ^{
            NSArray *rules = _rulesForRegionDictionary[region];
            for (BMBeaconRule *rule in rules) {
                [rule didExitRegion];
            }
        });
        [_manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

@end

@implementation BMBeaconRule

- (instancetype)initWithRegion:(CLBeaconRegion *)region activationProximity:(CLProximity)proxmity andCallback:(BMBeaconRuleCallback)callback {
    self = [super init];
    if (self) {
        if (!region) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"A BMBeaconRule MUST have a region" userInfo:nil];
        }
        _ruleRegion = region;
        _activationProximity = proxmity;
        self.activationCallback = callback;
    }
    return self;
}

- (void)didEnterRegion {
    //To be overridden in subclass
}

- (void)didExitRegion {
    //To be overridden in subclass
}

- (void)didRangeWithBeacons:(NSArray *)beacons {
    if (self.activationProximity == CLProximityUnknown) {
        return;
    }
}

- (void)activateRule:(BOOL)activate {
    if (_activated == activate) {
        return;
    }
    
    _activated = activate;
    if (self.activationCallback) {
        self.activationCallback(self, activate);
    }
}
@end

@interface BMCompositeBeaconRule ()
@property (strong) NSMutableArray *subRules;

- (void)evaluatePossibleActivation;
@end

@implementation BMCompositeBeaconRule
- (instancetype)initWithRegion:(CLBeaconRegion *)region activationProximity:(CLProximity)proxmity andCallback:(BMBeaconRuleCallback)callback {
    self = [super initWithRegion:region activationProximity:proxmity andCallback:callback];
    if (self) {
        self.subRules = [NSMutableArray array];
    }
    return self;
}

- (void)addRules:(NSArray *)rules {
    [self.subRules addObjectsFromArray:rules];
}


- (void)didRangeWithBeacons:(NSArray *)beacons {
    [super didRangeWithBeacons:beacons];
    for (BMBeaconRule *rule in self.subRules) {
        [rule didRangeWithBeacons:beacons];
    }
    [self evaluatePossibleActivation];
}

- (void)didEnterRegion {
    [super didEnterRegion];
    for (BMBeaconRule *rule in self.subRules) {
        [rule didEnterRegion];
    }
    [self evaluatePossibleActivation];
}

- (void)didExitRegion {
    [super didExitRegion];
    for (BMBeaconRule *rule in self.subRules) {
        [rule didExitRegion];
    }
    [self evaluatePossibleActivation];
}

- (void)evaluatePossibleActivation {
    //to be overridden in subclass
}
@end

@implementation BMCompositeAndRule

- (void)evaluatePossibleActivation {
    BOOL allRulesActivated = YES;
    for (BMBeaconRule *rule in self.subRules) {
        if (!rule.activated) {
            allRulesActivated = NO;
            break;
        }
    }
    [self activateRule:allRulesActivated];
}

@end

@implementation BMCompositeOrRule

- (void)evaluatePossibleActivation {
    BOOL anyRulesActivated = NO;
    for (BMBeaconRule *rule in self.subRules) {
        if (rule.activated) {
            anyRulesActivated = YES;
            break;
        }
    }
    [self activateRule:anyRulesActivated];
}

@end