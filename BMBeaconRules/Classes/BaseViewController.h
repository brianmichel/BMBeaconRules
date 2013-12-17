//
//  BaseViewController.h
//  BMBeaconRules
//
//  Created by Brian Michel on 12/16/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BMBeaconRuleManager;

@interface BaseViewController : UIViewController
@property (strong, readonly) BMBeaconRuleManager *manager;
@end
