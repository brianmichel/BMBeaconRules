//
//  BMEnterExitRule.h
//  Beaconer
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "BMBeaconRules.h"

/**
    A simple rule that will toggle itself on if
 the region in which it is associated with is entered.
    
    It will also deactivate itself when a user has
 moved out of range of the region that the rule is associated with.
 */
@interface BMEnterExitRule : BMBeaconRule

@end
