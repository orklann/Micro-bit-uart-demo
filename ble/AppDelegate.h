//
//  AppDelegate.h
//  ble
//
//  Created by Aaron Elkins on 8/21/18.
//  Copyright © 2018 Aaron Elkins. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *manager;
    CBPeripheral *connectedPeripheral;
    CBUUID *uartUUID;
    CBUUID *rxUUID;
    CBUUID *txUUID;
}

@end

