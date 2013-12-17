//
//  BMEnterExitRule.m
//  Beaconer
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "BMEnterExitRule.h"

@implementation BMEnterExitRule

- (void)didEnterRegion {
    [super didEnterRegion];
    
    [self activateRule:YES];
}

- (void)didExitRegion {
    [super didExitRegion];
    
    [self activateRule:NO];
}
@end
