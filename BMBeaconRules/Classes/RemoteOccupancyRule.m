//
//  RemoteOccupancyRule.m
//  BMBeaconRules
//
//  Created by Brian Michel on 12/7/13.
//  Copyright (c) 2013 Brian Michel. All rights reserved.
//

#import "RemoteOccupancyRule.h"
#import <SocketClient/SocketClient.h>

@import MultipeerConnectivity;

@interface RemoteOccupancyRule () <MCNearbyServiceBrowserDelegate>
@property (strong) MCNearbyServiceAdvertiser *advertiser;
@property (strong) MCNearbyServiceBrowser *browser;
@property (strong) NSMutableArray *peers;

@property (assign) CLProximity lastProximity;
@end

@implementation RemoteOccupancyRule

- (instancetype)initWithRegion:(CLBeaconRegion *)region activationProximity:(CLProximity)proxmity andCallback:(BMBeaconRuleCallback)callback {
    self = [super initWithRegion:region activationProximity:proxmity andCallback:callback];
    if (self) {
        self.peers = [NSMutableArray array];
                
        self.lastProximity = CLProximityUnknown;
        
        MCPeerID *peerId = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peerId discoveryInfo:nil serviceType:@"bsm-remote"];
        
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerId serviceType:@"bsm-remote"];
        self.browser.delegate = self;
#ifdef TARGET_IPHONE_SIMULATOR
        [self.advertiser startAdvertisingPeer];
        [self.browser startBrowsingForPeers];
#endif
    }
    return self;
}

- (void)didRangeWithBeacons:(NSArray *)beacons {
    [super didRangeWithBeacons:beacons];
    NSNumber *averageState = [beacons valueForKeyPath:@"@avg.proximity"];
    CLProximity proximity = [averageState integerValue];
    if (self.lastProximity != proximity && proximity == self.activationProximity) {
        [self.advertiser startAdvertisingPeer];
        [self.browser startBrowsingForPeers];
    } else if (proximity != self.activationProximity) {
        [self.advertiser stopAdvertisingPeer];
        [self.browser stopBrowsingForPeers];
    }
    self.lastProximity = proximity;
}

#pragma mark - Service Browser Delegate
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    [self.peers addObject:peerID];

    BOOL shouldActivate = [self.peers count] > 0;
    [self activateRule:shouldActivate];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    [self.peers removeObject:peerID];
    BOOL shouldActivate = [self.peers count] > 0;
    [self activateRule:shouldActivate];
}

@end
