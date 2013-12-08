//
//  EntranceTimerRule.h
//  Beaconer
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "BMBeaconRules.h"

@interface ProximityTimerRule : BMBeaconRule
@property (copy) void (^countdownBlock)(NSTimeInterval);
@end
